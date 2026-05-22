#!/usr/bin/env node
/**
 * Export saved Metabase cards into the handoff artifact layout:
 *   artifacts/queries/<card_id>__<slug>.sql
 *   artifacts/metadata/<card_id>__<slug>.json
 *
 * Auth options, read from repo-root .env or the current environment:
 *   METABASE_SESSION=...      -> X-Metabase-Session
 *   METABASE_API_KEY=...      -> x-api-key
 *   METABASE_COOKIE=...       -> Cookie header, e.g. metabase.SESSION=...
 *   METABASE_USERNAME=...
 *   METABASE_PASSWORD=...     -> POST /api/session
 */
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "fs";
import { dirname, join, resolve } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, "..");
const ARTIFACTS = join(REPO_ROOT, "artifacts");
const QUERIES = join(ARTIFACTS, "queries");
const METADATA = join(ARTIFACTS, "metadata");

function loadEnvFile() {
  const p = join(REPO_ROOT, ".env");
  if (!existsSync(p)) return;
  for (const line of readFileSync(p, "utf8").split(/\r?\n/)) {
    const t = line.trim();
    if (!t || t.startsWith("#")) continue;
    const m = /^([A-Za-z_][A-Za-z0-9_]*)=(.*)$/.exec(t);
    if (!m) continue;
    const key = m[1];
    let val = m[2].trim();
    if (
      (val.startsWith('"') && val.endsWith('"')) ||
      (val.startsWith("'") && val.endsWith("'"))
    ) {
      val = val.slice(1, -1);
    }
    if (process.env[key] === undefined) process.env[key] = val;
  }
}

function slugify(raw) {
  return String(raw || "")
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/&/g, " and ")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 120);
}

function jsonHeaders(extra = {}) {
  return {
    Accept: "application/json",
    "Content-Type": "application/json",
    "User-Agent": "curefit-auditor-metabase-export",
    ...extra,
  };
}

async function makeAuthHeaders(baseUrl) {
  const headers = {};

  if (process.env.METABASE_API_KEY) {
    headers["x-api-key"] = process.env.METABASE_API_KEY;
  }
  if (process.env.METABASE_SESSION) {
    headers["X-Metabase-Session"] = process.env.METABASE_SESSION;
  }
  if (process.env.METABASE_COOKIE) {
    headers.Cookie = process.env.METABASE_COOKIE;
  }

  if (
    !headers["x-api-key"] &&
    !headers["X-Metabase-Session"] &&
    !headers.Cookie &&
    process.env.METABASE_USERNAME &&
    process.env.METABASE_PASSWORD
  ) {
    const res = await fetch(`${baseUrl}/api/session`, {
      method: "POST",
      headers: jsonHeaders(),
      body: JSON.stringify({
        username: process.env.METABASE_USERNAME,
        password: process.env.METABASE_PASSWORD,
      }),
    });
    if (!res.ok) {
      const text = await res.text();
      throw new Error(`Metabase login failed: ${res.status} ${text.slice(0, 200)}`);
    }
    const body = await res.json();
    if (!body.id) throw new Error("Metabase login did not return a session id.");
    headers["X-Metabase-Session"] = body.id;
  }

  if (!Object.keys(headers).length) {
    throw new Error(
      [
        "No Metabase auth found.",
        "Set METABASE_SESSION, METABASE_API_KEY, METABASE_COOKIE, or METABASE_USERNAME/METABASE_PASSWORD in .env.",
      ].join(" "),
    );
  }

  return headers;
}

function nativeSqlFromCard(card) {
  const query = card?.dataset_query;
  if (query?.type === "native" && query.native?.query) {
    return query.native.query;
  }
  if (query?.native?.query) return query.native.query;
  const firstStage = Array.isArray(query?.stages) ? query.stages[0] : null;
  if (firstStage?.native?.query) return firstStage.native.query;
  if (typeof firstStage?.native === "string") return firstStage.native;
  return null;
}

async function fetchCard(baseUrl, authHeaders, cardId) {
  const res = await fetch(`${baseUrl}/api/card/${encodeURIComponent(cardId)}`, {
    headers: jsonHeaders(authHeaders),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Card ${cardId}: ${res.status} ${text.slice(0, 200)}`);
  }
  return res.json();
}

function loadExistingMetadata(metadataPath) {
  if (!existsSync(metadataPath)) return null;
  try {
    return JSON.parse(readFileSync(metadataPath, "utf8"));
  } catch {
    return null;
  }
}

function mergeResultMetadata(card, existingCard) {
  const fresh = card?.result_metadata;
  const previous = existingCard?.result_metadata;
  const hasFreshResultMetadata = Array.isArray(fresh) && fresh.length > 0;
  const hasPreviousResultMetadata =
    Array.isArray(previous) && previous.length > 0;

  if (hasFreshResultMetadata || !hasPreviousResultMetadata) return card;

  return {
    ...card,
    result_metadata: previous,
  };
}

async function main() {
  loadEnvFile();
  const cardIds = process.argv.slice(2).filter(Boolean);
  if (!cardIds.length) {
    throw new Error("Usage: node scripts/export-metabase-cards.mjs <card-id> [card-id ...]");
  }

  const baseUrl = (process.env.METABASE_SITE_URL || "https://metabase.curefit.co").replace(
    /\/$/,
    "",
  );
  const authHeaders = await makeAuthHeaders(baseUrl);

  mkdirSync(QUERIES, { recursive: true });
  mkdirSync(METADATA, { recursive: true });

  for (const cardId of cardIds) {
    const card = await fetchCard(baseUrl, authHeaders, cardId);
    const name = card.name || `Card ${cardId}`;
    const slug = slugify(name) || `card-${cardId}`;
    const sql = nativeSqlFromCard(card);

    const metadataPath = join(METADATA, `${cardId}__${slug}.json`);
    const existingCard = loadExistingMetadata(metadataPath);
    const mergedCard = mergeResultMetadata(card, existingCard);
    writeFileSync(metadataPath, `${JSON.stringify(mergedCard, null, 2)}\n`, "utf8");

    if (!sql) {
      throw new Error(
        `Card ${cardId} (${name}) was exported to metadata, but it does not contain native SQL.`,
      );
    }
    const queryPath = join(QUERIES, `${cardId}__${slug}.sql`);
    writeFileSync(queryPath, `${sql.replace(/\s+$/, "")}\n`, "utf8");

    console.log(`Exported ${cardId} ${JSON.stringify(name)}`);
    console.log(`  ${queryPath}`);
    console.log(`  ${metadataPath}`);
  }
}

main().catch((err) => {
  console.error(err instanceof Error ? err.message : String(err));
  process.exit(1);
});

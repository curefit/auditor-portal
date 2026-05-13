#!/usr/bin/env node
/**
 * Refresh sample result CSV/JSON files under artifacts/results without changing
 * portal UI behavior or file naming.
 *
 * Default behavior is logic-preserving:
 * - only date params are auto-updated
 * - non-date params are preserved as-is unless an explicit override exists
 *
 * Usage:
 *   node scripts/refresh-result-files.mjs --dry-run
 *   node scripts/refresh-result-files.mjs --write
 *   node scripts/refresh-result-files.mjs --write --only question-75109
 *   node scripts/refresh-result-files.mjs --write --only dashboard-3604
 */
import {
  existsSync,
  readFileSync,
  readdirSync,
  renameSync,
  rmSync,
  writeFileSync,
} from "fs";
import { dirname, extname, join, resolve } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, "..");
const RESULTS_DIR = join(REPO_ROOT, "artifacts", "results");
const OVERRIDES_PATH = join(REPO_ROOT, "artifacts", "result_refresh_overrides.json");

const START_DATE = "2023-04-01";
const END_DATE = "2026-03-31";

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

function jsonHeaders(extra = {}) {
  return {
    Accept: "application/json",
    "Content-Type": "application/json",
    "User-Agent": "curefit-auditor-result-refresh",
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

function parseArgs(argv) {
  const opts = {
    dryRun: false,
    write: false,
    only: [],
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--dry-run") {
      opts.dryRun = true;
    } else if (arg === "--write") {
      opts.write = true;
    } else if (arg === "--only") {
      const next = argv[i + 1];
      if (!next) throw new Error("Missing value for --only");
      opts.only.push(next);
      i += 1;
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }

  if (opts.dryRun && opts.write) {
    throw new Error("Use either --dry-run or --write, not both.");
  }
  if (!opts.dryRun && !opts.write) {
    opts.dryRun = true;
  }

  return opts;
}

function loadOverrides() {
  if (!existsSync(OVERRIDES_PATH)) {
    return { files: {}, cards: {} };
  }
  const parsed = JSON.parse(readFileSync(OVERRIDES_PATH, "utf8"));
  return {
    files: parsed.files && typeof parsed.files === "object" ? parsed.files : {},
    cards: parsed.cards && typeof parsed.cards === "object" ? parsed.cards : {},
  };
}

function listResultManifests() {
  if (!existsSync(RESULTS_DIR)) {
    throw new Error(`Results directory not found: ${RESULTS_DIR}`);
  }

  return readdirSync(RESULTS_DIR)
    .filter((name) => name.endsWith(".json"))
    .sort()
    .map((jsonName) => {
      const stem = jsonName.slice(0, -5);
      return {
        jsonName,
        stem,
        jsonPath: join(RESULTS_DIR, jsonName),
        csvPath: join(RESULTS_DIR, `${stem}.csv`),
      };
    });
}

function matchesOnly(manifest, onlyValues, payload) {
  if (onlyValues.length === 0) return true;
  return onlyValues.some((value) => {
    const token = String(value);
    return (
      manifest.stem === token ||
      manifest.jsonName === token ||
      manifest.stem.startsWith(token) ||
      payload.card_id === Number(token) ||
      String(payload.card_id) === token
    );
  });
}

function getParamName(param) {
  const target = Array.isArray(param?.target) ? param.target : [];
  if (
    target.length > 1 &&
    Array.isArray(target[1]) &&
    target[1].length > 1 &&
    typeof target[1][1] === "string"
  ) {
    return target[1][1];
  }
  if (typeof param?.name === "string" && param.name.trim()) {
    return param.name.trim();
  }
  return null;
}

function isDateParam(param) {
  return typeof param?.type === "string" && param.type.startsWith("date");
}

function pickDateValue(name) {
  const lower = String(name || "").toLowerCase();
  if (lower.includes("start") || lower.includes("from")) {
    return START_DATE;
  }
  if (
    lower.includes("end") ||
    lower.includes("to") ||
    lower.includes("last") ||
    lower === "ed" ||
    lower.endsWith("_ed")
  ) {
    return END_DATE;
  }
  return null;
}

function cloneJson(value) {
  return JSON.parse(JSON.stringify(value));
}

function mergeOverrideMaps(base = {}, extra = {}) {
  return { ...base, ...extra };
}

function resolveOverrides(overrides, manifest, payload) {
  const byCard = overrides.cards[String(payload.card_id)] ?? {};
  const byStem = overrides.files[manifest.stem] ?? {};
  const byJsonName = overrides.files[manifest.jsonName] ?? {};

  return {
    params: mergeOverrideMaps(
      mergeOverrideMaps(byCard.params, byStem.params),
      byJsonName.params,
    ),
  };
}

function applyParamOverride(param, override, paramName) {
  if (!override || typeof override !== "object") return { keep: true, param };

  const action = override.action;
  if (action === "remove") {
    return { keep: false, note: `${paramName}: remove` };
  }
  if (action === "set") {
    if (!Object.prototype.hasOwnProperty.call(override, "value")) {
      throw new Error(`Override for ${paramName} is missing "value"`);
    }
    const next = cloneJson(param);
    next.value = cloneJson(override.value);
    return { keep: true, param: next, note: `${paramName}: set` };
  }
  if (action === "replace_empty_with_null") {
    const next = cloneJson(param);
    if (next.value === "") {
      next.value = null;
      return { keep: true, param: next, note: `${paramName}: empty->null` };
    }
    return { keep: true, param: next };
  }

  throw new Error(`Unsupported override action for ${paramName}: ${action}`);
}

function normalizeParameters(params, paramOverrides) {
  const nextParams = [];
  const notes = [];
  const seenNames = new Set();

  for (const original of Array.isArray(params) ? params : []) {
    let param = cloneJson(original);
    const name = getParamName(param);
    if (name) seenNames.add(name);

    if (isDateParam(param) && name) {
      const nextValue = pickDateValue(name);
      if (nextValue != null && param.value !== nextValue) {
        param.value = nextValue;
        notes.push(`${name}: date->${nextValue}`);
      }
    }

    const override = name ? paramOverrides[name] : null;
    const outcome = applyParamOverride(param, override, name ?? "<unnamed>");
    if (outcome.note) notes.push(outcome.note);
    if (outcome.keep) nextParams.push(outcome.param);
  }

  for (const [name, override] of Object.entries(paramOverrides ?? {})) {
    if (seenNames.has(name)) continue;
    if (!override || typeof override !== "object") continue;
    if (override.action !== "set" || !override.createIfMissing) continue;
    if (!Object.prototype.hasOwnProperty.call(override, "value")) {
      throw new Error(`Override for ${name} is missing "value"`);
    }

    const next = cloneJson(override.createIfMissing);
    next.value = cloneJson(override.value);
    nextParams.push(next);
    notes.push(`${name}: add`);
  }

  return { parameters: nextParams, notes };
}

function toCsvCell(value) {
  if (value == null) return "";
  const raw =
    typeof value === "string"
      ? value
      : typeof value === "number" || typeof value === "boolean"
        ? String(value)
        : JSON.stringify(value);
  return /[",\n\r]/.test(raw) ? `"${raw.replace(/"/g, '""')}"` : raw;
}

function buildCsv(queryResponse) {
  const data = queryResponse?.data;
  const cols = Array.isArray(data?.cols) ? data.cols : [];
  const rows = Array.isArray(data?.rows) ? data.rows : [];
  const header = cols.map((col) => col?.name ?? col?.display_name ?? "");
  const lines = [header.map(toCsvCell).join(",")];

  for (const row of rows) {
    const cells = Array.isArray(row) ? row : header.map((key) => row?.[key]);
    lines.push(cells.map(toCsvCell).join(","));
  }
  return `${lines.join("\n")}\n`;
}

function writeAtomic(filePath, text) {
  const tempPath = `${filePath}.tmp`;
  writeFileSync(tempPath, text, "utf8");
  renameSync(tempPath, filePath);
}

async function executeCardQuery(baseUrl, authHeaders, cardId, parameters) {
  const res = await fetch(`${baseUrl}/api/card/${encodeURIComponent(cardId)}/query`, {
    method: "POST",
    headers: jsonHeaders(authHeaders),
    body: JSON.stringify({
      ignore_cache: true,
      parameters,
    }),
  });

  const text = await res.text();
  if (!res.ok) {
    throw new Error(`Card ${cardId}: ${res.status} ${text.slice(0, 500)}`);
  }

  try {
    return JSON.parse(text);
  } catch (err) {
    throw new Error(`Card ${cardId}: could not parse query response JSON: ${err.message}`);
  }
}

function summarizeData(queryResponse) {
  const rows = Array.isArray(queryResponse?.data?.rows) ? queryResponse.data.rows.length : 0;
  const cols = Array.isArray(queryResponse?.data?.cols) ? queryResponse.data.cols.length : 0;
  return `${rows} rows x ${cols} cols`;
}

async function main() {
  loadEnvFile();
  const opts = parseArgs(process.argv.slice(2));
  const overrides = loadOverrides();
  const manifests = listResultManifests();

  const matched = manifests
    .map((manifest) => {
      const payload = JSON.parse(readFileSync(manifest.jsonPath, "utf8"));
      return { manifest, payload };
    })
    .filter(({ manifest, payload }) => matchesOnly(manifest, opts.only, payload));

  if (matched.length === 0) {
    throw new Error("No result files matched the requested filters.");
  }

  console.log(
    `[refresh-result-files] Mode: ${opts.write ? "write" : "dry-run"} | matched ${matched.length} result bundles`,
  );
  console.log(
    `[refresh-result-files] Date normalization: start/from -> ${START_DATE}, end/to/last/ed -> ${END_DATE}`,
  );

  if (opts.dryRun) {
    for (const { manifest, payload } of matched) {
      const resolved = resolveOverrides(overrides, manifest, payload);
      const { parameters, notes } = normalizeParameters(payload.parameters ?? [], resolved.params);
      const dateNames = parameters
        .filter((param) => isDateParam(param))
        .map((param) => `${getParamName(param)}=${param.value}`);
      console.log(`- ${manifest.jsonName} | card ${payload.card_id}`);
      console.log(`  date params: ${dateNames.length ? dateNames.join(", ") : "none"}`);
      console.log(`  overrides: ${notes.length ? notes.join("; ") : "none"}`);
    }
    return;
  }

  const baseUrl = (process.env.METABASE_SITE_URL || "https://metabase.curefit.co").replace(
    /\/$/,
    "",
  );
  const authHeaders = await makeAuthHeaders(baseUrl);

  let successCount = 0;
  const failures = [];

  for (const { manifest, payload } of matched) {
    const originalJsonText = readFileSync(manifest.jsonPath, "utf8");
    const originalCsvText = existsSync(manifest.csvPath) ? readFileSync(manifest.csvPath, "utf8") : null;

    try {
      const resolved = resolveOverrides(overrides, manifest, payload);
      const { parameters, notes } = normalizeParameters(payload.parameters ?? [], resolved.params);
      const queryResponse = await executeCardQuery(baseUrl, authHeaders, payload.card_id, parameters);
      const nextPayload = {
        card_id: payload.card_id,
        card_name: payload.card_name,
        parameters,
        query_response: queryResponse,
      };
      const csvText = buildCsv(queryResponse);

      writeAtomic(manifest.jsonPath, `${JSON.stringify(nextPayload, null, 2)}\n`);
      writeAtomic(manifest.csvPath, csvText);

      successCount += 1;
      console.log(
        `[refresh-result-files] Refreshed ${manifest.stem} | ${summarizeData(queryResponse)}${
          notes.length ? ` | ${notes.join("; ")}` : ""
        }`,
      );
    } catch (err) {
      writeAtomic(manifest.jsonPath, originalJsonText);
      if (originalCsvText == null) {
        rmSync(manifest.csvPath, { force: true });
      } else {
        writeAtomic(manifest.csvPath, originalCsvText);
      }
      failures.push({
        file: manifest.jsonName,
        cardId: payload.card_id,
        error: err instanceof Error ? err.message : String(err),
      });
      console.warn(
        `[refresh-result-files] Failed ${manifest.stem} | card ${payload.card_id} | ${
          err instanceof Error ? err.message : String(err)
        }`,
      );
    }
  }

  console.log(
    `[refresh-result-files] Completed: ${successCount} succeeded, ${failures.length} failed`,
  );
  if (failures.length > 0) {
    console.log("[refresh-result-files] Failures:");
    for (const failure of failures) {
      console.log(`  - ${failure.file} (card ${failure.cardId}): ${failure.error}`);
    }
    process.exitCode = 1;
  }
}

main().catch((err) => {
  console.error(err instanceof Error ? err.message : String(err));
  process.exit(1);
});

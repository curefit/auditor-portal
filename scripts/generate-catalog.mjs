#!/usr/bin/env node
/**
 * Builds auditor-portal/src/catalog.json and copies artifacts + docs into
 * auditor-portal/public/handoff/ for static serving.
 *
 * Optional (read-only, at build time — no execution):
 *   DBT_GITHUB_REPO=Owner/Dbt_datamodels
 *   DBT_GITHUB_REF=main
 *   GITHUB_TOKEN=...        (private repos)
 *   METABASE_SITE_URL=https://metabase.curefit.co
 *
 * Loads repo-root .env if present (simple KEY=value lines).
 */
import {
  cpSync,
  existsSync,
  mkdirSync,
  readdirSync,
  readFileSync,
  rmSync,
  statSync,
  writeFileSync,
} from "fs";
import { dirname, join, resolve } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, "..");
const PORTAL_ROOT = join(REPO_ROOT, "auditor-portal");
const PUBLIC_ROOT = join(PORTAL_ROOT, "public");
const PUBLIC_HANDOFF = join(PUBLIC_ROOT, "handoff");
const DBT_SQL_DIR = join(PUBLIC_ROOT, "dbt-sql");
const DBT_NOTEBOOKS_DIR = join(PUBLIC_ROOT, "dbt-notebooks");
const CATALOG_OUT = join(PORTAL_ROOT, "src", "catalog.json");
const ARTIFACTS = join(REPO_ROOT, "artifacts");
const DOCS = join(REPO_ROOT, "docs");
const MAPPING_CSV = join(ARTIFACTS, "dashboard_card_mapping.csv");
const ROOT_SUMMARY_CSV = join(ARTIFACTS, "root_asset_summary.csv");
const OP_METRICS_CSV = join(ARTIFACTS, "op_metrics_sheet.csv");
const LINEAGE_DIR = join(DOCS, "lineage");
const PREVIEWS = join(ARTIFACTS, "previews");
const QUERIES = join(ARTIFACTS, "queries");
const METADATA = join(ARTIFACTS, "metadata");
const RESULTS = join(ARTIFACTS, "results");
// Allow-list: these Metabase question IDs intentionally map to multiple DRHP rows in op_metrics_sheet.csv.
const DUPLICATE_SHEET_CARD_IDS = new Set(["84483", "84661"]);

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

function parseCsv(text) {
  const lines = text.trim().split(/\r?\n/);
  if (lines.length < 2) return [];
  const header = parseCsvLine(lines[0]);
  const rows = [];
  for (let i = 1; i < lines.length; i++) {
    const cols = parseCsvLine(lines[i]);
    const row = {};
    header.forEach((h, j) => {
      row[h] = cols[j] ?? "";
    });
    rows.push(row);
  }
  return rows;
}

function parseCsvLine(line) {
  const out = [];
  let cur = "";
  let inQuotes = false;
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (c === '"') {
      inQuotes = !inQuotes;
      continue;
    }
    if (c === "," && !inQuotes) {
      out.push(cur);
      cur = "";
      continue;
    }
    cur += c;
  }
  out.push(cur);
  return out;
}

/**
 * Parses a full CSV text into rows of cells, correctly handling:
 * - Quoted fields with embedded commas
 * - Multiline quoted fields (newlines inside quotes)
 * - Escaped double-quotes ("")
 */
function parseCsvRows(csvText) {
  const rows = [];
  let row = [];
  let cell = "";
  let inQ = false;

  for (let i = 0; i < csvText.length; i++) {
    const c = csvText[i];
    const next = csvText[i + 1];

    if (c === '"') {
      if (inQ && next === '"') {
        cell += '"';
        i++;
      } else {
        inQ = !inQ;
      }
    } else if (c === "," && !inQ) {
      row.push(cell);
      cell = "";
    } else if ((c === "\r" || c === "\n") && !inQ) {
      if (c === "\r" && next === "\n") i++;
      row.push(cell);
      rows.push(row);
      row = [];
      cell = "";
    } else {
      cell += c;
    }
  }
  if (cell || row.length > 0) {
    row.push(cell);
    rows.push(row);
  }
  return rows;
}

/**
 * Parses the DRHP op-metrics sheet CSV.
 * Returns one or more sheet metrics for every card ID whose Source column
 * contains at least one metabase.curefit.co/question/<id> link.
 *
 * CSV column layout (0-indexed):
 *   0: empty  1: Sl.No  2: Metric  3: Short def  4: Long def
 *   5: Status  6: Timeline  7: PoC  8: empty  9: Units
 *   10: FY23  11: FY24  12: FY25  13: FY26
 *   14: 9MFY25  15: 9MFY26  16: Source  17: Data limitations
 */
/**
 * Returns { cardMap, dashboardMap } where:
 * - cardMap: Map<questionCardId, sheetMetric[]> (matched via /question/<id>)
 * - dashboardMap: Map<dashboardId, sheetMetric> (matched via /dashboard/<id>)
 * sheetOrder is the 0-based position of the metric in the CSV (preserves DRHP list order).
 */
function parseOpMetricsSheet(csvText) {
  const cardMap = new Map();
  const dashboardMap = new Map();
  const rows = parseCsvRows(csvText);
  const QUESTION_RE = /metabase\.curefit\.co\/question\/(\d+)/g;
  const DASHBOARD_RE = /metabase\.curefit\.co\/dashboard\/(\d+)/g;

  let sheetOrder = 0;

  for (const cols of rows) {
    const source = (cols[16] ?? "").trim();
    if (!source.includes("metabase.curefit.co")) continue;

    const slNo = (cols[1] ?? "").trim();
    if (!slNo || isNaN(Number(slNo))) continue; // skip header / section rows

    const metric = {
      sheetOrder: sheetOrder++,
      slNo,
      metricName: (cols[2] ?? "").trim(),
      definition: ((cols[4] ?? "") || (cols[3] ?? "")).trim(),
      status: (cols[5] ?? "").trim(),
      poc: (cols[7] ?? "").trim(),
      units: (cols[9] ?? "").trim(),
      fy23: (cols[10] ?? "").trim(),
      fy24: (cols[11] ?? "").trim(),
      fy25: (cols[12] ?? "").trim(),
      fy26: (cols[13] ?? "").trim(),
      nineMFy25: (cols[14] ?? "").trim(),
      nineMFy26: (cols[15] ?? "").trim(),
      sourceRaw: source,
      limitations: (cols[17] ?? "").trim(),
    };

    let m;
    QUESTION_RE.lastIndex = 0;
    while ((m = QUESTION_RE.exec(source))) {
      const existing = cardMap.get(m[1]) ?? [];
      cardMap.set(m[1], [...existing, metric]);
    }
    DASHBOARD_RE.lastIndex = 0;
    while ((m = DASHBOARD_RE.exec(source))) {
      if (!dashboardMap.has(m[1])) dashboardMap.set(m[1], metric);
    }
  }
  return { cardMap, dashboardMap };
}

function listMatching(dir, pred) {
  if (!existsSync(dir)) return [];
  return readdirSync(dir).filter(pred);
}

function firstQueryFile(cardId) {
  const names = listMatching(
    QUERIES,
    (n) => n.startsWith(`${cardId}__`) && n.endsWith(".sql"),
  );
  return names[0] ?? null;
}

function firstMetadataFile(cardId) {
  const names = listMatching(
    METADATA,
    (n) => n.startsWith(`${cardId}__`) && n.endsWith(".json"),
  );
  return names[0] ?? null;
}

function entryKeyFor(cardId, sheetMetric) {
  return sheetMetric ? `card:${cardId}:drhp:${sheetMetric.sheetOrder}` : `card:${cardId}`;
}

function cardIdFromQueryFilename(name) {
  const m = /^(\d+)__/.exec(name);
  return m ? m[1] : null;
}

function buildCardToRootFromLineage() {
  const map = new Map();
  if (!existsSync(LINEAGE_DIR)) return map;
  const re = /- Card `(\d+)`/g;
  for (const f of readdirSync(LINEAGE_DIR)) {
    if (!f.endsWith(".md")) continue;
    const rootKey = f.replace(/\.md$/, "");
    const text = readFileSync(join(LINEAGE_DIR, f), "utf8");
    let m;
    while ((m = re.exec(text))) {
      const id = m[1];
      if (!map.has(id)) map.set(id, rootKey);
    }
  }
  return map;
}

function buildRootSourceUrlMap() {
  const map = new Map();
  if (!existsSync(ROOT_SUMMARY_CSV)) return map;
  const rows = parseCsv(readFileSync(ROOT_SUMMARY_CSV, "utf8"));
  for (const row of rows) {
    const type = String(row.asset_type ?? "").trim().toLowerCase();
    const id = String(row.root_asset_id ?? "").trim();
    const url = String(row.normalized_source_url ?? "").trim();
    if (!id || !url) continue;
    const key =
      type === "dashboard" ? `dashboard-${id}` : `question-${id}`;
    if (!map.has(key)) map.set(key, url);
  }
  return map;
}

function pickPreviewPair(rootKey, cardId) {
  const prefix = `${rootKey}__${cardId}__`;
  const all = listMatching(PREVIEWS, (n) => n.startsWith(prefix) && n.endsWith(".html"));
  const lineage = all.find((n) => n.endsWith("__lineage.html"));
  const output = all.find((n) => !n.endsWith("__lineage.html"));
  return { outputPreview: output ?? null, lineagePreview: lineage ?? null };
}

function resultFilesFor(cardId) {
  const hits = listMatching(
    RESULTS,
    (n) => n.includes(`__${cardId}__`) || n.startsWith(`${cardId}__`),
  );
  return hits.map((n) => `artifacts/results/${n}`);
}

function readCardNameFromMetadata(cardId) {
  const metaDir = listMatching(METADATA, (n) => n.startsWith(`${cardId}__`) && n.endsWith(".json"));
  if (!metaDir.length) return null;
  try {
    const raw = readFileSync(join(METADATA, metaDir[0]), "utf8");
    const j = JSON.parse(raw);
    return j.name ?? j.display_name ?? null;
  } catch {
    return null;
  }
}

function rel(p) {
  return p.replace(/^\//, "");
}

function stripSqlComments(sql) {
  return sql
    .replace(/\/\*[\s\S]*?\*\//g, " ")
    .replace(/--[^\n]*/g, " ");
}

/**
 * Extract warehouse-style identifiers (schema.table[.column]) from SQL for lineage hints.
 */
function extractSqlRelations(sql) {
  if (!sql) return [];
  const s = stripSqlComments(sql).replace(/[`"]/g, "");
  const found = new Set();

  const fromJoin = /\b(?:from|join)\s+([a-z0-9_.]+)/gi;
  let m;
  while ((m = fromJoin.exec(s))) {
    let chunk = m[1].trim();
    if (chunk.startsWith("(")) continue;
    for (const piece of chunk.split(/,\s*/)) {
      const token = piece.split(/\s+/)[0]?.trim().toLowerCase();
      if (token && token.includes(".") && !token.startsWith("(")) found.add(token);
    }
  }

  const warehouse = /\b((?:dwh|pk|stage|gs)_[a-z0-9_]*(?:\.[a-z][a-z0-9_]+)+)\b/gi;
  while ((m = warehouse.exec(s))) {
    found.add(m[1].toLowerCase());
  }

  return [...found].sort();
}

function githubBlobUrl(owner, repo, ref, filePath) {
  const enc = filePath
    .split("/")
    .map((seg) => encodeURIComponent(seg))
    .join("/");
  return `https://github.com/${owner}/${repo}/blob/${ref}/${enc}`;
}

function rawGithubUrl(owner, repo, ref, filePath) {
  const enc = filePath
    .split("/")
    .map((seg) => encodeURIComponent(seg))
    .join("/");
  return `https://raw.githubusercontent.com/${owner}/${repo}/${ref}/${enc}`;
}

function matchDbtModelsForRelation(
  relation,
  modelPaths,
  owner,
  repo,
  ref,
  fallbackPaths = [],
  fallbackOwner = "",
  fallbackRepo = "",
  fallbackRef = "",
) {
  if (!relation.includes(".")) {
    return {
      relation,
      dbtModelPaths: [],
      githubBlobUrls: [],
      rawGithubUrls: [],
      fallbackModelPaths: [],
      fallbackGithubBlobUrls: [],
      fallbackLocalUrls: [],
    };
  }
  const parts = relation.toLowerCase().split(".");
  const table = parts[parts.length - 1]?.replace(/-/g, "_") ?? relation;

  const EXCLUDED_SUFFIXES = ["_test", "_tmp", "_staging"];
  const EXCLUDED_SUBSTRINGS = ["delete_model"];

  const hits = [];
  for (const p of modelPaths) {
    const low = p.toLowerCase();
    const base = low.split("/").pop()?.replace(/\.sql$/i, "") ?? "";
    if (
      EXCLUDED_SUFFIXES.some((s) => base.endsWith(s)) ||
      EXCLUDED_SUBSTRINGS.some((s) => base.includes(s))
    )
      continue;
    if (base === table || base.endsWith(`_${table}`) || base.endsWith(`__${table}`)) {
      hits.push(p);
      if (hits.length >= 4) break;
    }
  }

  const fallbackHits = [];
  if (hits.length === 0 && fallbackPaths.length > 0) {
    const relationLow = relation.toLowerCase();
    for (const p of fallbackPaths) {
      const low = p.toLowerCase();
      const base = low.split("/").pop()?.replace(/\.ipynb$/i, "") ?? "";
      if (base === relationLow) {
        fallbackHits.push(p);
        break;
      }
    }
  }

  return {
    relation,
    dbtModelPaths: hits,
    githubBlobUrls: hits.map((path) => githubBlobUrl(owner, repo, ref, path)),
    localSqlUrls: hits.map((path) => `/dbt-sql/${path}`),
    fallbackModelPaths: fallbackHits,
    fallbackGithubBlobUrls: fallbackHits.map((path) =>
      githubBlobUrl(fallbackOwner, fallbackRepo, fallbackRef, path),
    ),
    fallbackLocalUrls: fallbackHits.map((path) => `/dbt-notebooks/${path}`),
  };
}

/**
 * Resolves the ref to use for a repo. If the specified ref exists, returns it.
 * Otherwise falls back to the repo's default branch (fetched from the API).
 * This avoids hard-coding master/main when repos may use either convention.
 */
async function resolveRef(owner, repo, ref, headers) {
  const branchRes = await fetch(
    `https://api.github.com/repos/${owner}/${repo}/branches/${encodeURIComponent(ref)}`,
    { headers },
  );
  if (branchRes.ok) return ref;

  // Branch not found — try the repo's default branch
  console.warn(
    `[generate-catalog] Branch "${ref}" not found on ${owner}/${repo}, falling back to repo default branch`,
  );
  const repoRes = await fetch(`https://api.github.com/repos/${owner}/${repo}`, { headers });
  if (!repoRes.ok) {
    const t = await repoRes.text();
    throw new Error(`GitHub branch ${ref}: ${branchRes.status} — repo lookup also failed: ${repoRes.status} ${t.slice(0, 200)}`);
  }
  const repoData = await repoRes.json();
  const defaultBranch = repoData.default_branch;
  console.log(`[generate-catalog] Using default branch "${defaultBranch}" for ${owner}/${repo}`);
  return defaultBranch;
}

/** Fetches .ipynb notebook paths from a fallback repo (e.g. cf-data-lab). */
async function fetchFallbackNotebookPaths(owner, repo, ref, token, modelsPath) {
  const headers = {
    Accept: "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28",
    "User-Agent": "curefit-auditor-catalog-generator",
  };
  if (token) headers.Authorization = `Bearer ${token}`;

  const resolvedRef = await resolveRef(owner, repo, ref, headers);

  const branchRes = await fetch(
    `https://api.github.com/repos/${owner}/${repo}/branches/${encodeURIComponent(resolvedRef)}`,
    { headers },
  );
  if (!branchRes.ok) {
    const t = await branchRes.text();
    throw new Error(`GitHub branch ${resolvedRef}: ${branchRes.status} ${t.slice(0, 200)}`);
  }
  const branch = await branchRes.json();
  const sha = branch.commit.sha;

  const treeRes = await fetch(
    `https://api.github.com/repos/${owner}/${repo}/git/trees/${sha}?recursive=1`,
    { headers },
  );
  if (!treeRes.ok) {
    const t = await treeRes.text();
    throw new Error(`GitHub tree: ${treeRes.status} ${t.slice(0, 200)}`);
  }
  const tree = await treeRes.json();
  const paths = [];
  const prefix = modelsPath.replace(/\/?$/, "/");
  for (const item of tree.tree ?? []) {
    if (item.type !== "blob" || !item.path) continue;
    const p = item.path;
    if (!p.toLowerCase().startsWith(prefix.toLowerCase())) continue;
    if (!p.toLowerCase().endsWith(".ipynb")) continue;
    paths.push(p);
  }
  return { paths: paths.sort(), resolvedRef };
}

/**
 * Downloads matched dbt SQL files to public/dbt-sql/ at build time, then
 * follows ref() calls transitively (BFS) so that deps-of-deps are also
 * available for the portal's inline dependency tree.
 */
async function downloadDbtSqlWithTransitiveDeps(owner, repo, ref, token, allModelPaths, seedPaths) {
  if (!seedPaths.size) return;
  rmSync(DBT_SQL_DIR, { recursive: true, force: true });

  const headers = { "User-Agent": "curefit-auditor-catalog-generator" };
  if (token) headers.Authorization = `Bearer ${token}`;

  // Build model-name → path lookup from the full model index.
  // Warn if two files share the same basename — the last one wins and the earlier
  // one will be silently ignored during BFS transitive expansion.
  const modelNameToPath = new Map();
  for (const p of allModelPaths) {
    const name = p.split("/").pop().replace(/\.sql$/i, "");
    if (modelNameToPath.has(name)) {
      console.warn(
        `[generate-catalog] Duplicate model basename "${name}": "${modelNameToPath.get(name)}" overwritten by "${p}"`,
      );
    }
    modelNameToPath.set(name, p);
  }

  const allPaths = new Set(seedPaths);
  const sqlCache = new Map(); // path → sql text (avoids re-fetching)
  let queue = [...seedPaths];

  while (queue.length > 0) {
    // Fetch all paths in the current wave in parallel
    await Promise.all(
      queue.map(async (p) => {
        if (sqlCache.has(p)) return;
        const encoded = p.split("/").map(encodeURIComponent).join("/");
        const url = `https://raw.githubusercontent.com/${owner}/${repo}/${ref}/${encoded}`;
        try {
          const res = await fetch(url, { headers });
          if (res.ok) sqlCache.set(p, await res.text());
        } catch {}
      }),
    );

    // Parse each fetched SQL for all dependency name mentions and queue any new deps.
    // Covers: ref(), source(), and raw FROM/JOIN schema.table where the table name
    // matches a known model (e.g. models referenced only via source() or raw SQL).
    const nextQueue = [];
    for (const p of queue) {
      const sql = sqlCache.get(p);
      if (!sql) continue;

      const candidateNames = new Set();

      // {{ ref('model') }} and {{ ref('package', 'model') }}
      for (const m of sql.matchAll(/\{\{\s*ref\s*\([^)]*['"]([\w]+)['"]\s*\)\s*\}\}/gi)) {
        candidateNames.add(m[1]);
      }
      // {{ source('schema', 'table') }} — table name may match a model
      for (const m of sql.matchAll(/\{\{\s*source\s*\(\s*['"][^'"]+['"]\s*,\s*['"]([\w]+)['"]\s*\)\s*\}\}/gi)) {
        candidateNames.add(m[1]);
      }
      // Raw FROM/JOIN schema.table — table name may match a model
      for (const m of sql.matchAll(/\b(?:FROM|JOIN)\s+[\w]+\.([\w_]+)/gi)) {
        candidateNames.add(m[1]);
      }

      for (const name of candidateNames) {
        const refPath = modelNameToPath.get(name);
        if (refPath && !allPaths.has(refPath)) {
          allPaths.add(refPath);
          nextQueue.push(refPath);
        }
      }
    }
    queue = nextQueue;
  }

  // Write everything to disk
  let ok = 0;
  let writeFail = 0;
  for (const [p, sql] of sqlCache) {
    try {
      const outPath = join(DBT_SQL_DIR, ...p.split("/"));
      mkdirSync(dirname(outPath), { recursive: true });
      writeFileSync(outPath, sql, "utf8");
      ok++;
    } catch {
      writeFail++;
    }
  }
  // Paths that were queued (via seed or BFS) but never made it into sqlCache = fetch failures
  const fetchFail = allPaths.size - sqlCache.size;

  const transitive = ok - seedPaths.size > 0 ? ` (${ok - seedPaths.size} transitive)` : "";
  const failMsg = fetchFail + writeFail > 0
    ? `, ${fetchFail} fetch-failed, ${writeFail} write-failed`
    : "";
  console.log(
    `[generate-catalog] Downloaded dbt SQL: ${ok} ok${transitive}${failMsg} → public/dbt-sql/`,
  );
}

async function downloadMatchedNotebookFiles(owner, repo, ref, token, paths) {
  if (!paths.size) return;
  rmSync(DBT_NOTEBOOKS_DIR, { recursive: true, force: true });

  const headers = { "User-Agent": "curefit-auditor-catalog-generator" };
  if (token) headers.Authorization = `Bearer ${token}`;

  let ok = 0;
  let fail = 0;
  for (const p of paths) {
    const encoded = p.split("/").map(encodeURIComponent).join("/");
    const url = `https://raw.githubusercontent.com/${owner}/${repo}/${ref}/${encoded}`;
    try {
      const res = await fetch(url, { headers });
      if (!res.ok) { fail++; continue; }
      const text = await res.text();
      const outPath = join(DBT_NOTEBOOKS_DIR, ...p.split("/"));
      mkdirSync(dirname(outPath), { recursive: true });
      writeFileSync(outPath, text, "utf8");
      ok++;
    } catch {
      fail++;
    }
  }
  console.log(
    `[generate-catalog] Downloaded notebooks: ${ok} ok, ${fail} failed → public/dbt-notebooks/`,
  );
}

async function fetchDbtModelSqlPaths(owner, repo, ref, token, modelsPath = "models") {
  const headers = {
    Accept: "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28",
    "User-Agent": "curefit-auditor-catalog-generator",
  };
  if (token) headers.Authorization = `Bearer ${token}`;

  const resolvedRef = await resolveRef(owner, repo, ref, headers);

  const branchRes = await fetch(
    `https://api.github.com/repos/${owner}/${repo}/branches/${encodeURIComponent(resolvedRef)}`,
    { headers },
  );
  if (!branchRes.ok) {
    const t = await branchRes.text();
    throw new Error(`GitHub branch ${resolvedRef}: ${branchRes.status} ${t.slice(0, 200)}`);
  }
  const branch = await branchRes.json();
  const sha = branch.commit.sha;

  const treeRes = await fetch(
    `https://api.github.com/repos/${owner}/${repo}/git/trees/${sha}?recursive=1`,
    { headers },
  );
  if (!treeRes.ok) {
    const t = await treeRes.text();
    throw new Error(`GitHub tree: ${treeRes.status} ${t.slice(0, 200)}`);
  }
  const tree = await treeRes.json();
  const paths = [];
  for (const item of tree.tree ?? []) {
    if (item.type !== "blob" || !item.path) continue;
    const p = item.path;
    const prefix = modelsPath.replace(/\/?$/, "/");
    if (!p.toLowerCase().startsWith(prefix.toLowerCase())) continue;
    if (!p.toLowerCase().endsWith(".sql")) continue;
    paths.push(p);
  }
  return { paths: paths.sort(), resolvedRef };
}

/** Vite warns if the app tree contains a path segment `#` (e.g. stray folder `auditor-portal/#`). */
function pruneStrayHashNamedDirUnderPortal() {
  const bad = join(PORTAL_ROOT, "#");
  if (!existsSync(bad)) return;
  let st;
  try {
    st = statSync(bad);
  } catch {
    return;
  }
  if (!st.isDirectory()) {
    console.warn(
      `[generate-catalog] "auditor-portal/#" exists as a file. Rename or remove it — Vite warns about '#' in paths.`,
    );
    return;
  }
  const children = readdirSync(bad);
  if (children.length === 0) {
    rmSync(bad);
    console.warn(
      `[generate-catalog] Removed empty directory auditor-portal/# (avoids Vite's '#' path warning).`,
    );
    return;
  }
  console.warn(
    `[generate-catalog] auditor-portal/# is not empty (${children.length} entries). Rename or move it — Vite warns about '#' in paths.`,
  );
}

function writeDbtArtifacts(dbt, modelPaths, fetchNote, fallbackDbt, fallbackPaths, fallbackFetchNote) {
  const cfg = {
    enabled: dbt !== null,
    owner: dbt?.owner,
    repo: dbt?.repo,
    ref: dbt?.ref,
    modelSqlFileCount: modelPaths.length,
    fetchNote,
    fallback: fallbackDbt
      ? {
          enabled: true,
          owner: fallbackDbt.owner,
          repo: fallbackDbt.repo,
          ref: fallbackDbt.ref,
          modelNotebookCount: fallbackPaths.length,
          fetchNote: fallbackFetchNote,
        }
      : { enabled: false, fetchNote: fallbackFetchNote },
  };
  mkdirSync(PUBLIC_ROOT, { recursive: true });
  writeFileSync(
    join(PUBLIC_ROOT, "dbt-config.json"),
    JSON.stringify(cfg, null, 2),
    "utf8",
  );
  writeFileSync(
    join(PUBLIC_ROOT, "dbt-models-index.json"),
    JSON.stringify({ paths: modelPaths }, null, 2),
    "utf8",
  );
  writeFileSync(
    join(PUBLIC_ROOT, "dbt-notebooks-index.json"),
    JSON.stringify({ paths: fallbackPaths }, null, 2),
    "utf8",
  );
}

/**
 * Accepts `owner/repo`, `https://github.com/owner/repo`, or `https://github.com/owner/repo.git`.
 * Returns { owner, repo } or null.
 */
function parseGithubRepoSlug(raw) {
  if (!raw) return null;
  let s = raw.trim().replace(/^["']|["']$/g, "");
  if (/^https?:\/\//i.test(s)) {
    try {
      const u = new URL(s);
      const host = u.hostname.replace(/^www\./i, "");
      if (!/^github\.com$/i.test(host)) return null;
      const parts = u.pathname.split("/").filter(Boolean);
      if (parts.length < 2) return null;
      const owner = parts[0];
      const repo = parts[1].replace(/\.git$/i, "");
      if (!owner || !repo) return null;
      return { owner, repo };
    } catch {
      return null;
    }
  }
  const parts = s.split("/").filter(Boolean);
  if (parts.length >= 2) {
    const owner = parts[0];
    const repo = parts[1].replace(/\.git$/i, "");
    if (!owner || !repo) return null;
    return { owner, repo };
  }
  return null;
}

async function main() {
  loadEnvFile();

  const metabaseOrigin = (
    process.env.METABASE_SITE_URL ?? "https://metabase.curefit.co"
  ).replace(/\/$/, "");
  const rootSourceUrls = buildRootSourceUrlMap();

  const repoSlug = process.env.DBT_GITHUB_REPO?.trim();
  const ref = process.env.DBT_GITHUB_REF?.trim() || "main";
  const token = process.env.GITHUB_TOKEN?.trim();
  const modelsPath = process.env.DBT_MODELS_PATH?.trim() || "models";

  const fallbackRepoSlug = process.env.FALLBACK_GITHUB_REPO?.trim();
  const fallbackRef = process.env.FALLBACK_GITHUB_REF?.trim() || "master";
  const fallbackModelsPath = process.env.FALLBACK_MODELS_PATH?.trim() || "nbs/pinaka_data_models";

  let modelPaths = [];
  let dbt = null;
  let dbtFetchNote;
  let resolvedDbtRef = ref;

  if (repoSlug) {
    const parsed = parseGithubRepoSlug(repoSlug);
    if (parsed) {
      const { owner, repo } = parsed;
      try {
        ({ paths: modelPaths, resolvedRef: resolvedDbtRef } = await fetchDbtModelSqlPaths(owner, repo, ref, token, modelsPath));
        dbt = { owner, repo, ref: resolvedDbtRef };
        console.log(
          `[generate-catalog] DBT models on GitHub: ${modelPaths.length} SQL files under ${modelsPath}/ (${owner}/${repo}@${resolvedDbtRef})`,
        );
      } catch (e) {
        dbtFetchNote = e instanceof Error ? e.message : String(e);
        console.warn(`[generate-catalog] DBT GitHub fetch failed: ${dbtFetchNote}`);
      }
    } else {
      dbtFetchNote =
        "DBT_GITHUB_REPO must be owner/repo or https://github.com/owner/repo (see .env.example)";
      console.warn(`[generate-catalog] ${dbtFetchNote}`);
    }
  } else {
    dbtFetchNote =
      "Set DBT_GITHUB_REPO (e.g. curefit/dbt-data-models or the repo HTTPS URL) in repo-root .env to index dbt SQL at build time (read-only).";
  }

  let fallbackPaths = [];
  let fallbackDbt = null;
  let fallbackFetchNote;
  let resolvedFallbackRef = fallbackRef;
  if (fallbackRepoSlug) {
    const parsed = parseGithubRepoSlug(fallbackRepoSlug);
    if (parsed) {
      const { owner, repo } = parsed;
      try {
        ({ paths: fallbackPaths, resolvedRef: resolvedFallbackRef } = await fetchFallbackNotebookPaths(owner, repo, fallbackRef, token, fallbackModelsPath));
        fallbackDbt = { owner, repo, ref: resolvedFallbackRef };
        console.log(
          `[generate-catalog] Fallback notebooks on GitHub: ${fallbackPaths.length} .ipynb files under ${fallbackModelsPath}/ (${owner}/${repo}@${resolvedFallbackRef})`,
        );
      } catch (e) {
        fallbackFetchNote = e instanceof Error ? e.message : String(e);
        console.warn(`[generate-catalog] Fallback GitHub fetch failed: ${fallbackFetchNote}`);
      }
    }
  }

  writeDbtArtifacts(dbt, modelPaths, dbtFetchNote, fallbackDbt, fallbackPaths, fallbackFetchNote);

  // Load DRHP op-metrics sheet for metric metadata + filtering
  let sheetCardMap = new Map();
  let sheetDashboardMap = new Map();
  if (existsSync(OP_METRICS_CSV)) {
    try {
      ({ cardMap: sheetCardMap, dashboardMap: sheetDashboardMap } = parseOpMetricsSheet(
        readFileSync(OP_METRICS_CSV, "utf8"),
      ));
      console.log(
        `[generate-catalog] Op-metrics sheet: ${sheetCardMap.size} question IDs, ${sheetDashboardMap.size} dashboard IDs mapped`,
      );
    } catch (e) {
      console.warn(`[generate-catalog] Could not parse op_metrics_sheet.csv: ${e.message}`);
    }
  }

  const cardToRootLineage = buildCardToRootFromLineage();
  const csvRows = existsSync(MAPPING_CSV)
    ? parseCsv(readFileSync(MAPPING_CSV, "utf8"))
    : [];
  const csvByCard = new Map();
  for (const row of csvRows) {
    const id = String(row.card_id ?? "").trim();
    if (!id) continue;
    csvByCard.set(id, row);
  }

  const queryFiles = listMatching(QUERIES, (n) => n.endsWith(".sql"));
  const cardIds = new Set();
  for (const q of queryFiles) {
    const id = cardIdFromQueryFilename(q);
    if (id) cardIds.add(id);
  }
  for (const id of csvByCard.keys()) cardIds.add(id);

  const entries = [];

  for (const cardId of cardIds) {
    const csv = csvByCard.get(cardId);
    let rootKey =
      csv?.root_key?.trim() ||
      cardToRootLineage.get(cardId) ||
      (existsSync(join(LINEAGE_DIR, `question-${cardId}.md`))
        ? `question-${cardId}`
        : null);

    if (!rootKey) {
      rootKey = `question-${cardId}`;
    }

    const queryFile = firstQueryFile(cardId);
    const metaFile = firstMetadataFile(cardId);

    const { outputPreview, lineagePreview } = pickPreviewPair(rootKey, cardId);

    const name =
      csv?.card_name?.trim() ||
      readCardNameFromMetadata(cardId) ||
      (queryFile
        ? queryFile
            .replace(/^\d+__/, "")
            .replace(/\.sql$/, "")
            .replace(/-/g, " ")
        : `Card ${cardId}`);

    let sqlText = "";
    if (queryFile) {
      try {
        sqlText = readFileSync(join(QUERIES, queryFile), "utf8");
      } catch {
        sqlText = "";
      }
    }
    const rels = extractSqlRelations(sqlText).filter((r) => r.includes("."));
    const sqlLineageRelations = rels.map((r) =>
      matchDbtModelsForRelation(
        r,
        modelPaths,
        dbt?.owner ?? "",
        dbt?.repo ?? "",
        dbt?.ref ?? ref,
        fallbackPaths,
        fallbackDbt?.owner ?? "",
        fallbackDbt?.repo ?? "",
        fallbackDbt?.ref ?? fallbackRef,
      ),
    );

    const baseEntry = {
      cardId,
      name,
      rootKey,
      rootAssetName: csv?.root_asset_name?.trim() || null,
      dashboardId: csv?.dashboard_id?.trim() || null,
      dashboardName: csv?.dashboard_name?.trim() || null,
      metabaseCardUrl: `${metabaseOrigin}/question/${cardId}`,
      metabaseRootSourceUrl: rootSourceUrls.get(rootKey) ?? null,
      paths: {
        query: queryFile ? rel(`artifacts/queries/${queryFile}`) : null,
        metadata: metaFile ? rel(`artifacts/metadata/${metaFile}`) : null,
        lineageMarkdown: existsSync(join(LINEAGE_DIR, `${rootKey}.md`))
          ? rel(`docs/lineage/${rootKey}.md`)
          : null,
        outputPreviewHtml: outputPreview ? rel(`artifacts/previews/${outputPreview}`) : null,
        lineagePreviewHtml: lineagePreview ? rel(`artifacts/previews/${lineagePreview}`) : null,
      },
      results: resultFilesFor(cardId),
      sqlLineageRelations,
    };

    const sheetCardMetrics = sheetCardMap.get(cardId);
    if (sheetCardMetrics?.length) {
      const metricsForCard = DUPLICATE_SHEET_CARD_IDS.has(cardId)
        ? sheetCardMetrics
        : [sheetCardMetrics[0]];
      const needsEntryKey = metricsForCard.length > 1;
      for (const sheetMetric of metricsForCard) {
        const entry = {
          ...baseEntry,
          sheetMetric,
          sheetMetricVia: "card",
        };
        if (needsEntryKey) entry.entryKey = entryKeyFor(cardId, sheetMetric);
        entries.push(entry);
      }
    } else if (sheetDashboardMap.has(csv?.dashboard_id?.trim())) {
      const sheetMetric = sheetDashboardMap.get(csv.dashboard_id.trim());
      entries.push({
        ...baseEntry,
        sheetMetric,
        sheetMetricVia: "dashboard",
      });
    } else {
      entries.push({
        ...baseEntry,
        sheetMetric: null,
        sheetMetricVia: null,
      });
    }
  }

  entries.sort((a, b) => a.name.localeCompare(b.name, undefined, { sensitivity: "base" }));

  // Collect unique matched dbt model paths and download them for static serving
  if (dbt && token) {
    const uniquePaths = new Set();
    for (const entry of entries) {
      for (const rel of entry.sqlLineageRelations ?? []) {
        for (const p of rel.dbtModelPaths) uniquePaths.add(p);
      }
    }
    await downloadDbtSqlWithTransitiveDeps(dbt.owner, dbt.repo, dbt.ref, token, modelPaths, uniquePaths);
  } else if (dbt && !token) {
    console.log(
      "[generate-catalog] Skipping dbt SQL download (no GITHUB_TOKEN). Add GITHUB_TOKEN to .env to enable inline SQL viewing.",
    );
  }

  // Download matched fallback notebooks for static serving
  if (fallbackDbt && token) {
    const uniqueNotebookPaths = new Set();
    for (const entry of entries) {
      for (const rel of entry.sqlLineageRelations ?? []) {
        for (const p of rel.fallbackModelPaths) uniqueNotebookPaths.add(p);
      }
    }
    if (uniqueNotebookPaths.size > 0) {
      await downloadMatchedNotebookFiles(
        fallbackDbt.owner,
        fallbackDbt.repo,
        fallbackDbt.ref,
        token,
        uniqueNotebookPaths,
      );
    }
  }

  const catalog = {
    generatedAt: new Date().toISOString(),
    basePath: "/handoff/",
    count: entries.length,
    entries,
    dbt: {
      enabled: Boolean(dbt && modelPaths.length),
      owner: dbt?.owner ?? "",
      repo: dbt?.repo ?? "",
      ref: dbt?.ref ?? ref,
      modelSqlFileCount: modelPaths.length,
      ...(dbtFetchNote ? { fetchNote: dbtFetchNote } : {}),
    },
  };

  mkdirSync(join(PORTAL_ROOT, "src"), { recursive: true });
  writeFileSync(CATALOG_OUT, JSON.stringify(catalog, null, 2), "utf8");

  rmSync(PUBLIC_HANDOFF, { recursive: true, force: true });
  mkdirSync(PUBLIC_HANDOFF, { recursive: true });
  cpSync(ARTIFACTS, join(PUBLIC_HANDOFF, "artifacts"), { recursive: true });
  cpSync(DOCS, join(PUBLIC_HANDOFF, "docs"), { recursive: true });

  console.log(`Wrote ${CATALOG_OUT} (${entries.length} metrics)`);
  console.log(`Copied artifacts + docs -> ${PUBLIC_HANDOFF}`);

  pruneStrayHashNamedDirUnderPortal();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});

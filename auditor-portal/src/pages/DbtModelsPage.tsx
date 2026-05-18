import { useCallback, useEffect, useMemo, useState } from "react";
import { Modal } from "../components/Modal";
import type { Catalog, DbtConfigFile, DbtModelsIndexFile } from "../types";
import rawCatalog from "../catalog.json";

const catalog = rawCatalog as Catalog;

const usedModelPaths = new Set<string>(
  catalog.entries.flatMap((e) =>
    (e.sqlLineageRelations ?? []).flatMap((r) => r.dbtModelPaths ?? []),
  ),
);

const usedNotebookPaths = new Set<string>(
  catalog.entries.flatMap((e) =>
    (e.sqlLineageRelations ?? []).flatMap((r) => r.fallbackModelPaths ?? []),
  ),
);

function blobGithubUrl(owner: string, repo: string, ref: string, path: string) {
  return `https://github.com/${owner}/${repo}/blob/${ref}/${path
    .split("/")
    .map((s) => encodeURIComponent(s))
    .join("/")}`;
}

// ─── Dependency parsing ────────────────────────────────────────────────────

type ParsedDeps = {
  refs: string[];
  sources: Array<{ schema: string; table: string }>;
  /** Raw FROM/JOIN schema.table refs extracted from non-dbt SQL (ClickHouse, Spark SQL) */
  rawTableRefs: Array<{ schema: string; table: string }>;
  path: string;
};

function parseDeps(sql: string, path: string): ParsedDeps {
  const refs = [...sql.matchAll(/\{\{\s*ref\s*\(\s*['"]([\w]+)['"]\s*\)\s*\}\}/g)].map(
    (m) => m[1],
  );
  const sources = [
    ...sql.matchAll(
      /\{\{\s*source\s*\(\s*['"]([^'"]+)['"]\s*,\s*['"]([\w]+)['"]\s*\)\s*\}\}/g,
    ),
  ].map((m) => ({ schema: m[1], table: m[2] }));

  // Always extract raw FROM/JOIN schema.table refs in addition to dbt ref()/source() calls.
  // This catches cross-db joins and ClickHouse models that bypass dbt macros entirely.
  // CTE names are excluded so they don't appear as false dependencies.
  const cteNames = new Set(
    [...sql.matchAll(/(?:WITH|,)\s+([\w]+)\s+AS\s*\(/g)].map((m) => m[1].toLowerCase()),
  );
  const rawTableRefs: Array<{ schema: string; table: string }> = [];
  const rawMatches = [
    ...sql.matchAll(/\bFROM\s+([\w]+)\.([\w_]+)/g),
    ...sql.matchAll(/\bJOIN\s+([\w]+)\.([\w_]+)/g),
  ];
  for (const m of rawMatches) {
    const schema = m[1];
    const table = m[2];
    if (!cteNames.has(table.toLowerCase()) && !cteNames.has(schema.toLowerCase())) {
      rawTableRefs.push({ schema, table });
    }
  }

  const dedupe = <T extends object>(arr: T[], key: (x: T) => string) =>
    arr.filter((v, i, a) => a.findIndex((x) => key(x) === key(v)) === i);

  return {
    refs: [...new Set(refs)],
    sources: dedupe(sources, (s) => `${s.schema}.${s.table}`),
    rawTableRefs: dedupe(rawTableRefs, (s) => `${s.schema}.${s.table}`),
    path,
  };
}

// Python module names to skip when extracting FROM/JOIN from notebook cells
const PYTHON_MODULES = new Set([
  "cfdatalab", "pandas", "numpy", "pyspark", "scipy", "sklearn", "matplotlib",
  "seaborn", "os", "sys", "re", "io", "json", "math", "time", "datetime",
  "typing", "collections", "functools", "itertools", "pathlib", "logging",
  "subprocess", "shutil", "glob", "dbutils", "spark", "sc", "sqlalchemy",
]);

function parseNotebookDeps(notebookJson: string, path: string): ParsedDeps {
  let cells: Array<{ cell_type: string; source: string | string[] }> = [];
  try {
    const nb = JSON.parse(notebookJson) as {
      cells?: Array<{ cell_type: string; source: string | string[] }>;
    };
    cells = nb.cells ?? [];
  } catch {
    return { refs: [], sources: [], rawTableRefs: [], path };
  }

  const fullText = cells
    .filter((c) => c.cell_type === "code")
    .map((c) => (Array.isArray(c.source) ? c.source.join("") : String(c.source ?? "")))
    .join("\n");

  const rawMatches = [
    ...fullText.matchAll(/\bFROM\s+([\w]+)\.([\w_]+)/g),
    ...fullText.matchAll(/\bJOIN\s+([\w]+)\.([\w_]+)/g),
  ];
  const rawTableRefs: Array<{ schema: string; table: string }> = [];
  for (const m of rawMatches) {
    const schema = m[1];
    const table = m[2];
    if (!PYTHON_MODULES.has(schema.toLowerCase())) {
      rawTableRefs.push({ schema, table });
    }
  }

  const dedupe = <T extends object>(arr: T[], key: (x: T) => string) =>
    arr.filter((v, i, a) => a.findIndex((x) => key(x) === key(v)) === i);

  return {
    refs: [],
    sources: [],
    rawTableRefs: dedupe(rawTableRefs, (s) => `${s.schema}.${s.table}`),
    path,
  };
}

// ─── Recursive deps tree ───────────────────────────────────────────────────

function DepsTree({
  modelName,
  depsMap,
  knownModelNames,
  modelNameToPath,
  fetchModel,
  cfg,
  onOpenSql,
  ancestors = new Set<string>(),
  showSelf = true,
}: {
  modelName: string;
  depsMap: Map<string, ParsedDeps>;
  knownModelNames: Set<string>;
  modelNameToPath: Map<string, string>;
  fetchModel: (name: string) => Promise<boolean>;
  cfg: DbtConfigFile;
  onOpenSql: (path: string) => void;
  ancestors?: Set<string>;
  showSelf?: boolean;
}) {
  const [expanded, setExpanded] = useState(false);
  const [fetchState, setFetchState] = useState<"idle" | "loading" | "missing">("idle");

  const deps = depsMap.get(modelName);
  const isCycle = ancestors.has(modelName);
  const newAncestors = new Set([...ancestors, modelName]);

  const refDeps = deps?.refs ?? [];
  const dbtSourceDeps = deps?.sources.filter((s) => knownModelNames.has(s.table)) ?? [];
  const rawSourceDeps = deps?.sources.filter((s) => !knownModelNames.has(s.table)) ?? [];
  const rawTableRefs = deps?.rawTableRefs ?? [];
  const totalChildren =
    refDeps.length + dbtSourceDeps.length + rawSourceDeps.length + rawTableRefs.length;

  const canFetch = !deps && modelNameToPath.has(modelName) && fetchState !== "missing";

  async function handleToggle() {
    const opening = !expanded;
    setExpanded((e) => !e);
    if (opening && !deps && fetchState === "idle" && modelNameToPath.has(modelName)) {
      setFetchState("loading");
      const ok = await fetchModel(modelName);
      setFetchState(ok ? "idle" : "missing");
    }
  }

  const childrenBlock = (
    <div className={showSelf ? "ml-5 border-l border-zinc-800/60 pl-3 pt-0.5" : ""}>
      {refDeps.map((ref) => (
        <DepsTree
          key={`ref-${ref}`}
          modelName={ref}
          depsMap={depsMap}
          knownModelNames={knownModelNames}
          modelNameToPath={modelNameToPath}
          fetchModel={fetchModel}
          cfg={cfg}
          onOpenSql={onOpenSql}
          ancestors={newAncestors}
          showSelf
        />
      ))}
      {dbtSourceDeps.map((s) => (
        <DepsTree
          key={`srcmodel-${s.schema}-${s.table}`}
          modelName={s.table}
          depsMap={depsMap}
          knownModelNames={knownModelNames}
          modelNameToPath={modelNameToPath}
          fetchModel={fetchModel}
          cfg={cfg}
          onOpenSql={onOpenSql}
          ancestors={newAncestors}
          showSelf
        />
      ))}
      {rawSourceDeps.map((s) => (
        <RawTableRow key={`rawsrc-${s.schema}-${s.table}`} schema={s.schema} table={s.table} />
      ))}
      {rawTableRefs.map((s) => (
        <RawTableRow key={`raw-${s.schema}-${s.table}`} schema={s.schema} table={s.table} />
      ))}
      {totalChildren === 0 && (
        <p className="py-0.5 text-xs text-zinc-700">No dependencies found in SQL.</p>
      )}
    </div>
  );

  if (showSelf && isCycle) {
    return (
      <div className="flex items-center gap-2 py-0.5 text-xs text-amber-600/70">
        <span className="w-5 text-center">↻</span>
        <span className="font-mono">{modelName}</span>
        <span className="text-zinc-700">(cycle)</span>
      </div>
    );
  }

  if (!showSelf) return <>{childrenBlock}</>;

  // Model not in our depsMap
  if (!deps) {
    const showArrow = canFetch || fetchState === "loading";
    return (
      <div>
        <div className="flex flex-wrap items-center gap-x-2 gap-y-0.5 py-0.5 text-xs">
          {showArrow ? (
            <button
              type="button"
              onClick={handleToggle}
              className="flex h-5 w-5 items-center justify-center rounded bg-zinc-800 text-zinc-400 hover:bg-zinc-700 hover:text-white"
            >
              {fetchState === "loading" ? "…" : expanded ? "▾" : "▸"}
            </button>
          ) : (
            <span className="flex h-5 w-5 items-center justify-center text-zinc-700">◦</span>
          )}
          <span className="font-mono text-zinc-400">{modelName}</span>
          <span className="text-zinc-600">dbt model</span>
          {fetchState === "missing" && (
            <span className="text-zinc-700">(SQL not available locally)</span>
          )}
        </div>
        {expanded && fetchState === "loading" && (
          <div className="ml-5 pl-3 text-xs text-zinc-600">Loading…</div>
        )}
      </div>
    );
  }

  return (
    <div>
      <div className="flex flex-wrap items-center gap-x-2 gap-y-0.5 py-0.5 text-xs">
        <button
          type="button"
          onClick={handleToggle}
          className={`flex h-5 w-5 items-center justify-center rounded bg-zinc-800 text-zinc-400 hover:bg-zinc-700 hover:text-white ${
            totalChildren === 0 ? "invisible" : ""
          }`}
        >
          {expanded ? "▾" : "▸"}
        </button>
        <span className="font-mono text-sm font-medium text-emerald-400">{modelName}</span>
        <span className="rounded bg-emerald-950/50 px-1 py-0.5 text-zinc-500">dbt model</span>
        <button
          type="button"
          onClick={() => onOpenSql(deps.path)}
          className="text-zinc-600 underline hover:text-emerald-400"
        >
          View SQL
        </button>
        {cfg.owner && cfg.repo && (
          <a
            href={blobGithubUrl(cfg.owner, cfg.repo, cfg.ref ?? "master", deps.path)}
            target="_blank"
            rel="noreferrer"
            className="text-zinc-600 hover:text-zinc-300"
          >
            GitHub ↗
          </a>
        )}
      </div>
      {expanded && childrenBlock}
    </div>
  );
}

function RawTableRow({ schema, table }: { schema: string; table: string }) {
  return (
    <div className="flex items-center gap-2 py-0.5 text-xs">
      <span className="flex h-5 w-5 items-center justify-center text-zinc-700">—</span>
      <span className="font-mono text-zinc-400">{table}</span>
      <span className="rounded bg-zinc-800/50 px-1 py-0.5 text-zinc-600">{schema}</span>
    </div>
  );
}

// ─── Notebook viewer ────────────────────────────────────────────────────────

type NotebookCell = { cell_type: string; source: string[] };

function NotebookView({ body }: { body: string }) {
  const cells = useMemo<NotebookCell[]>(() => {
    try {
      const nb = JSON.parse(body) as { cells?: NotebookCell[] };
      return nb.cells ?? [];
    } catch {
      return [];
    }
  }, [body]);

  if (cells.length === 0) {
    return (
      <pre className="max-h-[70vh] overflow-auto whitespace-pre-wrap font-mono text-xs leading-relaxed text-zinc-200">
        {body}
      </pre>
    );
  }

  return (
    <div className="max-h-[70vh] space-y-3 overflow-y-auto">
      {cells.map((cell, i) => {
        const src = Array.isArray(cell.source)
          ? cell.source.join("")
          : String(cell.source ?? "");
        if (!src.trim()) return null;
        return (
          <div
            key={i}
            className={`rounded-lg border text-sm ${
              cell.cell_type === "code"
                ? "border-zinc-700 bg-zinc-950"
                : "border-zinc-800 bg-zinc-900/50"
            }`}
          >
            <div
              className={`border-b px-3 py-1 text-xs font-semibold uppercase tracking-wider ${
                cell.cell_type === "code"
                  ? "border-zinc-700 text-sky-400/70"
                  : "border-zinc-800 text-zinc-500"
              }`}
            >
              {cell.cell_type === "code" ? `Code [${i + 1}]` : "Markdown"}
            </div>
            <pre className="overflow-x-auto whitespace-pre-wrap p-3 font-mono text-xs leading-relaxed text-zinc-200">
              {src}
            </pre>
          </div>
        );
      })}
    </div>
  );
}

// ─── Page ──────────────────────────────────────────────────────────────────

export default function DbtModelsPage() {
  const [cfg, setCfg] = useState<DbtConfigFile | null>(null);
  const [index, setIndex] = useState<DbtModelsIndexFile | null>(null);
  const [notebookIndex, setNotebookIndex] = useState<DbtModelsIndexFile | null>(null);
  const [loadErr, setLoadErr] = useState<string | null>(null);
  const [q, setQ] = useState("");
  const [openPath, setOpenPath] = useState<{ path: string; kind: "sql" | "notebook" } | null>(
    null,
  );
  const [source, setSource] = useState<string | null>(null);
  const [srcErr, setSrcErr] = useState<string | null>(null);

  const [sqlCache, setSqlCache] = useState<Record<string, string>>({});
  const [notebookCache, setNotebookCache] = useState<Record<string, string>>({});
  const [expandedPaths, setExpandedPaths] = useState<Set<string>>(new Set());

  useEffect(() => {
    const base = import.meta.env.BASE_URL;
    Promise.all([
      fetch(`${base}dbt-config.json`).then((r) => r.json()),
      fetch(`${base}dbt-models-index.json`).then((r) => r.json()),
      fetch(`${base}dbt-notebooks-index.json`)
        .then((r) => (r.ok ? r.json() : { paths: [] }))
        .catch(() => ({ paths: [] })),
    ])
      .then(([c, i, ni]) => {
        setCfg(c as DbtConfigFile);
        setIndex(i as DbtModelsIndexFile);
        setNotebookIndex(ni as DbtModelsIndexFile);
      })
      .catch((e: Error) => setLoadErr(e.message));
  }, []);

  const usedSqlPaths = useMemo(
    () => (index?.paths ?? []).filter((p) => usedModelPaths.has(p)),
    [index],
  );

  const usedNbPaths = useMemo(
    () => (notebookIndex?.paths ?? []).filter((p) => usedNotebookPaths.has(p)),
    [notebookIndex],
  );

  // Full model name → path map (all 299+ models, not just the 31 we pre-fetch)
  const modelNameToPath = useMemo(() => {
    const map = new Map<string, string>();
    for (const p of index?.paths ?? []) {
      const name = p.split("/").pop()!.replace(".sql", "");
      map.set(name, p);
    }
    return map;
  }, [index]);

  // Pre-fetch all used SQL files to power the deps tree
  useEffect(() => {
    if (!usedSqlPaths.length) return;
    const base = import.meta.env.BASE_URL;
    for (const path of usedSqlPaths) {
      fetch(`${base}dbt-sql/${path}`)
        .then((r) => (r.ok ? r.text() : null))
        .then((text) => {
          if (text) setSqlCache((prev) => ({ ...prev, [path]: text }));
        })
        .catch(() => {});
    }
  }, [usedSqlPaths]);

  // Pre-fetch all used notebook files to power their deps view
  useEffect(() => {
    if (!usedNbPaths.length) return;
    const base = import.meta.env.BASE_URL;
    for (const path of usedNbPaths) {
      fetch(`${base}dbt-notebooks/${path}`)
        .then((r) => (r.ok ? r.text() : null))
        .then((text) => {
          if (text) setNotebookCache((prev) => ({ ...prev, [path]: text }));
        })
        .catch(() => {});
    }
  }, [usedNbPaths]);

  const depsMap = useMemo(() => {
    const map = new Map<string, ParsedDeps>();
    for (const [path, sql] of Object.entries(sqlCache)) {
      const name = path.split("/").pop()!.replace(".sql", "");
      map.set(name, parseDeps(sql, path));
    }
    return map;
  }, [sqlCache]);

  const notebookDepsMap = useMemo(() => {
    const map = new Map<string, ParsedDeps>();
    for (const [path, json] of Object.entries(notebookCache)) {
      const name = path.split("/").pop()!.replace(".ipynb", "");
      map.set(name, parseNotebookDeps(json, path));
    }
    return map;
  }, [notebookCache]);

  const knownModelNames = useMemo(() => new Set(depsMap.keys()), [depsMap]);

  // Lazy-fetch a dep model's SQL on demand (for nodes not in the pre-fetched set)
  const fetchModel = useCallback(
    async (modelName: string): Promise<boolean> => {
      const path = modelNameToPath.get(modelName);
      if (!path) return false;
      try {
        const base = import.meta.env.BASE_URL;
        const res = await fetch(`${base}dbt-sql/${path}`);
        if (!res.ok) return false;
        // Vite dev server returns index.html (text/html, status 200) for missing
        // static files. Reject those so we don't parse HTML as SQL.
        const contentType = res.headers.get("content-type") ?? "";
        if (contentType.includes("text/html")) return false;
        const text = await res.text();
        setSqlCache((prev) => ({ ...prev, [path]: text }));
        return true;
      } catch {
        return false;
      }
    },
    [modelNameToPath],
  );

  const filteredSql = useMemo(() => {
    const qq = q.trim().toLowerCase();
    return qq ? usedSqlPaths.filter((p) => p.toLowerCase().includes(qq)) : usedSqlPaths;
  }, [usedSqlPaths, q]);

  const filteredNb = useMemo(() => {
    const qq = q.trim().toLowerCase();
    return qq ? usedNbPaths.filter((p) => p.toLowerCase().includes(qq)) : usedNbPaths;
  }, [usedNbPaths, q]);

  useEffect(() => {
    if (!openPath) return;
    setSrcErr(null);
    setSource(null);
    const base = import.meta.env.BASE_URL;
    const url =
      openPath.kind === "sql"
        ? `${base}dbt-sql/${openPath.path}`
        : `${base}dbt-notebooks/${openPath.path}`;
    fetch(url)
      .then((res) => {
        if (!res.ok) throw new Error(`${res.status} — run npm run generate to download files`);
        return res.text();
      })
      .then(setSource)
      .catch((e: Error) => setSrcErr(e.message));
  }, [openPath]);

  if (loadErr) {
    return <div className="p-8 text-sm text-amber-400">Could not load model index: {loadErr}</div>;
  }
  if (!cfg || !index) {
    return <div className="p-8 text-sm text-zinc-500">Loading…</div>;
  }

  const sqlEnabled = cfg.enabled && cfg.owner && cfg.repo;
  const nbEnabled = cfg.fallback?.enabled && cfg.fallback.owner && cfg.fallback.repo;

  function openFile(path: string, kind: "sql" | "notebook") {
    setOpenPath({ path, kind });
    setSource(null);
    setSrcErr(null);
  }

  function toggleExpanded(path: string) {
    setExpandedPaths((prev) => {
      const next = new Set(prev);
      if (next.has(path)) next.delete(path);
      else next.add(path);
      return next;
    });
  }

  const openFileGithubUrl = (() => {
    if (!openPath) return null;
    if (openPath.kind === "sql" && cfg.owner && cfg.repo) {
      return blobGithubUrl(cfg.owner, cfg.repo, cfg.ref ?? "master", openPath.path);
    }
    if (openPath.kind === "notebook" && cfg.fallback?.owner && cfg.fallback.repo) {
      return blobGithubUrl(
        cfg.fallback.owner,
        cfg.fallback.repo,
        cfg.fallback.ref ?? "master",
        openPath.path,
      );
    }
    return null;
  })();

  const depTreeProps = {
    depsMap,
    knownModelNames,
    modelNameToPath,
    fetchModel,
    cfg,
    onOpenSql: (path: string) => openFile(path, "sql"),
  };

  return (
    <div className="flex h-full min-h-0 w-full flex-col overflow-hidden">
      <header className="border-b border-zinc-800 px-6 py-6">
        <h1 className="text-2xl font-bold text-white">Model Source Code</h1>
        <p className="mt-2 max-w-3xl text-sm text-zinc-400">
          dbt SQL models and cf-data-lab notebooks matched to the metrics in this handoff. Click a
          file to view its SQL, or use the Dependencies button to explore its source tables.
        </p>
        <div className="mt-3 flex flex-wrap gap-6 text-xs text-zinc-500">
          {sqlEnabled && (
            <span>
              <span className="font-medium text-emerald-400">{usedSqlPaths.length} SQL models</span>
              {" "}from {cfg.owner}/{cfg.repo} @ {cfg.ref}
            </span>
          )}
          {nbEnabled && (
            <span>
              <span className="font-medium text-amber-400">{usedNbPaths.length} notebooks</span>
              {" "}from {cfg.fallback!.owner}/{cfg.fallback!.repo} @ {cfg.fallback!.ref}
            </span>
          )}
        </div>
        {!sqlEnabled && !nbEnabled && (
          <p className="mt-3 rounded-lg border border-amber-900/60 bg-amber-950/40 p-3 text-sm text-amber-200">
            {cfg.hint ?? cfg.fetchNote ?? "Configure DBT_GITHUB_REPO in .env and run npm run generate."}
          </p>
        )}
      </header>

      <div className="px-6 py-4">
        <label className="flex max-w-xl flex-col gap-1.5 text-xs text-zinc-500">
          Filter
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="e.g. membership_dim, booking_fact, dim_date…"
            className="rounded-lg border border-zinc-700 bg-zinc-950 px-3 py-2 text-sm text-white placeholder:text-zinc-600 focus:border-emerald-600 focus:outline-none focus:ring-1 focus:ring-emerald-600"
          />
        </label>
      </div>

      <div className="min-h-0 flex-1 overflow-y-auto px-6 pb-8">
        {sqlEnabled && filteredSql.length > 0 && (
          <section className="mb-6">
            <h2 className="mb-3 flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-zinc-500">
              <span className="h-2 w-2 rounded-full bg-emerald-400" />
              dbt SQL models
              <span className="font-normal text-zinc-600">({cfg.owner}/{cfg.repo})</span>
            </h2>
            <ul className="divide-y divide-zinc-800/60">
              {filteredSql.map((p) => {
                const filename = p.split("/").pop() ?? p;
                const modelName = filename.replace(".sql", "");
                const dir = p.split("/").slice(0, -1).join("/");
                const isExpanded = expandedPaths.has(p);
                const deps = depsMap.get(modelName);
                const hasDeps =
                  deps &&
                  (deps.refs.length +
                    deps.sources.length +
                    deps.rawTableRefs.length) > 0;

                return (
                  <li key={p} className="py-3">
                    <div className="flex flex-wrap items-center gap-x-3 gap-y-1.5">
                      <button
                        type="button"
                        onClick={() => openFile(p, "sql")}
                        className="font-mono text-sm font-medium text-emerald-400 hover:underline"
                      >
                        {filename}
                      </button>
                      <a
                        href={blobGithubUrl(cfg.owner!, cfg.repo!, cfg.ref ?? "master", p)}
                        target="_blank"
                        rel="noreferrer"
                        className="flex items-center gap-1 rounded border border-zinc-700 px-2 py-0.5 text-xs text-zinc-400 hover:border-zinc-500 hover:text-zinc-200"
                      >
                        GitHub ↗
                      </a>
                      <button
                        type="button"
                        onClick={() => toggleExpanded(p)}
                        className={`flex items-center gap-1.5 rounded border px-2.5 py-1 text-xs font-medium transition-colors ${
                          isExpanded
                            ? "border-emerald-800 bg-emerald-950/60 text-emerald-400"
                            : "border-zinc-700 bg-zinc-900 text-zinc-400 hover:border-zinc-500 hover:text-zinc-200"
                        }`}
                      >
                        {isExpanded ? "▾" : "▸"} Dependencies
                        {hasDeps && !isExpanded && (
                          <span className="rounded-full bg-zinc-700 px-1.5 py-0.5 text-zinc-400">
                            {deps.refs.length + deps.sources.length + deps.rawTableRefs.length}
                          </span>
                        )}
                      </button>
                    </div>
                    <p className="mt-1 font-mono text-xs text-zinc-600">{dir}/</p>

                    {isExpanded && (
                      <div className="mt-2 rounded-lg border border-zinc-800 bg-zinc-950/60 px-4 py-3">
                        <p className="mb-2 text-xs font-semibold uppercase tracking-wider text-zinc-600">
                          Dependencies
                        </p>
                        {deps ? (
                          <DepsTree
                            modelName={modelName}
                            showSelf={false}
                            {...depTreeProps}
                          />
                        ) : (
                          <p className="text-xs text-zinc-600">Loading dependencies…</p>
                        )}
                      </div>
                    )}
                  </li>
                );
              })}
            </ul>
          </section>
        )}

        {nbEnabled && filteredNb.length > 0 && (
          <section>
            <h2 className="mb-3 flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-zinc-500">
              <span className="h-2 w-2 rounded-full bg-amber-400" />
              cf-data-lab notebooks
              <span className="font-normal text-zinc-600">
                ({cfg.fallback!.owner}/{cfg.fallback!.repo})
              </span>
            </h2>
            <ul className="divide-y divide-zinc-800/60">
              {filteredNb.map((p) => {
                const filename = p.split("/").pop() ?? p;
                const modelName = filename.replace(".ipynb", "");
                const dir = p.split("/").slice(0, -1).join("/");
                const isExpanded = expandedPaths.has(p);
                const nbDeps = notebookDepsMap.get(modelName);
                const hasDeps = nbDeps && nbDeps.rawTableRefs.length > 0;

                return (
                  <li key={p} className="py-3">
                    <div className="flex flex-wrap items-center gap-x-3 gap-y-1.5">
                      <button
                        type="button"
                        onClick={() => openFile(p, "notebook")}
                        className="text-left font-mono text-sm font-medium text-amber-400 hover:underline"
                      >
                        {filename}
                      </button>
                      <a
                        href={blobGithubUrl(
                          cfg.fallback!.owner!,
                          cfg.fallback!.repo!,
                          cfg.fallback!.ref ?? "master",
                          p,
                        )}
                        target="_blank"
                        rel="noreferrer"
                        className="flex items-center gap-1 rounded border border-zinc-700 px-2 py-0.5 text-xs text-zinc-400 hover:border-zinc-500 hover:text-zinc-200"
                      >
                        GitHub ↗
                      </a>
                      <button
                        type="button"
                        onClick={() => toggleExpanded(p)}
                        className={`flex items-center gap-1.5 rounded border px-2.5 py-1 text-xs font-medium transition-colors ${
                          isExpanded
                            ? "border-amber-800 bg-amber-950/60 text-amber-400"
                            : "border-zinc-700 bg-zinc-900 text-zinc-400 hover:border-zinc-500 hover:text-zinc-200"
                        }`}
                      >
                        {isExpanded ? "▾" : "▸"} Dependencies
                        {hasDeps && !isExpanded && (
                          <span className="rounded-full bg-zinc-700 px-1.5 py-0.5 text-zinc-400">
                            {nbDeps.rawTableRefs.length}
                          </span>
                        )}
                      </button>
                    </div>
                    <p className="mt-1 font-mono text-xs text-zinc-600">{dir}/</p>

                    {isExpanded && (
                      <div className="mt-2 rounded-lg border border-zinc-800 bg-zinc-950/60 px-4 py-3">
                        <p className="mb-2 text-xs font-semibold uppercase tracking-wider text-zinc-600">
                          Source tables
                        </p>
                        {nbDeps ? (
                          nbDeps.rawTableRefs.length > 0 ? (
                            <div className="space-y-0.5">
                              {nbDeps.rawTableRefs.map((s) => (
                                <RawTableRow
                                  key={`${s.schema}.${s.table}`}
                                  schema={s.schema}
                                  table={s.table}
                                />
                              ))}
                            </div>
                          ) : (
                            <p className="text-xs text-zinc-600">
                              No FROM/JOIN table references found in code cells.
                            </p>
                          )
                        ) : (
                          <p className="text-xs text-zinc-600">Loading…</p>
                        )}
                      </div>
                    )}
                  </li>
                );
              })}
            </ul>
          </section>
        )}

        {filteredSql.length === 0 && filteredNb.length === 0 && (
          <p className="py-8 text-center text-sm text-zinc-500">No models match.</p>
        )}
      </div>

      {openPath && (
        <Modal
          title={openPath.path.split("/").pop() ?? openPath.path}
          wide
          onClose={() => {
            setOpenPath(null);
            setSource(null);
            setSrcErr(null);
          }}
        >
          {openFileGithubUrl && (
            <div className="mb-3 flex items-center gap-2">
              <a
                href={openFileGithubUrl}
                target="_blank"
                rel="noreferrer"
                className="flex items-center gap-1.5 rounded-lg border border-zinc-700 px-3 py-1.5 text-xs font-medium text-zinc-300 hover:border-zinc-500 hover:text-white"
              >
                View on GitHub ↗
              </a>
              <span className="font-mono text-xs text-zinc-600">{openPath.path}</span>
            </div>
          )}
          {srcErr && <p className="text-sm text-amber-400">{srcErr}</p>}
          {!srcErr && source == null && <p className="text-sm text-zinc-500">Loading…</p>}
          {source != null && openPath.kind === "sql" && (
            <pre className="max-h-[70vh] overflow-auto whitespace-pre-wrap font-mono text-xs leading-relaxed text-zinc-200 md:text-sm">
              {source}
            </pre>
          )}
          {source != null && openPath.kind === "notebook" && <NotebookView body={source} />}
        </Modal>
      )}
    </div>
  );
}

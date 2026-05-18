import { useEffect, useMemo, useState } from "react";
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

  return {
    refs: [...new Set(refs)],
    sources: sources.filter(
      (s, i, arr) =>
        arr.findIndex((x) => x.schema === s.schema && x.table === s.table) === i,
    ),
    path,
  };
}

// ─── Recursive deps tree ───────────────────────────────────────────────────

function DepsTree({
  modelName,
  depsMap,
  knownModelNames,
  cfg,
  onOpenSql,
  ancestors = new Set<string>(),
  showSelf = true,
}: {
  modelName: string;
  depsMap: Map<string, ParsedDeps>;
  knownModelNames: Set<string>;
  cfg: DbtConfigFile;
  onOpenSql: (path: string) => void;
  ancestors?: Set<string>;
  showSelf?: boolean;
}) {
  const [expanded, setExpanded] = useState(false);
  const deps = depsMap.get(modelName);
  const isCycle = ancestors.has(modelName);
  const newAncestors = new Set([...ancestors, modelName]);

  // sources whose table name matches a known dbt model → treat as expandable
  const dbtSourceDeps = deps?.sources.filter((s) => knownModelNames.has(s.table)) ?? [];
  const rawSourceDeps = deps?.sources.filter((s) => !knownModelNames.has(s.table)) ?? [];
  const refDeps = deps?.refs ?? [];

  const hasExpandableChildren = refDeps.length > 0 || dbtSourceDeps.length > 0;
  const totalChildren = refDeps.length + dbtSourceDeps.length + rawSourceDeps.length;

  const childrenBlock = (
    <div className={showSelf ? "ml-4 border-l border-zinc-800/70 pl-3 pt-0.5" : ""}>
      {refDeps.map((ref) => (
        <DepsTree
          key={`ref-${ref}`}
          modelName={ref}
          depsMap={depsMap}
          knownModelNames={knownModelNames}
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
          cfg={cfg}
          onOpenSql={onOpenSql}
          ancestors={newAncestors}
          showSelf
        />
      ))}
      {rawSourceDeps.map((s) => (
        <div
          key={`raw-${s.schema}-${s.table}`}
          className="flex items-center gap-2 py-0.5 text-xs"
        >
          <span className="w-3 text-center text-zinc-700">—</span>
          <span className="font-mono text-zinc-500">{s.table}</span>
          <span className="rounded bg-zinc-800/60 px-1 py-0.5 text-zinc-600">{s.schema}</span>
        </div>
      ))}
      {totalChildren === 0 && (
        <p className="py-0.5 text-xs text-zinc-700">No dependencies found in SQL.</p>
      )}
    </div>
  );

  // Cycle guard
  if (showSelf && isCycle) {
    return (
      <div className="flex items-center gap-2 py-0.5 text-xs text-amber-600/70">
        <span className="w-3 text-center">↻</span>
        <span className="font-mono">{modelName}</span>
        <span className="text-zinc-700">(cycle)</span>
      </div>
    );
  }

  // Model not downloaded locally
  if (showSelf && !deps) {
    return (
      <div className="flex items-center gap-2 py-0.5 text-xs">
        <span className="w-3 text-center text-zinc-700">◦</span>
        <span className="font-mono text-zinc-400">{modelName}</span>
        <span className="text-zinc-700">dbt model</span>
      </div>
    );
  }

  if (!showSelf) return <>{childrenBlock}</>;

  return (
    <div>
      <div className="flex flex-wrap items-center gap-x-2 gap-y-0.5 py-0.5 text-xs">
        <button
          type="button"
          onClick={() => setExpanded((e) => !e)}
          className={`w-3 text-center text-zinc-500 transition-transform hover:text-white ${
            !hasExpandableChildren ? "invisible" : ""
          }`}
        >
          {expanded ? "▾" : "▸"}
        </button>
        <span className="font-mono text-sm font-medium text-emerald-400">{modelName}</span>
        <span className="rounded bg-emerald-950/50 px-1 py-0.5 text-zinc-500">dbt model</span>
        {deps && (
          <button
            type="button"
            onClick={() => onOpenSql(deps.path)}
            className="text-zinc-600 underline hover:text-emerald-400"
          >
            View SQL
          </button>
        )}
        {deps && cfg.owner && cfg.repo && (
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

  // Pre-fetched SQL cache — keyed by path — used to build the deps tree
  const [sqlCache, setSqlCache] = useState<Record<string, string>>({});
  // Which list items have their deps tree expanded
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

  // Pre-fetch all used SQL files in the background to power the deps tree
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

  // Build model-name → ParsedDeps map from the SQL cache
  const depsMap = useMemo(() => {
    const map = new Map<string, ParsedDeps>();
    for (const [path, sql] of Object.entries(sqlCache)) {
      const modelName = path.split("/").pop()!.replace(".sql", "");
      map.set(modelName, parseDeps(sql, path));
    }
    return map;
  }, [sqlCache]);

  const knownModelNames = useMemo(() => new Set(depsMap.keys()), [depsMap]);

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

  // GitHub link for the currently-open file
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

  return (
    <div className="flex h-full min-h-0 w-full flex-col overflow-hidden">
      <header className="border-b border-zinc-800 px-6 py-6">
        <h1 className="text-2xl font-bold text-white">Model Source Code</h1>
        <p className="mt-2 max-w-3xl text-sm text-zinc-400">
          dbt SQL models and cf-data-lab notebooks matched to the metrics in this handoff. Click a
          file to view its SQL, or expand ▸ to explore its source dependencies.
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
                const hasDeps = depsMap.has(modelName);

                return (
                  <li key={p} className="py-3">
                    {/* Model name row */}
                    <div className="flex flex-wrap items-center gap-x-3 gap-y-1">
                      <button
                        type="button"
                        onClick={() => toggleExpanded(p)}
                        aria-label={isExpanded ? "Collapse dependencies" : "Expand dependencies"}
                        className={`text-xs text-zinc-500 transition-colors hover:text-white ${
                          !hasDeps ? "invisible" : ""
                        }`}
                      >
                        {isExpanded ? "▾" : "▸"}
                      </button>
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
                    </div>
                    <p className="mt-0.5 pl-5 font-mono text-xs text-zinc-600">{dir}/</p>

                    {/* Inline deps tree */}
                    {isExpanded && (
                      <div className="mt-2 rounded-lg border border-zinc-800 bg-zinc-950/60 px-4 py-3">
                        <p className="mb-2 text-xs font-semibold uppercase tracking-wider text-zinc-600">
                          Dependencies
                        </p>
                        {hasDeps ? (
                          <DepsTree
                            modelName={modelName}
                            depsMap={depsMap}
                            knownModelNames={knownModelNames}
                            cfg={cfg}
                            onOpenSql={(depPath) => openFile(depPath, "sql")}
                            showSelf={false}
                          />
                        ) : (
                          <p className="text-xs text-zinc-600">
                            Loading dependencies… (SQL still fetching)
                          </p>
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
                const dir = p.split("/").slice(0, -1).join("/");
                return (
                  <li key={p} className="py-2.5">
                    <div className="flex items-center gap-3">
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
                    </div>
                    <p className="mt-0.5 font-mono text-xs text-zinc-600">{dir}/</p>
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
          {/* GitHub link inside modal */}
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
          {source != null && openPath.kind === "notebook" && (
            <NotebookView body={source} />
          )}
        </Modal>
      )}
    </div>
  );
}

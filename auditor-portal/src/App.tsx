import { useCallback, useEffect, useMemo, useState } from "react";
import type { Catalog, CatalogEntry } from "./types";
import rawCatalog from "./catalog.json";

const catalog = rawCatalog as Catalog;

const HANDOFF = `${import.meta.env.BASE_URL}handoff/`;

function handoffUrl(rel: string) {
  return `${HANDOFF}${rel.replace(/^\//, "")}`;
}

async function fetchText(path: string): Promise<string> {
  const res = await fetch(handoffUrl(path));
  if (!res.ok) throw new Error(`${res.status} ${path}`);
  return res.text();
}

async function fetchJson(path: string): Promise<unknown> {
  const res = await fetch(handoffUrl(path));
  if (!res.ok) throw new Error(`${res.status} ${path}`);
  return res.json();
}

function Modal({
  title,
  onClose,
  children,
  wide,
}: {
  title: string;
  onClose: () => void;
  children: React.ReactNode;
  wide?: boolean;
}) {
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [onClose]);

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4 backdrop-blur-sm"
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
      onMouseDown={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div
        className={`flex max-h-[90vh] w-full flex-col overflow-hidden rounded-xl border border-zinc-700 bg-zinc-900 shadow-2xl ${
          wide ? "max-w-6xl" : "max-w-3xl"
        }`}
      >
        <div className="flex items-center justify-between border-b border-zinc-800 px-5 py-3">
          <h2 id="modal-title" className="text-lg font-semibold text-white">
            {title}
          </h2>
          <button
            type="button"
            onClick={onClose}
            className="rounded-lg px-3 py-1.5 text-sm text-zinc-400 hover:bg-zinc-800 hover:text-white"
          >
            Close
          </button>
        </div>
        <div className="min-h-0 flex-1 overflow-auto p-4">{children}</div>
      </div>
    </div>
  );
}

function DetailPanel({
  entry,
  onClose,
  onShowSql,
  onShowLineageGraph,
}: {
  entry: CatalogEntry;
  onClose: () => void;
  onShowSql: () => void;
  onShowLineageGraph: () => void;
}) {
  const [meta, setMeta] = useState<unknown | null>(null);
  const [metaErr, setMetaErr] = useState<string | null>(null);
  const [lineageMd, setLineageMd] = useState<string | null>(null);
  const [lineageErr, setLineageErr] = useState<string | null>(null);

  useEffect(() => {
    setMeta(null);
    setMetaErr(null);
    setLineageMd(null);
    setLineageErr(null);
    if (!entry.paths.metadata) {
      setMetaErr("No metadata JSON for this card.");
      return;
    }
    fetchJson(entry.paths.metadata)
      .then(setMeta)
      .catch((e: Error) => setMetaErr(e.message));
  }, [entry]);

  useEffect(() => {
    if (!entry.paths.lineageMarkdown) {
      setLineageErr("No lineage markdown for this root.");
      return;
    }
    fetchText(entry.paths.lineageMarkdown)
      .then(setLineageMd)
      .catch((e: Error) => setLineageErr(e.message));
  }, [entry]);

  const metaStr = useMemo(() => {
    if (meta == null) return "";
    try {
      return JSON.stringify(meta, null, 2);
    } catch {
      return String(meta);
    }
  }, [meta]);

  return (
    <aside className="flex w-full max-w-xl shrink-0 flex-col border-l border-zinc-800 bg-zinc-900/95 lg:max-w-[28rem] xl:max-w-md">
      <div className="flex items-start justify-between gap-3 border-b border-zinc-800 p-4">
        <div className="min-w-0">
          <p className="text-xs font-medium uppercase tracking-wide text-emerald-500/90">
            Metabase card {entry.cardId}
          </p>
          <h2 className="mt-1 text-lg font-semibold leading-snug text-white">{entry.name}</h2>
          {entry.dashboardName && (
            <p className="mt-2 text-sm text-zinc-400">
              Dashboard: <span className="text-zinc-200">{entry.dashboardName}</span>
              {entry.dashboardId && (
                <span className="text-zinc-500"> ({entry.dashboardId})</span>
              )}
            </p>
          )}
          <p className="mt-1 text-xs text-zinc-500">
            Lineage root: <code className="text-zinc-400">{entry.rootKey}</code>
          </p>
        </div>
        <button
          type="button"
          onClick={onClose}
          className="shrink-0 rounded-lg p-2 text-zinc-400 hover:bg-zinc-800 hover:text-white"
          aria-label="Close panel"
        >
          ✕
        </button>
      </div>

      <div className="flex flex-wrap gap-2 border-b border-zinc-800 p-4">
        {entry.paths.query && (
          <button
            type="button"
            onClick={onShowSql}
            className="rounded-lg bg-emerald-600 px-3 py-2 text-sm font-medium text-white hover:bg-emerald-500"
          >
            View source SQL
          </button>
        )}
        {entry.paths.lineagePreviewHtml && (
          <button
            type="button"
            onClick={onShowLineageGraph}
            className="rounded-lg border border-zinc-600 bg-zinc-800 px-3 py-2 text-sm font-medium text-zinc-100 hover:border-zinc-500 hover:bg-zinc-800"
          >
            Lineage graph
          </button>
        )}
        {entry.paths.outputPreviewHtml && (
          <a
            href={handoffUrl(entry.paths.outputPreviewHtml)}
            target="_blank"
            rel="noreferrer"
            className="rounded-lg border border-zinc-600 px-3 py-2 text-sm font-medium text-zinc-200 hover:bg-zinc-800"
          >
            Output preview
          </a>
        )}
        {entry.paths.lineageMarkdown && (
          <a
            href={handoffUrl(entry.paths.lineageMarkdown)}
            target="_blank"
            rel="noreferrer"
            className="rounded-lg border border-zinc-600 px-3 py-2 text-sm font-medium text-zinc-200 hover:bg-zinc-800"
          >
            Open lineage .md
          </a>
        )}
      </div>

      <div className="min-h-0 flex-1 space-y-4 overflow-y-auto p-4">
        <section>
          <h3 className="mb-2 text-sm font-semibold text-zinc-300">Metabase metadata</h3>
          {metaErr && <p className="text-sm text-amber-400">{metaErr}</p>}
          {!metaErr && meta == null && <p className="text-sm text-zinc-500">Loading…</p>}
          {meta != null && (
            <pre className="max-h-72 overflow-auto rounded-lg border border-zinc-800 bg-zinc-950 p-3 text-xs leading-relaxed text-zinc-300 font-mono">
              {metaStr}
            </pre>
          )}
        </section>

        <section>
          <h3 className="mb-2 text-sm font-semibold text-zinc-300">Lineage narrative</h3>
          {lineageErr && <p className="text-sm text-amber-400">{lineageErr}</p>}
          {!lineageErr && lineageMd == null && <p className="text-sm text-zinc-500">Loading…</p>}
          {lineageMd != null && (
            <pre className="max-h-64 overflow-auto whitespace-pre-wrap rounded-lg border border-zinc-800 bg-zinc-950 p-3 text-xs leading-relaxed text-zinc-400 font-mono">
              {lineageMd.slice(0, 12000)}
              {lineageMd.length > 12000 ? "\n\n… (truncated in UI; use Open lineage .md for full file)" : ""}
            </pre>
          )}
        </section>

        {entry.results.length > 0 && (
          <section>
            <h3 className="mb-2 text-sm font-semibold text-zinc-300">Sample / result files</h3>
            <ul className="space-y-1 text-sm">
              {entry.results.map((r) => (
                <li key={r}>
                  <a
                    href={handoffUrl(r)}
                    target="_blank"
                    rel="noreferrer"
                    className="text-emerald-400 hover:underline"
                  >
                    {r.replace(/^artifacts\/results\//, "")}
                  </a>
                </li>
              ))}
            </ul>
          </section>
        )}
      </div>
    </aside>
  );
}

export default function App() {
  const [q, setQ] = useState("");
  const [dash, setDash] = useState("");
  const [selected, setSelected] = useState<CatalogEntry | null>(null);
  const [sqlOpen, setSqlOpen] = useState(false);
  const [sqlBody, setSqlBody] = useState<string | null>(null);
  const [sqlErr, setSqlErr] = useState<string | null>(null);
  const [lineageOpen, setLineageOpen] = useState(false);

  const dashboards = useMemo(() => {
    const set = new Set<string>();
    for (const e of catalog.entries) {
      if (e.dashboardName) set.add(e.dashboardName);
    }
    return [...set].sort((a, b) => a.localeCompare(b));
  }, []);

  const filtered = useMemo(() => {
    const qq = q.trim().toLowerCase();
    return catalog.entries.filter((e) => {
      if (dash && e.dashboardName !== dash) return false;
      if (!qq) return true;
      return (
        e.name.toLowerCase().includes(qq) ||
        e.cardId.includes(qq) ||
        (e.dashboardName?.toLowerCase().includes(qq) ?? false) ||
        e.rootKey.toLowerCase().includes(qq)
      );
    });
  }, [q, dash]);

  const loadSql = useCallback(() => {
    if (!selected?.paths.query) return;
    setSqlErr(null);
    setSqlBody(null);
    fetchText(selected.paths.query)
      .then(setSqlBody)
      .catch((e: Error) => setSqlErr(e.message));
  }, [selected]);

  useEffect(() => {
    if (sqlOpen && selected?.paths.query) loadSql();
  }, [sqlOpen, selected, loadSql]);

  return (
    <div className="flex min-h-screen flex-col lg:flex-row">
      <div className="flex min-w-0 flex-1 flex-col">
        <header className="border-b border-zinc-800 bg-zinc-900/80 px-6 py-8">
          <p className="text-xs font-semibold uppercase tracking-widest text-emerald-500/90">
            Curefit · Auditor handoff
          </p>
          <h1 className="mt-2 text-3xl font-bold tracking-tight text-white md:text-4xl">
            Metrics, definitions & lineage
          </h1>
          <p className="mt-3 max-w-2xl text-sm leading-relaxed text-zinc-400">
            One place to review Metabase card metadata, exported SQL, dependency lineage, and evidence
            files—without granting access to internal codebases. Built from the same artifacts as this
            repository.
          </p>
          <p className="mt-2 text-xs text-zinc-600">
            Catalog generated {new Date(catalog.generatedAt).toLocaleString()} · {catalog.count} cards
          </p>
        </header>

        <div className="flex flex-wrap items-end gap-3 border-b border-zinc-800 bg-zinc-900/40 px-6 py-4">
          <label className="flex min-w-[12rem] flex-1 flex-col gap-1 text-xs text-zinc-500">
            Search
            <input
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="Name, card id, dashboard…"
              className="rounded-lg border border-zinc-700 bg-zinc-950 px-3 py-2 text-sm text-white placeholder:text-zinc-600 focus:border-emerald-600 focus:outline-none focus:ring-1 focus:ring-emerald-600"
            />
          </label>
          <label className="flex w-full min-w-[10rem] flex-col gap-1 text-xs text-zinc-500 sm:w-56">
            Dashboard
            <select
              value={dash}
              onChange={(e) => setDash(e.target.value)}
              className="rounded-lg border border-zinc-700 bg-zinc-950 px-3 py-2 text-sm text-white focus:border-emerald-600 focus:outline-none focus:ring-1 focus:ring-emerald-600"
            >
              <option value="">All</option>
              {dashboards.map((d) => (
                <option key={d} value={d}>
                  {d}
                </option>
              ))}
            </select>
          </label>
        </div>

        <div className="min-h-0 flex-1 overflow-auto">
          <table className="w-full border-collapse text-left text-sm">
            <thead className="sticky top-0 z-10 bg-zinc-900/95 backdrop-blur">
              <tr className="border-b border-zinc-800 text-xs uppercase tracking-wide text-zinc-500">
                <th className="px-6 py-3 font-medium">Metric</th>
                <th className="hidden px-3 py-3 font-medium md:table-cell">Card</th>
                <th className="hidden px-3 py-3 font-medium lg:table-cell">Dashboard</th>
                <th className="px-4 py-3 font-medium">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((e) => (
                <tr
                  key={e.entryKey ?? e.cardId}
                  className={`border-b border-zinc-800/80 hover:bg-zinc-900/60 ${
                    (selected?.entryKey ?? selected?.cardId) === (e.entryKey ?? e.cardId)
                      ? "bg-emerald-950/20"
                      : ""
                  }`}
                >
                  <td className="px-6 py-3">
                    <button
                      type="button"
                      onClick={() => setSelected(e)}
                      className="text-left font-medium text-zinc-100 hover:text-emerald-400"
                    >
                      {e.name}
                    </button>
                  </td>
                  <td className="hidden px-3 py-3 font-mono text-xs text-zinc-500 md:table-cell">
                    {e.cardId}
                  </td>
                  <td className="hidden max-w-[14rem] truncate px-3 py-3 text-zinc-500 lg:table-cell">
                    {e.dashboardName ?? "—"}
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex flex-wrap gap-1.5">
                      <button
                        type="button"
                        onClick={() => {
                          setSelected(e);
                        }}
                        className="rounded-md border border-zinc-700 px-2 py-1 text-xs text-zinc-300 hover:bg-zinc-800"
                      >
                        Details
                      </button>
                      {e.paths.query && (
                        <button
                          type="button"
                          onClick={() => {
                            setSelected(e);
                            setSqlOpen(true);
                          }}
                          className="rounded-md bg-emerald-700/80 px-2 py-1 text-xs text-white hover:bg-emerald-600"
                        >
                          SQL
                        </button>
                      )}
                      {e.paths.lineagePreviewHtml && (
                        <button
                          type="button"
                          onClick={() => {
                            setSelected(e);
                            setLineageOpen(true);
                          }}
                          className="rounded-md border border-zinc-600 px-2 py-1 text-xs text-zinc-200 hover:bg-zinc-800"
                        >
                          Lineage
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {filtered.length === 0 && (
            <p className="px-6 py-12 text-center text-zinc-500">No metrics match your filters.</p>
          )}
        </div>
      </div>

      {selected && (
        <DetailPanel
          entry={selected}
          onClose={() => {
            setSelected(null);
            setSqlOpen(false);
            setLineageOpen(false);
          }}
          onShowSql={() => setSqlOpen(true)}
          onShowLineageGraph={() => setLineageOpen(true)}
        />
      )}

      {sqlOpen && selected?.paths.query && (
        <Modal title="Source SQL" onClose={() => setSqlOpen(false)} wide>
          {sqlErr && <p className="text-amber-400">{sqlErr}</p>}
          {!sqlErr && sqlBody == null && <p className="text-zinc-500">Loading…</p>}
          {sqlBody != null && (
            <pre className="text-xs leading-relaxed text-zinc-300 font-mono whitespace-pre-wrap">
              {sqlBody}
            </pre>
          )}
        </Modal>
      )}

      {lineageOpen && selected?.paths.lineagePreviewHtml && (
        <Modal title="Lineage preview" onClose={() => setLineageOpen(false)} wide>
          <iframe
            title="Lineage"
            className="h-[75vh] w-full rounded-lg border border-zinc-800 bg-white"
            src={handoffUrl(selected.paths.lineagePreviewHtml)}
            sandbox="allow-scripts allow-same-origin"
          />
        </Modal>
      )}
    </div>
  );
}

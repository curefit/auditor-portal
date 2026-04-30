import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { Modal } from "../components/Modal";
import type { Catalog, CatalogEntry, SheetMetric, SqlLineageRelation } from "../types";
import rawCatalog from "../catalog.json";

const catalog: Catalog = {
  ...(rawCatalog as Catalog),
  dbt:
    (rawCatalog as Catalog).dbt ??
    ({
      enabled: false,
      owner: "",
      repo: "",
      ref: "main",
      modelSqlFileCount: 0,
      fetchNote: "Run npm run generate to refresh catalog and optional dbt index.",
    } as Catalog["dbt"]),
};

const HANDOFF = "/handoff/";

type DbtSqlRefs = { sources: string[]; refs: string[] };

function parseDbtRefs(sql: string): DbtSqlRefs {
  const sources = new Set<string>();
  const refs = new Set<string>();
  const srcRe = /{{\s*source\s*\(\s*['"]([^'"]+)['"]\s*,\s*['"]([^'"]+)['"]\s*\)\s*}}/gi;
  const refRe = /{{\s*ref\s*\(\s*['"]([^'"]+)['"]\s*\)\s*}}/gi;
  let m: RegExpExecArray | null;
  while ((m = srcRe.exec(sql))) sources.add(`${m[1]}.${m[2]}`);
  while ((m = refRe.exec(sql))) refs.add(m[1]);
  return { sources: [...sources].sort(), refs: [...refs].sort() };
}

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

function SheetMetricSection({ metric }: { metric: SheetMetric }) {
  const fyRows = [
    { label: "FY23", value: metric.fy23 },
    { label: "FY24", value: metric.fy24 },
    { label: "FY25", value: metric.fy25 },
    { label: "FY26", value: metric.fy26 },
    { label: "9M FY25", value: metric.nineMFy25 },
    { label: "9M FY26", value: metric.nineMFy26 },
  ].filter((r) => r.value);

  return (
    <div className="rounded-xl border border-indigo-700/50 bg-indigo-950/30 p-5">
      <div className="mb-3 flex flex-wrap items-center gap-2">
        <span className="rounded-full bg-indigo-600/80 px-2.5 py-0.5 text-xs font-semibold uppercase tracking-wider text-indigo-100">
          DRHP Op. Metrics
        </span>
        <span className="text-xs text-indigo-400/80">Metric #{metric.slNo}</span>
        {metric.status && (
          <span
            className={`rounded-full px-2.5 py-0.5 text-xs font-medium ${
              metric.status === "Done"
                ? "bg-emerald-900/60 text-emerald-300"
                : "bg-amber-900/60 text-amber-300"
            }`}
          >
            {metric.status}
          </span>
        )}
      </div>

      <h3 className="text-base font-semibold text-white">{metric.metricName}</h3>

      {metric.definition && (
        <p className="mt-2 text-sm leading-relaxed text-zinc-300">{metric.definition}</p>
      )}

      {fyRows.length > 0 && (
        <div className="mt-4 overflow-x-auto">
          <table className="w-full border-collapse text-sm">
            <thead>
              <tr className="border-b border-indigo-800/60">
                {fyRows.map((r) => (
                  <th
                    key={r.label}
                    className="px-3 py-1.5 text-left text-xs font-semibold uppercase tracking-wide text-indigo-400"
                  >
                    {r.label}
                  </th>
                ))}
                {metric.units && (
                  <th className="px-3 py-1.5 text-left text-xs font-semibold uppercase tracking-wide text-indigo-400">
                    Units
                  </th>
                )}
              </tr>
            </thead>
            <tbody>
              <tr>
                {fyRows.map((r) => (
                  <td key={r.label} className="px-3 py-1.5 font-mono text-sm text-zinc-200">
                    {r.value || "—"}
                  </td>
                ))}
                {metric.units && (
                  <td className="px-3 py-1.5 text-sm text-zinc-400">{metric.units}</td>
                )}
              </tr>
            </tbody>
          </table>
        </div>
      )}

      <div className="mt-4 flex flex-wrap gap-x-6 gap-y-1.5 text-sm">
        {metric.poc && (
          <span className="text-zinc-400">
            PoC: <span className="text-zinc-200">{metric.poc}</span>
          </span>
        )}
        {metric.limitations && (
          <span className="text-zinc-400">
            Limitations: <span className="text-amber-300/90">{metric.limitations}</span>
          </span>
        )}
      </div>
    </div>
  );
}

function RelationRow({
  r,
  onViewDbtSql,
  onViewNotebook,
}: {
  r: SqlLineageRelation;
  onViewDbtSql: (localUrl: string, label: string, githubUrl?: string) => void;
  onViewNotebook: (localUrl: string, label: string, githubUrl?: string) => void;
}) {
  const hasModel = r.dbtModelPaths.length > 0;
  const hasFallback = r.fallbackModelPaths.length > 0;
  return (
    <li className="rounded-lg border border-zinc-800 bg-zinc-950/80 p-3 text-base">
      <code className="font-mono text-emerald-300">{r.relation}</code>
      {hasModel && (
        <ul className="mt-2 space-y-1.5 text-sm">
          {r.dbtModelPaths.map((path, i) => {
            const filename = path.split("/").pop() ?? path;
            const localUrl = r.localSqlUrls?.[i];
            const githubUrl = r.githubBlobUrls[i];
            return (
              <li key={path} className="flex flex-wrap items-center gap-2">
                {localUrl ? (
                  <button
                    type="button"
                    onClick={() => onViewDbtSql(localUrl, filename, githubUrl)}
                    className="break-all text-left text-sky-400 hover:underline"
                  >
                    {filename}
                  </button>
                ) : (
                  <span className="break-all text-zinc-400">{filename}</span>
                )}
                {githubUrl && (
                  <a
                    href={githubUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    title="Open on GitHub"
                    className="rounded bg-zinc-800 px-2 py-0.5 text-xs text-zinc-400 hover:bg-zinc-700 hover:text-zinc-200"
                  >
                    GitHub ↗
                  </a>
                )}
              </li>
            );
          })}
        </ul>
      )}
      {!hasModel && hasFallback && (
        <ul className="mt-2 space-y-1.5 text-sm">
          {r.fallbackModelPaths.map((path, i) => {
            const filename = path.split("/").pop() ?? path;
            const localUrl = r.fallbackLocalUrls?.[i];
            const githubUrl = r.fallbackGithubBlobUrls[i];
            return (
              <li key={path} className="flex flex-wrap items-center gap-2">
                {localUrl ? (
                  <button
                    type="button"
                    onClick={() => onViewNotebook(localUrl, filename, githubUrl)}
                    className="break-all text-left text-amber-400 hover:underline"
                  >
                    {filename}
                  </button>
                ) : (
                  <span className="break-all text-amber-400/70">{filename}</span>
                )}
                <span className="text-xs text-zinc-600">(notebook)</span>
                {githubUrl && (
                  <a
                    href={githubUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    title="Open on GitHub"
                    className="rounded bg-zinc-800 px-2 py-0.5 text-xs text-zinc-400 hover:bg-zinc-700 hover:text-zinc-200"
                  >
                    GitHub ↗
                  </a>
                )}
              </li>
            );
          })}
        </ul>
      )}
      {!hasModel && !hasFallback && (
        <p className="mt-2 text-sm text-zinc-500">No matching dbt model or notebook found.</p>
      )}
    </li>
  );
}

/** A collapsible row used in the DRHP list for dashboard-sourced metrics. */
type NotebookCell = { cell_type: string; source: string[] };

function NotebookModal({
  label,
  body,
  err,
  githubUrl,
  onClose,
}: {
  label: string;
  body: string | null;
  err: string | null;
  githubUrl?: string;
  onClose: () => void;
}) {
  const cells = useMemo<NotebookCell[]>(() => {
    if (!body) return [];
    try {
      const nb = JSON.parse(body) as { cells?: NotebookCell[] };
      return nb.cells ?? [];
    } catch {
      return [];
    }
  }, [body]);

  const codeCells = cells.filter((c) => c.cell_type === "code");
  const mdCells = cells.filter((c) => c.cell_type === "markdown");

  return (
    <Modal title={`Notebook — ${label}`} onClose={onClose} wide>
      <div className="mb-4 flex items-center justify-between gap-4">
        <p className="text-sm text-zinc-500">
          Python / SQL notebook from the cf-data-lab repo.{" "}
          {codeCells.length > 0 && `${codeCells.length} code cell${codeCells.length !== 1 ? "s" : ""}`}
          {mdCells.length > 0 && `, ${mdCells.length} markdown cell${mdCells.length !== 1 ? "s" : ""}`}.{" "}
          <span className="text-zinc-600">
            Cached {new Date(catalog.generatedAt).toLocaleString()}.
          </span>
        </p>
        {githubUrl && (
          <a
            href={githubUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="shrink-0 rounded-lg border border-zinc-600 px-3 py-1.5 text-sm text-zinc-300 hover:bg-zinc-800"
          >
            View on GitHub ↗
          </a>
        )}
      </div>

      {err && (
        <p className="mb-4 rounded-lg border border-amber-700 bg-amber-950/40 p-3 text-sm text-amber-300">
          {err}
        </p>
      )}
      {!err && body == null && <p className="text-sm text-zinc-500">Loading…</p>}

      {cells.length > 0 && (
        <div className="max-h-[65vh] space-y-3 overflow-y-auto">
          {cells.map((cell, i) => {
            const src = Array.isArray(cell.source) ? cell.source.join("") : String(cell.source ?? "");
            if (!src.trim()) return null;
            return (
              <div key={i} className={`rounded-lg border text-sm ${
                cell.cell_type === "code"
                  ? "border-zinc-700 bg-zinc-950"
                  : "border-zinc-800 bg-zinc-900/50"
              }`}>
                <div className={`border-b px-3 py-1 text-xs font-semibold uppercase tracking-wider ${
                  cell.cell_type === "code"
                    ? "border-zinc-700 text-sky-400/70"
                    : "border-zinc-800 text-zinc-500"
                }`}>
                  {cell.cell_type === "code" ? `Code [${i + 1}]` : "Markdown"}
                </div>
                <pre className="overflow-x-auto whitespace-pre-wrap p-3 font-mono text-xs leading-relaxed text-zinc-200">
                  {src}
                </pre>
              </div>
            );
          })}
        </div>
      )}

      {body != null && cells.length === 0 && (
        <pre className="max-h-[60vh] overflow-auto whitespace-pre-wrap rounded-lg border border-zinc-800 bg-zinc-950 p-4 font-mono text-xs text-zinc-300">
          {body}
        </pre>
      )}
    </Modal>
  );
}

function DashboardGroup({
  metric,
  dashboardId,
  dashboardName,
  cards,
  selected,
  onSelect,
  onOpenMetabase,
  onOpenSql,
}: {
  metric: SheetMetric;
  dashboardId: string;
  dashboardName: string;
  cards: CatalogEntry[];
  selected: CatalogEntry | null;
  onSelect: (e: CatalogEntry) => void;
  onOpenMetabase: (url: string) => void;
  onOpenSql: (e: CatalogEntry) => void;
}) {
  const [open, setOpen] = useState(false);
  const isActive = selected && cards.some((c) => c.cardId === selected.cardId);

  return (
    <>
      <tr
        className={`border-b border-zinc-800/80 hover:bg-zinc-900/60 ${
          isActive ? "bg-emerald-950/20" : ""
        }`}
      >
        <td className="px-6 py-4" colSpan={2}>
          <button
            type="button"
            onClick={() => setOpen((v) => !v)}
            className="flex items-start gap-2 text-left"
          >
            <span className="mt-0.5 shrink-0 text-zinc-500">{open ? "▾" : "▸"}</span>
            <div>
              <span className="text-lg font-medium text-zinc-100 hover:text-emerald-400">
                {metric.metricName}
              </span>
              <div className="mt-1 flex flex-wrap items-center gap-2">
                <span className="rounded-full bg-indigo-800/60 px-2 py-0.5 text-xs font-semibold text-indigo-300">
                  DRHP #{metric.slNo}
                </span>
                <span className="rounded bg-zinc-800 px-2 py-0.5 text-xs text-zinc-400">
                  Dashboard · {cards.length} cards
                </span>
                {metric.units && (
                  <span className="text-xs text-zinc-500">{metric.units}</span>
                )}
                {metric.fy26 && (
                  <span className="text-xs text-zinc-400">
                    FY26: <span className="font-medium text-zinc-200">{metric.fy26}</span>
                  </span>
                )}
              </div>
            </div>
          </button>
        </td>
        <td className="hidden px-3 py-4 text-base text-zinc-500 lg:table-cell">
          {dashboardName}
        </td>
        <td className="px-4 py-4">
          <a
            href={`https://metabase.curefit.co/dashboard/${dashboardId}`}
            target="_blank"
            rel="noopener noreferrer"
            className="rounded-md border border-emerald-700/80 bg-emerald-950/40 px-3 py-1.5 text-sm font-medium text-emerald-200 hover:bg-emerald-900/50"
          >
            Dashboard ↗
          </a>
        </td>
      </tr>
      {open &&
        cards.map((card) => (
          <tr
            key={card.cardId}
            data-card-id={card.cardId}
            className={`border-b border-zinc-800/40 bg-zinc-950/40 hover:bg-zinc-900/60 ${
              selected?.cardId === card.cardId ? "bg-emerald-950/20" : ""
            }`}
          >
            <td className="py-3 pl-14 pr-4">
              <button
                type="button"
                onClick={() => onSelect(card)}
                className="text-left text-sm text-zinc-300 hover:text-emerald-400"
              >
                {card.name}
              </button>
            </td>
            <td className="hidden px-3 py-3 font-mono text-xs text-zinc-600 md:table-cell">
              {card.cardId}
            </td>
            <td className="hidden px-3 py-3 lg:table-cell" />
            <td className="px-4 py-3">
              <div className="flex flex-wrap gap-2">
                <a
                  href={card.metabaseCardUrl ?? `https://metabase.curefit.co/question/${card.cardId}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="rounded-md border border-zinc-700 px-2.5 py-1 text-xs text-zinc-300 hover:bg-zinc-800"
                >
                  Metabase
                </a>
                <button
                  type="button"
                  onClick={() => onSelect(card)}
                  className="rounded-md border border-zinc-700 px-2.5 py-1 text-xs text-zinc-300 hover:bg-zinc-800"
                >
                  Overview
                </button>
                {card.paths.query && (
                  <button
                    type="button"
                    onClick={() => onOpenSql(card)}
                    className="rounded-md bg-emerald-700/80 px-2.5 py-1 text-xs text-white hover:bg-emerald-600"
                  >
                    SQL
                  </button>
                )}
              </div>
            </td>
          </tr>
        ))}
    </>
  );
}

type MetaCard = {
  name?: string;
  description?: string | null;
  display?: string;
  created_at?: string;
  updated_at?: string;
  creator?: { common_name?: string; email?: string };
  collection?: { name?: string };
  database_id?: number;
  result_metadata?: Array<{ display_name?: string; base_type?: string; name?: string }>;
};

function MetaCardView({ meta }: { meta: MetaCard }) {
  const columns = meta.result_metadata ?? [];
  return (
    <div className="space-y-4 text-sm">
      {meta.description && (
        <p className="leading-relaxed text-zinc-300">{meta.description}</p>
      )}
      <div className="flex flex-wrap gap-x-6 gap-y-2 text-zinc-400">
        {meta.display && (
          <span>
            Chart type: <span className="text-zinc-200 capitalize">{meta.display}</span>
          </span>
        )}
        {meta.creator?.common_name && (
          <span>
            Creator: <span className="text-zinc-200">{meta.creator.common_name}</span>
          </span>
        )}
        {meta.collection?.name && (
          <span>
            Collection: <span className="text-zinc-200">{meta.collection.name}</span>
          </span>
        )}
        {meta.created_at && (
          <span>
            Created:{" "}
            <span className="text-zinc-200">
              {new Date(meta.created_at).toLocaleDateString()}
            </span>
          </span>
        )}
      </div>
      {columns.length > 0 && (
        <div>
          <p className="mb-2 text-xs font-semibold uppercase tracking-wider text-zinc-500">
            Output columns ({columns.length})
          </p>
          <div className="flex flex-wrap gap-1.5">
            {columns.map((c, i) => (
              <span
                key={i}
                className="rounded bg-zinc-800 px-2 py-0.5 font-mono text-xs text-zinc-300"
                title={c.base_type}
              >
                {c.display_name ?? c.name}
              </span>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

function DetailPanel({
  entry,
  onClose,
  onShowSql,
  onViewDbtSql,
  onViewNotebook,
}: {
  entry: CatalogEntry;
  onClose: () => void;
  onShowSql: () => void;
  onViewDbtSql: (localUrl: string, label: string, githubUrl?: string) => void;
  onViewNotebook: (localUrl: string, label: string, githubUrl?: string) => void;
}) {
  const [meta, setMeta] = useState<MetaCard | null>(null);
  const [metaErr, setMetaErr] = useState<string | null>(null);

  useEffect(() => {
    setMeta(null);
    setMetaErr(null);
    if (!entry.paths.metadata) {
      setMetaErr("No metadata for this card.");
      return;
    }
    fetchJson(entry.paths.metadata)
      .then((d) => setMeta(d as MetaCard))
      .catch((e: Error) => setMetaErr(e.message));
  }, [entry]);

  return (
    <aside className="flex h-full w-full max-w-xl shrink-0 flex-col border-l border-zinc-800 bg-zinc-900/95 lg:max-w-[32rem] xl:max-w-lg">
      <div className="flex items-start justify-between gap-3 border-b border-zinc-800 p-5">
        <div className="min-w-0">
          <p className="text-sm font-medium uppercase tracking-wide text-emerald-500/90">
            Metabase card {entry.cardId}
          </p>
          <h2 className="mt-1.5 text-xl font-semibold leading-snug text-white">{entry.name}</h2>
          {entry.dashboardName && (
            <p className="mt-1 text-sm text-zinc-500">
              {entry.dashboardName}
            </p>
          )}
          <div className="mt-3 flex flex-wrap gap-2">
            <a
              href={entry.metabaseCardUrl ?? `https://metabase.curefit.co/question/${entry.cardId}`}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center rounded-lg bg-emerald-700 px-3 py-2 text-sm font-medium text-white hover:bg-emerald-600"
            >
              Open in Metabase ↗
            </a>
            {entry.paths.query && (
              <button
                type="button"
                onClick={onShowSql}
                className="rounded-lg bg-zinc-700 px-3 py-2 text-sm font-medium text-zinc-100 hover:bg-zinc-600"
              >
                View SQL
              </button>
            )}
          </div>
        </div>
        <button
          type="button"
          onClick={onClose}
          className="shrink-0 rounded-lg p-2 text-lg text-zinc-400 hover:bg-zinc-800 hover:text-white"
          aria-label="Close panel"
        >
          ✕
        </button>
      </div>

      <div className="min-h-0 flex-1 space-y-5 overflow-y-auto p-5">
        {entry.sheetMetric && (
          <section>
            <SheetMetricSection metric={entry.sheetMetric} />
          </section>
        )}

        <section>
          <h3 className="mb-2 text-base font-semibold text-zinc-300">Tables / relations (from SQL)</h3>
          <p className="mb-3 text-sm leading-relaxed text-zinc-500">
            Parsed from the exported Metabase SQL. Links are{" "}
            <strong className="text-zinc-400">name-matched</strong> dbt model files — click{" "}
            <span className="text-zinc-400">View SQL ↗</span> to see the SQL that creates the table.
            Amber links are Jupyter notebooks from the fallback repo.
          </p>
          {(entry.sqlLineageRelations ?? []).length === 0 ? (
            <p className="text-base text-zinc-500">No qualified relations detected in SQL.</p>
          ) : (
            <ul className="space-y-3">
              {(entry.sqlLineageRelations ?? []).map((r) => (
                <RelationRow key={r.relation} r={r} onViewDbtSql={onViewDbtSql} onViewNotebook={onViewNotebook} />
              ))}
            </ul>
          )}
        </section>

        <section>
          <h3 className="mb-2 text-base font-semibold text-zinc-300">Card details</h3>
          {metaErr && <p className="text-sm text-zinc-500">{metaErr}</p>}
          {!metaErr && meta == null && <p className="text-sm text-zinc-500">Loading…</p>}
          {meta != null && <MetaCardView meta={meta} />}
        </section>

        {entry.results.length > 0 && (
          <section>
            <h3 className="mb-2 text-base font-semibold text-zinc-300">Sample result files</h3>
            <ul className="space-y-2 text-sm">
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

function DbtSqlModal({
  label,
  body,
  err,
  refs,
  githubUrl,
  onClose,
}: {
  label: string;
  body: string | null;
  err: string | null;
  refs: DbtSqlRefs | null;
  githubUrl?: string;
  onClose: () => void;
}) {
  const hasLineage = refs && (refs.sources.length > 0 || refs.refs.length > 0);

  return (
    <Modal title={`dbt model — ${label}`} onClose={onClose} wide>
      <div className="mb-4 flex items-center justify-between gap-4">
        <p className="text-sm text-zinc-500">
          SQL that creates this dimension/fact table in the data warehouse.{" "}
          <span className="text-zinc-600">
            Cached {new Date(catalog.generatedAt).toLocaleString()}.
          </span>
        </p>
        {githubUrl && (
          <a
            href={githubUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="shrink-0 rounded-lg border border-zinc-600 px-3 py-1.5 text-sm text-zinc-300 hover:bg-zinc-800"
          >
            View on GitHub ↗
          </a>
        )}
      </div>

      {err && (
        <p className="mb-4 rounded-lg border border-amber-700 bg-amber-950/40 p-3 text-sm text-amber-300">
          {err}
        </p>
      )}
      {!err && body == null && <p className="text-base text-zinc-500">Loading…</p>}

      {hasLineage && (
        <div className="mb-4 rounded-lg border border-zinc-700 bg-zinc-900 p-4">
          <p className="mb-3 text-sm font-semibold text-zinc-200">
            Upstream lineage — tables this model reads from
          </p>
          {refs.sources.length > 0 && (
            <div className="mb-3">
              <p className="mb-1.5 text-xs font-semibold uppercase tracking-wider text-zinc-500">
                Raw / stage sources ({refs.sources.length})
              </p>
              <ul className="grid grid-cols-1 gap-1 sm:grid-cols-2">
                {refs.sources.map((s) => (
                  <li key={s}>
                    <code className="text-sm text-amber-300">{s}</code>
                  </li>
                ))}
              </ul>
            </div>
          )}
          {refs.refs.length > 0 && (
            <div>
              <p className="mb-1.5 text-xs font-semibold uppercase tracking-wider text-zinc-500">
                dbt model refs / intermediate ({refs.refs.length})
              </p>
              <ul className="flex flex-wrap gap-x-4 gap-y-1">
                {refs.refs.map((r) => (
                  <li key={r}>
                    <code className="text-sm text-sky-300">{r}</code>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      )}

      {body != null && (
        <pre className="max-h-[60vh] overflow-auto whitespace-pre-wrap rounded-lg border border-zinc-800 bg-zinc-950 p-4 font-mono text-sm leading-relaxed text-zinc-200">
          {body}
        </pre>
      )}
    </Modal>
  );
}

type DisplayRow =
  | { type: "card"; entry: CatalogEntry }
  | {
      type: "dashboard";
      key: string;
      dashboardId: string;
      dashboardName: string;
      metric: SheetMetric;
      cards: CatalogEntry[];
    };

export default function MetricsPage() {
  const [q, setQ] = useState("");
  const [dash, setDash] = useState("");
  const [drhpOnly, setDrhpOnly] = useState(true);
  const [selected, setSelected] = useState<CatalogEntry | null>(null);
  const [sqlOpen, setSqlOpen] = useState(false);
  const [sqlBody, setSqlBody] = useState<string | null>(null);
  const [sqlErr, setSqlErr] = useState<string | null>(null);
  const [dbtSqlOpen, setDbtSqlOpen] = useState(false);
  const [dbtSqlLabel, setDbtSqlLabel] = useState("");
  const [dbtSqlBody, setDbtSqlBody] = useState<string | null>(null);
  const [dbtSqlErr, setDbtSqlErr] = useState<string | null>(null);
  const [dbtSqlRefs, setDbtSqlRefs] = useState<DbtSqlRefs | null>(null);
  const [dbtSqlGithubUrl, setDbtSqlGithubUrl] = useState<string | undefined>(undefined);
  const [notebookOpen, setNotebookOpen] = useState(false);
  const [notebookLabel, setNotebookLabel] = useState("");
  const [notebookBody, setNotebookBody] = useState<string | null>(null);
  const [notebookErr, setNotebookErr] = useState<string | null>(null);
  const [notebookGithubUrl, setNotebookGithubUrl] = useState<string | undefined>(undefined);
  const sqlForEntry = useRef<CatalogEntry | null>(null);
  const tableScrollRef = useRef<HTMLDivElement | null>(null);

  const dashboards = useMemo(() => {
    const set = new Set<string>();
    for (const e of catalog.entries) {
      if (e.dashboardName) set.add(e.dashboardName);
    }
    return [...set].sort((a, b) => a.localeCompare(b));
  }, []);

  const drhpCount = useMemo(() => {
    const seen = new Set<string>();
    for (const e of catalog.entries) {
      if (!e.sheetMetric) continue;
      const key =
        e.sheetMetricVia === "dashboard" && e.dashboardId
          ? `dash:${e.dashboardId}`
          : `card:${e.cardId}`;
      seen.add(key);
    }
    return seen.size;
  }, []);

  const displayRows = useMemo((): DisplayRow[] => {
    const qq = q.trim().toLowerCase();

    const matchEntry = (e: CatalogEntry) => {
      if (drhpOnly && !e.sheetMetric) return false;
      if (dash && e.dashboardName !== dash) return false;
      if (!qq) return true;
      return (
        e.name.toLowerCase().includes(qq) ||
        e.cardId.includes(qq) ||
        (e.dashboardName?.toLowerCase().includes(qq) ?? false) ||
        (e.sheetMetric?.metricName.toLowerCase().includes(qq) ?? false)
      );
    };

    const matched = catalog.entries.filter(matchEntry);

    if (!drhpOnly) {
      // Non-DRHP view: flat sorted list
      return matched
        .sort((a, b) => a.name.localeCompare(b.name, undefined, { sensitivity: "base" }))
        .map((e) => ({ type: "card" as const, entry: e }));
    }

    // DRHP view: group dashboard cards, sort by sheetOrder
    const dashboardGroups = new Map<
      string,
      { dashboardId: string; dashboardName: string; metric: SheetMetric; cards: CatalogEntry[] }
    >();
    const cardRows: DisplayRow[] = [];

    for (const e of matched) {
      if (e.sheetMetricVia === "dashboard" && e.dashboardId && e.sheetMetric) {
        const existing = dashboardGroups.get(e.dashboardId);
        if (existing) {
          existing.cards.push(e);
        } else {
          dashboardGroups.set(e.dashboardId, {
            dashboardId: e.dashboardId,
            dashboardName: e.dashboardName ?? e.dashboardId,
            metric: e.sheetMetric,
            cards: [e],
          });
        }
      } else {
        cardRows.push({ type: "card" as const, entry: e });
      }
    }

    const allRows: DisplayRow[] = [
      ...cardRows,
      ...[...dashboardGroups.values()].map((g) => ({
        type: "dashboard" as const,
        key: `dash:${g.dashboardId}`,
        ...g,
      })),
    ];

    // Sort by sheetOrder (position in the DRHP sheet)
    return allRows.sort((a, b) => {
      const ao = a.type === "card" ? (a.entry.sheetMetric?.sheetOrder ?? 999) : a.metric.sheetOrder;
      const bo = b.type === "card" ? (b.entry.sheetMetric?.sheetOrder ?? 999) : b.metric.sheetOrder;
      return ao - bo;
    });
  }, [q, dash, drhpOnly]);

  const loadSql = useCallback((entry: CatalogEntry) => {
    if (!entry.paths.query) return;
    sqlForEntry.current = entry;
    setSqlErr(null);
    setSqlBody(null);
    fetchText(entry.paths.query)
      .then(setSqlBody)
      .catch((e: Error) => setSqlErr(e.message));
  }, []);

  const handleOpenSql = useCallback(
    (entry: CatalogEntry) => {
      setSelected(entry);
      setSqlOpen(true);
      loadSql(entry);
    },
    [loadSql],
  );

  useEffect(() => {
    if (sqlOpen && selected?.paths.query && sqlForEntry.current?.cardId !== selected.cardId) {
      loadSql(selected);
    }
  }, [sqlOpen, selected, loadSql]);

  // When an entry is selected from deep in the list, scroll that row into view
  useEffect(() => {
    if (!selected) return;
    const row = tableScrollRef.current?.querySelector(`[data-card-id="${selected.cardId}"]`);
    row?.scrollIntoView({ block: "nearest", behavior: "smooth" });
  }, [selected]);

  const handleViewNotebook = useCallback((localUrl: string, label: string, githubUrl?: string) => {
    setNotebookLabel(label);
    setNotebookBody(null);
    setNotebookErr(null);
    setNotebookGithubUrl(githubUrl);
    setNotebookOpen(true);
    fetch(localUrl)
      .then((res) => {
        if (!res.ok) throw new Error(`${res.status} — try running npm run generate to download notebooks`);
        return res.text();
      })
      .then(setNotebookBody)
      .catch((e: Error) => setNotebookErr(e.message));
  }, []);

  const handleViewDbtSql = useCallback((localUrl: string, label: string, githubUrl?: string) => {
    setDbtSqlLabel(label);
    setDbtSqlBody(null);
    setDbtSqlErr(null);
    setDbtSqlRefs(null);
    setDbtSqlGithubUrl(githubUrl);
    setDbtSqlOpen(true);
    fetch(localUrl)
      .then((res) => {
        if (!res.ok) throw new Error(`${res.status} fetching ${localUrl} — try rebuilding (npm run dev) to download SQL files`);
        return res.text();
      })
      .then((text) => {
        setDbtSqlBody(text);
        setDbtSqlRefs(parseDbtRefs(text));
      })
      .catch((e: Error) => setDbtSqlErr(e.message));
  }, []);

  return (
    <div className="flex h-full min-h-0 w-full flex-col lg:flex-row">
      <div className="flex min-h-0 min-w-0 flex-1 flex-col overflow-hidden">
        <header className="border-b border-zinc-800 bg-zinc-900/80 px-6 py-8">
          <p className="text-sm font-semibold uppercase tracking-widest text-emerald-500/90">
            Curefit · Auditor handoff
          </p>
          <h1 className="mt-2 text-3xl font-bold tracking-tight text-white md:text-4xl">
            Metrics, definitions & lineage
          </h1>
          <p className="mt-4 max-w-2xl text-base leading-relaxed text-zinc-400">
            Read-only: Metabase metadata, exported SQL, lineage docs, and optional links to dbt model source
            on GitHub. Nothing in this app executes queries or dbt.
          </p>
          <p className="mt-3 text-sm text-zinc-600">
            Catalog {new Date(catalog.generatedAt).toLocaleString()} · {catalog.count} cards
            {catalog.dbt?.enabled && (
              <>
                {" "}
                · dbt index {catalog.dbt.modelSqlFileCount} models (
                <span className="text-zinc-500">
                  {catalog.dbt.owner}/{catalog.dbt.repo}
                </span>
                )
              </>
            )}
          </p>
        </header>

        <div className="flex flex-wrap items-end gap-4 border-b border-zinc-800 bg-zinc-900/40 px-6 py-5">
          <label className="flex min-w-[14rem] flex-1 flex-col gap-2 text-sm text-zinc-500">
            Search
            <input
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="Name, card id, dashboard…"
              className="rounded-lg border border-zinc-700 bg-zinc-950 px-3 py-2.5 text-base text-white placeholder:text-zinc-600 focus:border-emerald-600 focus:outline-none focus:ring-1 focus:ring-emerald-600"
            />
          </label>
          <label className="flex w-full min-w-[12rem] flex-col gap-2 text-sm text-zinc-500 sm:w-60">
            Dashboard
            <select
              value={dash}
              onChange={(e) => setDash(e.target.value)}
              className="rounded-lg border border-zinc-700 bg-zinc-950 px-3 py-2.5 text-base text-white focus:border-emerald-600 focus:outline-none focus:ring-1 focus:ring-emerald-600"
            >
              <option value="">All</option>
              {dashboards.map((d) => (
                <option key={d} value={d}>
                  {d}
                </option>
              ))}
            </select>
          </label>
          <div className="flex flex-col gap-2 text-sm text-zinc-500">
            Filter
            <button
              type="button"
              onClick={() => setDrhpOnly((v) => !v)}
              className={`rounded-lg border px-4 py-2.5 text-base font-medium transition-colors ${
                drhpOnly
                  ? "border-indigo-600 bg-indigo-900/50 text-indigo-200 hover:bg-indigo-900/70"
                  : "border-zinc-700 bg-zinc-950 text-zinc-400 hover:bg-zinc-900"
              }`}
            >
              {drhpOnly ? `DRHP only (${drhpCount})` : `All metrics (${catalog.count})`}
            </button>
          </div>
        </div>

        <div ref={tableScrollRef} className="min-h-0 flex-1 overflow-auto">
          <table className="w-full border-collapse text-left text-base">
            <thead className="sticky top-0 z-10 bg-zinc-900/95 backdrop-blur">
              <tr className="border-b border-zinc-800 text-sm uppercase tracking-wide text-zinc-500">
                <th className="px-6 py-4 font-medium">Metric</th>
                <th className="hidden px-3 py-4 font-medium md:table-cell">Card</th>
                <th className="hidden px-3 py-4 font-medium lg:table-cell">Dashboard</th>
                <th className="px-4 py-4 font-medium">Actions</th>
              </tr>
            </thead>
            <tbody>
              {displayRows.map((row) => {
                if (row.type === "dashboard") {
                  return (
                    <DashboardGroup
                      key={row.key}
                      metric={row.metric}
                      dashboardId={row.dashboardId}
                      dashboardName={row.dashboardName}
                      cards={row.cards}
                      selected={selected}
                      onSelect={setSelected}
                      onOpenMetabase={(url) => window.open(url, "_blank")}
                      onOpenSql={handleOpenSql}
                    />
                  );
                }

                const e = row.entry;
                return (
                  <tr
                    key={e.cardId}
                    data-card-id={e.cardId}
                    className={`border-b border-zinc-800/80 hover:bg-zinc-900/60 ${
                      selected?.cardId === e.cardId ? "bg-emerald-950/20" : ""
                    }`}
                  >
                    <td className="px-6 py-4">
                      <button
                        type="button"
                        onClick={() => setSelected(e)}
                        className="text-left text-lg font-medium text-zinc-100 hover:text-emerald-400"
                      >
                        {e.sheetMetric ? e.sheetMetric.metricName : e.name}
                      </button>
                      {e.sheetMetric && (
                        <div className="mt-1 flex flex-wrap items-center gap-2">
                          <span className="rounded-full bg-indigo-800/60 px-2 py-0.5 text-xs font-semibold text-indigo-300">
                            DRHP #{e.sheetMetric.slNo}
                          </span>
                          {e.sheetMetric.units && (
                            <span className="text-xs text-zinc-500">{e.sheetMetric.units}</span>
                          )}
                          {e.sheetMetric.fy26 && (
                            <span className="text-xs text-zinc-400">
                              FY26:{" "}
                              <span className="font-medium text-zinc-200">{e.sheetMetric.fy26}</span>
                            </span>
                          )}
                        </div>
                      )}
                    </td>
                    <td className="hidden px-3 py-4 font-mono text-sm text-zinc-500 md:table-cell">
                      {e.cardId}
                    </td>
                    <td className="hidden max-w-[16rem] truncate px-3 py-4 text-sm text-zinc-500 lg:table-cell">
                      {e.dashboardName ?? "—"}
                    </td>
                    <td className="px-4 py-4">
                      <div className="flex flex-wrap gap-2">
                        <a
                          href={
                            e.metabaseCardUrl ??
                            `https://metabase.curefit.co/question/${e.cardId}`
                          }
                          target="_blank"
                          rel="noopener noreferrer"
                          className="rounded-md border border-emerald-700/80 bg-emerald-950/40 px-3 py-1.5 text-sm font-medium text-emerald-200 hover:bg-emerald-900/50"
                        >
                          Metabase
                        </a>
                        <button
                          type="button"
                          onClick={() => setSelected(e)}
                          className="rounded-md border border-zinc-700 px-3 py-1.5 text-sm text-zinc-300 hover:bg-zinc-800"
                        >
                          Overview
                        </button>
                        {e.paths.query && (
                          <button
                            type="button"
                            onClick={() => handleOpenSql(e)}
                            className="rounded-md bg-emerald-700/80 px-3 py-1.5 text-sm text-white hover:bg-emerald-600"
                          >
                            SQL
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
          {displayRows.length === 0 && (
            <p className="px-6 py-12 text-center text-base text-zinc-500">
              No metrics match your filters.
            </p>
          )}
        </div>
      </div>

      {selected && (
        <DetailPanel
          entry={selected}
          onClose={() => {
            setSelected(null);
            setSqlOpen(false);
          }}
          onShowSql={() => setSqlOpen(true)}
          onViewDbtSql={handleViewDbtSql}
          onViewNotebook={handleViewNotebook}
        />
      )}

      {sqlOpen && (
        <Modal title="Exported SQL (Metabase)" onClose={() => setSqlOpen(false)} wide>
          {sqlErr && <p className="text-base text-amber-400">{sqlErr}</p>}
          {!sqlErr && sqlBody == null && <p className="text-base text-zinc-500">Loading…</p>}
          {sqlBody != null && (
            <pre className="whitespace-pre-wrap font-mono text-sm leading-relaxed text-zinc-200 md:text-base">
              {sqlBody}
            </pre>
          )}
        </Modal>
      )}


      {notebookOpen && (
        <NotebookModal
          label={notebookLabel}
          body={notebookBody}
          err={notebookErr}
          githubUrl={notebookGithubUrl}
          onClose={() => {
            setNotebookOpen(false);
            setNotebookBody(null);
            setNotebookGithubUrl(undefined);
          }}
        />
      )}

      {dbtSqlOpen && (
        <DbtSqlModal
          label={dbtSqlLabel}
          body={dbtSqlBody}
          err={dbtSqlErr}
          refs={dbtSqlRefs}
          githubUrl={dbtSqlGithubUrl}
          onClose={() => {
            setDbtSqlOpen(false);
            setDbtSqlBody(null);
            setDbtSqlRefs(null);
            setDbtSqlGithubUrl(undefined);
          }}
        />
      )}
    </div>
  );
}

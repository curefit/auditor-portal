import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { Modal } from "../components/Modal";
import type { Catalog, CatalogEntry, DrhpMilestone, SqlLineageRelation } from "../types";
import rawCatalog from "../catalog.json";

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

function milestoneDisplayDate(milestone: DrhpMilestone): string {
  if (milestone.milestoneDate && milestone.milestoneYear) {
    return `${milestone.milestoneDate} (${milestone.milestoneYear})`;
  }
  return milestone.milestoneDate || milestone.milestoneYear || "—";
}

function MilestoneSection({ milestone }: { milestone: DrhpMilestone }) {
  return (
    <div className="rounded-xl border border-amber-700/50 bg-amber-950/25 p-5">
      <div className="mb-3 flex flex-wrap items-center gap-2">
        <span className="rounded-full bg-amber-600/80 px-2.5 py-0.5 text-xs font-semibold uppercase tracking-wider text-amber-100">
          DRHP Milestone
        </span>
        <span className="text-xs text-amber-400/80">Milestone #{milestone.slNo}</span>
        {milestone.status && (
          <span
            className={`rounded-full px-2.5 py-0.5 text-xs font-medium ${
              milestone.status === "Done"
                ? "bg-emerald-900/60 text-emerald-300"
                : "bg-amber-900/60 text-amber-300"
            }`}
          >
            {milestone.status}
          </span>
        )}
      </div>

      <h3 className="text-base font-semibold text-white">{milestone.particulars}</h3>

      <div className="mt-4 overflow-x-auto">
        <table className="w-full border-collapse text-sm">
          <thead>
            <tr className="border-b border-amber-800/60">
              {milestone.milestoneDate && (
                <th className="px-3 py-1.5 text-left text-xs font-semibold uppercase tracking-wide text-amber-400">
                  Date
                </th>
              )}
              <th className="px-3 py-1.5 text-left text-xs font-semibold uppercase tracking-wide text-amber-400">
                Year
              </th>
            </tr>
          </thead>
          <tbody>
            <tr>
              {milestone.milestoneDate && (
                <td className="px-3 py-1.5 font-mono text-sm text-zinc-200">
                  {milestone.milestoneDate}
                </td>
              )}
              <td className="px-3 py-1.5 font-mono text-sm text-zinc-200">
                {milestone.milestoneYear || "—"}
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div className="mt-4 flex flex-wrap gap-x-6 gap-y-1.5 text-sm">
        {milestone.poc && (
          <span className="text-zinc-400">
            PoC: <span className="text-zinc-200">{milestone.poc}</span>
          </span>
        )}
        {milestone.limitations && (
          <span className="text-zinc-400">
            Limitations: <span className="text-amber-300/90">{milestone.limitations}</span>
          </span>
        )}
      </div>
    </div>
  );
}

type MetaCard = {
  name?: string;
  description?: string | null;
  display?: string;
  created_at?: string;
  creator?: { common_name?: string; email?: string };
  collection?: { name?: string };
  result_metadata?: Array<{ display_name?: string; base_type?: string; name?: string }>;
};

function MetaCardView({ meta }: { meta: MetaCard }) {
  const columns = meta.result_metadata ?? [];
  return (
    <div className="space-y-4 text-sm">
      {meta.description && <p className="leading-relaxed text-zinc-300">{meta.description}</p>}
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
            Created: <span className="text-zinc-200">{new Date(meta.created_at).toLocaleDateString()}</span>
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

function RelationRow({ relation }: { relation: SqlLineageRelation }) {
  const modelLinks = relation.dbtModelPaths.map((path, i) => ({
    path,
    githubUrl: relation.githubBlobUrls[i],
  }));
  const notebookLinks = relation.fallbackModelPaths.map((path, i) => ({
    path,
    githubUrl: relation.fallbackGithubBlobUrls[i],
  }));

  return (
    <li className="rounded-lg border border-zinc-800 bg-zinc-950/80 p-3 text-base">
      <code className="font-mono text-emerald-300">{relation.relation}</code>
      {modelLinks.length > 0 && (
        <ul className="mt-2 space-y-1.5 text-sm">
          {modelLinks.map(({ path, githubUrl }) => (
            <li key={path} className="flex flex-wrap items-center gap-2">
              <span className="break-all text-sky-400">{path.split("/").pop() ?? path}</span>
              {githubUrl && (
                <a
                  href={githubUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="rounded bg-zinc-800 px-2 py-0.5 text-xs text-zinc-400 hover:bg-zinc-700 hover:text-zinc-200"
                >
                  GitHub ↗
                </a>
              )}
            </li>
          ))}
        </ul>
      )}
      {modelLinks.length === 0 && notebookLinks.length > 0 && (
        <ul className="mt-2 space-y-1.5 text-sm">
          {notebookLinks.map(({ path, githubUrl }) => (
            <li key={path} className="flex flex-wrap items-center gap-2">
              <span className="break-all text-amber-400">{path.split("/").pop() ?? path}</span>
              <span className="text-xs text-zinc-600">(notebook)</span>
              {githubUrl && (
                <a
                  href={githubUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="rounded bg-zinc-800 px-2 py-0.5 text-xs text-zinc-400 hover:bg-zinc-700 hover:text-zinc-200"
                >
                  GitHub ↗
                </a>
              )}
            </li>
          ))}
        </ul>
      )}
      {modelLinks.length === 0 && notebookLinks.length === 0 && (
        <p className="mt-2 text-sm text-zinc-500">No matching dbt model or notebook found.</p>
      )}
    </li>
  );
}

function DetailPanel({
  entry,
  onClose,
  onShowSql,
}: {
  entry: CatalogEntry;
  onClose: () => void;
  onShowSql: () => void;
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
        {entry.milestone && (
          <section>
            <MilestoneSection milestone={entry.milestone} />
          </section>
        )}

        <section>
          <h3 className="mb-2 text-base font-semibold text-zinc-300">Tables / relations (from SQL)</h3>
          <p className="mb-3 text-sm leading-relaxed text-zinc-500">
            Parsed from the exported Metabase SQL. Source links are matched at catalog build time when
            dbt or notebook matches are available.
          </p>
          {(entry.sqlLineageRelations ?? []).length === 0 ? (
            <p className="text-base text-zinc-500">No qualified relations detected in SQL.</p>
          ) : (
            <ul className="space-y-3">
              {(entry.sqlLineageRelations ?? []).map((relation) => (
                <RelationRow key={relation.relation} relation={relation} />
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
              {entry.results.map((result) => (
                <li key={result}>
                  <a
                    href={handoffUrl(result)}
                    target="_blank"
                    rel="noreferrer"
                    className="text-emerald-400 hover:underline"
                  >
                    {result.replace(/^artifacts\/results\//, "")}
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

export default function MilestonesPage() {
  const [q, setQ] = useState("");
  const [selected, setSelected] = useState<CatalogEntry | null>(null);
  const [sqlOpen, setSqlOpen] = useState(false);
  const [sqlBody, setSqlBody] = useState<string | null>(null);
  const [sqlErr, setSqlErr] = useState<string | null>(null);
  const sqlForEntry = useRef<CatalogEntry | null>(null);
  const tableScrollRef = useRef<HTMLDivElement | null>(null);

  const milestones = useMemo(() => {
    const qq = q.trim().toLowerCase();
    return catalog.entries
      .filter((entry) => {
        if (!entry.milestone) return false;
        if (!qq) return true;
        return (
          entry.cardId.includes(qq) ||
          entry.name.toLowerCase().includes(qq) ||
          entry.milestone.particulars.toLowerCase().includes(qq) ||
          entry.milestone.milestoneYear.includes(qq) ||
          entry.milestone.milestoneDate.toLowerCase().includes(qq)
        );
      })
      .sort((a, b) => {
        const ao = a.milestone?.milestoneOrder ?? 999;
        const bo = b.milestone?.milestoneOrder ?? 999;
        return ao - bo;
      });
  }, [q]);

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

  useEffect(() => {
    if (!selected) return;
    const selectedKey = selected.entryKey ?? selected.cardId;
    const row = tableScrollRef.current?.querySelector(`[data-card-id="${selectedKey}"]`);
    row?.scrollIntoView({ block: "nearest", behavior: "smooth" });
  }, [selected]);

  return (
    <div className="flex h-full min-h-0 w-full flex-col lg:flex-row">
      <div className="flex min-h-0 min-w-0 flex-1 flex-col overflow-hidden">
        <header className="border-b border-zinc-800 bg-zinc-900/80 px-6 py-8">
          <p className="text-sm font-semibold uppercase tracking-widest text-amber-500/90">
            Curefit · DRHP
          </p>
          <h1 className="mt-2 text-3xl font-bold tracking-tight text-white md:text-4xl">
            Milestones & audit proof
          </h1>
          <p className="mt-4 max-w-2xl text-base leading-relaxed text-zinc-400">
            Read-only milestone validation: each milestone links to the Metabase query, exported SQL,
            metadata, result files when available, and parsed source lineage.
          </p>
          <p className="mt-3 text-sm text-zinc-600">
            Catalog {new Date(catalog.generatedAt).toLocaleString()} · {milestones.length} milestones
          </p>
        </header>

        <div className="flex flex-wrap items-end gap-4 border-b border-zinc-800 bg-zinc-900/40 px-6 py-5">
          <label className="flex min-w-[14rem] flex-1 flex-col gap-2 text-sm text-zinc-500">
            Search
            <input
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="Milestone, card id, year…"
              className="rounded-lg border border-zinc-700 bg-zinc-950 px-3 py-2.5 text-base text-white placeholder:text-zinc-600 focus:border-amber-600 focus:outline-none focus:ring-1 focus:ring-amber-600"
            />
          </label>
        </div>

        <div ref={tableScrollRef} className="min-h-0 flex-1 overflow-auto">
          <table className="w-full border-collapse text-left text-base">
            <thead className="sticky top-0 z-10 bg-zinc-900/95 backdrop-blur">
              <tr className="border-b border-zinc-800 text-sm uppercase tracking-wide text-zinc-500">
                <th className="px-6 py-4 font-medium">Milestone</th>
                <th className="hidden px-3 py-4 font-medium md:table-cell">Card</th>
                <th className="hidden px-3 py-4 font-medium lg:table-cell">Year / Date</th>
                <th className="px-4 py-4 font-medium">Actions</th>
              </tr>
            </thead>
            <tbody>
              {milestones.map((entry) => {
                const milestone = entry.milestone;
                if (!milestone) return null;
                return (
                  <tr
                    key={entry.entryKey ?? entry.cardId}
                    data-card-id={entry.entryKey ?? entry.cardId}
                    className={`border-b border-zinc-800/80 hover:bg-zinc-900/60 ${
                      (selected?.entryKey ?? selected?.cardId) === (entry.entryKey ?? entry.cardId)
                        ? "bg-emerald-950/20"
                        : ""
                    }`}
                  >
                    <td className="px-6 py-4">
                      <button
                        type="button"
                        onClick={() => setSelected(entry)}
                        className="text-left text-lg font-medium text-zinc-100 hover:text-amber-400"
                      >
                        {milestone.particulars}
                      </button>
                      <div className="mt-1 flex flex-wrap items-center gap-2">
                        <span className="rounded-full bg-amber-800/60 px-2 py-0.5 text-xs font-semibold text-amber-300">
                          DRHP Milestone #{milestone.slNo}
                        </span>
                        <span className="text-xs text-zinc-400">
                          {milestoneDisplayDate(milestone)}
                        </span>
                      </div>
                    </td>
                    <td className="hidden px-3 py-4 font-mono text-sm text-zinc-500 md:table-cell">
                      {entry.cardId}
                    </td>
                    <td className="hidden px-3 py-4 font-mono text-sm text-zinc-300 lg:table-cell">
                      {milestoneDisplayDate(milestone)}
                    </td>
                    <td className="px-4 py-4">
                      <div className="flex flex-wrap gap-2">
                        <a
                          href={
                            entry.metabaseCardUrl ??
                            `https://metabase.curefit.co/question/${entry.cardId}`
                          }
                          target="_blank"
                          rel="noopener noreferrer"
                          className="rounded-md border border-emerald-700/80 bg-emerald-950/40 px-3 py-1.5 text-sm font-medium text-emerald-200 hover:bg-emerald-900/50"
                        >
                          Metabase
                        </a>
                        <button
                          type="button"
                          onClick={() => setSelected(entry)}
                          className="rounded-md border border-zinc-700 px-3 py-1.5 text-sm text-zinc-300 hover:bg-zinc-800"
                        >
                          Overview
                        </button>
                        {entry.paths.query && (
                          <button
                            type="button"
                            onClick={() => handleOpenSql(entry)}
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
          {milestones.length === 0 && (
            <p className="px-6 py-12 text-center text-base text-zinc-500">
              No milestones match your filters.
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

    </div>
  );
}

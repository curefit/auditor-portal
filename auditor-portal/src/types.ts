export type CatalogPaths = {
  query: string | null;
  metadata: string | null;
  lineageMarkdown: string | null;
  outputPreviewHtml: string | null;
  lineagePreviewHtml: string | null;
};

/** One relation (schema.table) from SQL, matched to dbt model paths on GitHub at build time. */
export type SqlLineageRelation = {
  relation: string;
  /** Primary dbt repo — SQL model files */
  dbtModelPaths: string[];
  githubBlobUrls: string[];
  /** Static local URLs served from public/dbt-sql/ (downloaded at build time — no auth needed) */
  localSqlUrls: string[];
  /** Fallback repo — Jupyter notebooks (ipynb) when no SQL match found */
  fallbackModelPaths: string[];
  fallbackGithubBlobUrls: string[];
  /** Static local URLs served from public/dbt-notebooks/ (downloaded at build time) */
  fallbackLocalUrls?: string[];
};

export type CatalogDbt = {
  enabled: boolean;
  owner: string;
  repo: string;
  ref: string;
  modelSqlFileCount: number;
  /** Set when fetch failed or repo not configured */
  fetchNote?: string;
};

/** Metadata sourced from the DRHP op-metrics Google Sheet */
export type SheetMetric = {
  /** 0-based position in the sheet — used to sort the portal list in sheet order */
  sheetOrder: number;
  slNo: string;
  metricName: string;
  definition: string;
  status: string;
  poc: string;
  units: string;
  fy23: string;
  fy24: string;
  fy25: string;
  fy26: string;
  nineMFy25: string;
  nineMFy26: string;
  limitations: string;
  sourceRaw: string;
};

/** Metadata sourced from the DRHP milestones sheet */
export type DrhpMilestone = {
  /** 0-based position in the sheet — used to sort the milestones list */
  milestoneOrder: number;
  slNo: string;
  particulars: string;
  milestoneYear: string;
  milestoneDate: string;
  status: string;
  poc: string;
  limitations: string;
  sourceRaw: string;
};

export type CatalogEntry = {
  entryKey?: string;
  cardId: string;
  name: string;
  rootKey: string;
  rootAssetName: string | null;
  dashboardId: string | null;
  dashboardName: string | null;
  /** Metabase saved question / card (read-only in browser). */
  metabaseCardUrl?: string;
  /** Original question or dashboard URL from handoff CSV when available. */
  metabaseRootSourceUrl?: string | null;
  paths: CatalogPaths;
  results: string[];
  sqlLineageRelations?: SqlLineageRelation[];
  /** Present when this card appears in the DRHP op-metrics sheet with a Metabase link */
  sheetMetric?: SheetMetric | null;
  /** How sheetMetric was matched: 'card' = direct question ID, 'dashboard' = via dashboard ID */
  sheetMetricVia?: "card" | "dashboard" | null;
  /** Present when this card appears in the DRHP milestones sheet with a Metabase link */
  milestone?: DrhpMilestone | null;
  /** How milestone was matched: 'card' = direct question ID, 'dashboard' = via dashboard ID */
  milestoneVia?: "card" | "dashboard" | null;
};

export type Catalog = {
  generatedAt: string;
  basePath: string;
  count: number;
  entries: CatalogEntry[];
  dbt?: CatalogDbt;
};

export type DbtModelsIndexFile = {
  paths: string[];
};

export type DbtConfigFile = {
  enabled: boolean;
  owner?: string;
  repo?: string;
  ref?: string;
  modelSqlFileCount?: number;
  fetchNote?: string;
  hint?: string;
  fallback?: {
    enabled: boolean;
    owner?: string;
    repo?: string;
    ref?: string;
    modelNotebookCount?: number;
    fetchNote?: string;
  };
};

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom";
import RootLayout from "./layout/RootLayout";
import DbtModelsPage from "./pages/DbtModelsPage";
import MetricsPage from "./pages/MetricsPage";
import MilestonesPage from "./pages/MilestonesPage";
import "./index.css";

const basename = import.meta.env.BASE_URL.replace(/\/$/, "") || undefined;

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <BrowserRouter basename={basename}>
      <Routes>
        <Route element={<RootLayout />}>
          <Route index element={<MetricsPage />} />
          <Route path="milestones" element={<MilestonesPage />} />
          <Route path="dbt-models" element={<DbtModelsPage />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Route>
      </Routes>
    </BrowserRouter>
  </StrictMode>,
);

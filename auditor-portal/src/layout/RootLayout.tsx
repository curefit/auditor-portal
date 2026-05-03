import { useState } from "react";
import { NavLink, Outlet } from "react-router-dom";
import { isAuthed, PasswordGate } from "../auth";

const navCls = ({ isActive }: { isActive: boolean }) =>
  `rounded-lg px-4 py-2 text-base font-medium transition-colors ${
    isActive
      ? "bg-emerald-900/50 text-emerald-200"
      : "text-zinc-400 hover:bg-zinc-800 hover:text-white"
  }`;

export default function RootLayout() {
  const [authed, setAuthed] = useState(isAuthed);

  if (!authed) {
    return <PasswordGate onUnlock={() => setAuthed(true)} />;
  }

  return (
    <div className="flex h-screen flex-col overflow-hidden">
      <nav className="flex flex-wrap items-center gap-2 border-b border-zinc-800 bg-zinc-900 px-6 py-3">
        <span className="mr-4 text-base font-semibold text-white">Auditor portal</span>
        <NavLink to="/" className={navCls} end>
          Metrics
        </NavLink>
        <NavLink to="/dbt-models" className={navCls}>
          Model Source Code
        </NavLink>
        <p className="ml-auto max-w-xl text-sm text-zinc-500">
          Read-only views: no queries or pipelines run from this UI.
        </p>
      </nav>
      <div className="flex min-h-0 flex-1 overflow-hidden">
        <Outlet />
      </div>
    </div>
  );
}

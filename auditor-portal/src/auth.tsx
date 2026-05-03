import { useState } from "react";

// NOTE: This is a UX speed-bump, not real security. The password is embedded
// in the compiled JS bundle and can be found by anyone who inspects the source.
// It stops casual visitors but not a determined person. See docs/superpowers/plans
// for the Cloudflare Access migration plan if stronger auth is needed later.
//
// Set VITE_ACCESS_PASSWORD in the GitHub Actions workflow (or .env.production)
// to rotate the password without touching this file.
const ACCESS_PASSWORD = import.meta.env.VITE_ACCESS_PASSWORD ?? "curefit2026";
const SESSION_KEY = "auditor_authed";
const SESSION_EMAIL_KEY = "auditor_visitor_email";

// Read webhook URL from build-time env so it's empty in local dev and only
// active in the deployed build. Set VITE_VISITOR_WEBHOOK_URL in the GitHub
// Actions workflow (or .env.production) to enable visitor logging.
const VISITOR_WEBHOOK_URL = import.meta.env.VITE_VISITOR_WEBHOOK_URL ?? "";

function logVisitor(email: string) {
  sessionStorage.setItem(SESSION_EMAIL_KEY, email);
  if (VISITOR_WEBHOOK_URL) {
    // keepalive: true ensures the request completes even if the user navigates
    // away immediately after unlocking.
    fetch(VISITOR_WEBHOOK_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, timestamp: new Date().toISOString() }),
      keepalive: true,
    }).catch(() => {
      // fire-and-forget; don't block the user if this fails
    });
  }
}

export function isAuthed(): boolean {
  return sessionStorage.getItem(SESSION_KEY) === "1";
}

export function PasswordGate({ onUnlock }: { onUnlock: () => void }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState(false);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (password === ACCESS_PASSWORD) {
      logVisitor(email.trim());
      sessionStorage.setItem(SESSION_KEY, "1");
      onUnlock();
    } else {
      setError(true);
      setPassword("");
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-zinc-950 px-4">
      <div className="w-full max-w-sm rounded-xl border border-zinc-800 bg-zinc-900 p-8 shadow-2xl">
        <p className="text-xs font-semibold uppercase tracking-widest text-emerald-500/90">
          Curefit · Auditor handoff
        </p>
        <h1 className="mt-3 text-2xl font-bold text-white">Enter password</h1>
        <p className="mt-2 text-sm text-zinc-400">
          This portal is password-protected. Your email will be recorded on entry.
        </p>
        <form onSubmit={handleSubmit} className="mt-6 flex flex-col gap-4">
          <label className="flex flex-col gap-1 text-xs text-zinc-400">
            Email
            <input
              id="gate-email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@example.com"
              required
              autoFocus
              className="rounded-lg border border-zinc-700 bg-zinc-950 px-3 py-2.5 text-sm text-white placeholder:text-zinc-600 focus:border-emerald-600 focus:outline-none focus:ring-1 focus:ring-emerald-600"
            />
          </label>
          <label className="flex flex-col gap-1 text-xs text-zinc-400">
            Password
            <input
              id="gate-password"
              type="password"
              value={password}
              onChange={(e) => {
                setPassword(e.target.value);
                setError(false);
              }}
              placeholder="Password"
              aria-invalid={error}
              aria-describedby={error ? "gate-error" : undefined}
              className={`rounded-lg border bg-zinc-950 px-3 py-2.5 text-sm text-white placeholder:text-zinc-600 focus:outline-none focus:ring-1 ${
                error
                  ? "border-red-500 focus:border-red-500 focus:ring-red-500"
                  : "border-zinc-700 focus:border-emerald-600 focus:ring-emerald-600"
              }`}
            />
          </label>
          {error && (
            <p id="gate-error" role="alert" className="text-sm text-red-400">
              Incorrect password. Try again.
            </p>
          )}
          <button
            type="submit"
            className="rounded-lg bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-emerald-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 focus:ring-offset-zinc-900"
          >
            Unlock
          </button>
        </form>
      </div>
    </div>
  );
}

import { useState } from "react";

const ACCESS_PASSWORD = "curefit2026";
const SESSION_KEY = "auditor_authed";
const SESSION_EMAIL_KEY = "auditor_visitor_email";

// Set this to a webhook URL to receive visitor emails (e.g. Slack incoming webhook,
// Formspree endpoint, or any POST endpoint that accepts { email, timestamp }).
// Leave empty to skip the network call and only store locally.
const VISITOR_WEBHOOK_URL = "https://formspree.io/f/xlgzgoaj";

function logVisitor(email: string) {
  sessionStorage.setItem(SESSION_EMAIL_KEY, email);
  if (VISITOR_WEBHOOK_URL) {
    fetch(VISITOR_WEBHOOK_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, timestamp: new Date().toISOString() }),
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
          This portal is password-protected.
        </p>
        <form onSubmit={handleSubmit} className="mt-6 flex flex-col gap-4">
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="Your email"
            required
            autoFocus
            className="rounded-lg border border-zinc-700 bg-zinc-950 px-3 py-2.5 text-sm text-white placeholder:text-zinc-600 focus:border-emerald-600 focus:outline-none focus:ring-1 focus:ring-emerald-600"
          />
          <input
            type="password"
            value={password}
            onChange={(e) => {
              setPassword(e.target.value);
              setError(false);
            }}
            placeholder="Password"
            className="rounded-lg border border-zinc-700 bg-zinc-950 px-3 py-2.5 text-sm text-white placeholder:text-zinc-600 focus:border-emerald-600 focus:outline-none focus:ring-1 focus:ring-emerald-600"
          />
          {error && (
            <p className="text-sm text-red-400">Incorrect password. Try again.</p>
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

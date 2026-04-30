import tailwindcss from "@tailwindcss/vite";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [react(), tailwindcss()],
  // Use repo name as base for GitHub Pages project site.
  // Override with VITE_BASE env var when hosting at a custom domain root.
  base: process.env.VITE_BASE ?? "/auditor-portal/",
});

/**
 * Bundle React/Vite project to a single HTML file (invoked by bundle-artifact.cmd or directly).
 */
const { execSync, spawnSync } = require("child_process");
const fs = require("fs");

if (!fs.existsSync("package.json")) {
  console.error("Error: No package.json found. Run this from your project root.");
  process.exit(1);
}
if (!fs.existsSync("index.html")) {
  console.error("Error: No index.html found in project root.");
  process.exit(1);
}

console.log("Installing bundling dependencies...");
execSync(
  "pnpm add -D parcel @parcel/config-default parcel-resolver-tspaths html-inline",
  { stdio: "inherit", shell: true }
);

if (!fs.existsSync(".parcelrc")) {
  console.log("Creating Parcel configuration with path alias support...");
  const rc = {
    extends: "@parcel/config-default",
    resolvers: ["parcel-resolver-tspaths", "..."],
  };
  fs.writeFileSync(".parcelrc", JSON.stringify(rc, null, 2) + "\n");
}

console.log("Cleaning previous build...");
fs.rmSync("dist", { recursive: true, force: true });
try {
  fs.unlinkSync("bundle.html");
} catch {
  /* ignore */
}

console.log("Building with Parcel...");
execSync("pnpm exec parcel build index.html --dist-dir dist --no-source-maps", {
  stdio: "inherit",
  shell: true,
});

console.log("Inlining all assets into single HTML file...");
const r = spawnSync(
  "pnpm",
  ["exec", "html-inline", "dist/index.html"],
  { encoding: "utf8", shell: true, maxBuffer: 50 * 1024 * 1024 }
);
if (r.status !== 0) {
  console.error(r.stderr || "html-inline failed");
  process.exit(r.status || 1);
}
fs.writeFileSync("bundle.html", r.stdout);

const bytes = fs.statSync("bundle.html").size;
console.log("");
console.log("Bundle complete!");
console.log(`Output: bundle.html (${bytes} bytes)`);
console.log("");
console.log("You can use this single HTML file as an artifact in Claude conversations.");
console.log("To test locally: open bundle.html in your browser");

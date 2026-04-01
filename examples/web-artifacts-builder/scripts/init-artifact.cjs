/**
 * Windows-friendly initializer (invoked by init-artifact.cmd).
 * Replaces the former bash init script (Windows: init-artifact.cmd).
 */
const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

function run(cmd, opts = {}) {
  execSync(cmd, { stdio: "inherit", shell: true, ...opts });
}

const NODE_MAJOR = parseInt(process.version.slice(1).split(".")[0], 10);
console.log(`Detected Node.js major version: ${NODE_MAJOR}`);

if (NODE_MAJOR < 18) {
  console.error(`Error: Node.js 18 or higher is required. Current: ${process.version}`);
  process.exit(1);
}

const VITE_VERSION = NODE_MAJOR >= 20 ? "latest" : "5.4.11";
if (NODE_MAJOR >= 20) {
  console.log("Using Vite latest (Node 20+)");
} else {
  console.log(`Using Vite ${VITE_VERSION} (Node 18 compatible)`);
}

try {
  execSync("pnpm --version", { stdio: "pipe" });
} catch {
  console.log("pnpm not found. Installing pnpm...");
  run("npm install -g pnpm");
}

const projectName = process.argv[2];
if (!projectName) {
  console.error("Usage: init-artifact.cmd <project-name>");
  process.exit(1);
}

const scriptDir = __dirname;
const componentsTarball = path.join(scriptDir, "shadcn-components.tar.gz");
const componentsDir = path.join(scriptDir, "shadcn-components");

if (!fs.existsSync(componentsDir) && !fs.existsSync(componentsTarball)) {
  console.error("Error: shadcn components not found in script directory");
  console.error(`Expected: ${componentsDir}\\ (directory) or ${componentsTarball}`);
  process.exit(1);
}

console.log(`Creating new React + Vite project: ${projectName}`);
run(`pnpm create vite "${projectName}" --template react-ts`);

process.chdir(projectName);

console.log("Cleaning up Vite template...");
let indexHtml = fs.readFileSync("index.html", "utf8");
indexHtml = indexHtml
  .split("\n")
  .filter((line) => !/<link\s+rel="icon"[^>]*vite\.svg/i.test(line))
  .join("\n");
indexHtml = indexHtml.replace(/<title>[\s\S]*?<\/title>/, `<title>${projectName}</title>`);
fs.writeFileSync("index.html", indexHtml);

console.log("Installing base dependencies...");
run("pnpm install");

if (NODE_MAJOR < 20) {
  console.log(`Pinning Vite to ${VITE_VERSION} for Node 18 compatibility...`);
  run(`pnpm add -D vite@${VITE_VERSION}`);
}

console.log("Installing Tailwind CSS and dependencies...");
run(
  "pnpm install -D tailwindcss@3.4.1 postcss autoprefixer @types/node tailwindcss-animate"
);
run("pnpm install class-variance-authority clsx tailwind-merge lucide-react next-themes");

const postcss = `export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
`;
fs.writeFileSync("postcss.config.js", postcss);

const tailwind = `/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ["class"],
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      keyframes: {
        "accordion-down": {
          from: { height: "0" },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: "0" },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}
`;
fs.writeFileSync("tailwind.config.js", tailwind);

const indexCss = `@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 0 0% 3.9%;
    --card: 0 0% 100%;
    --card-foreground: 0 0% 3.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 0 0% 3.9%;
    --primary: 0 0% 9%;
    --primary-foreground: 0 0% 98%;
    --secondary: 0 0% 96.1%;
    --secondary-foreground: 0 0% 9%;
    --muted: 0 0% 96.1%;
    --muted-foreground: 0 0% 45.1%;
    --accent: 0 0% 96.1%;
    --accent-foreground: 0 0% 9%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 0 0% 98%;
    --border: 0 0% 89.8%;
    --input: 0 0% 89.8%;
    --ring: 0 0% 3.9%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 0 0% 3.9%;
    --foreground: 0 0% 98%;
    --card: 0 0% 3.9%;
    --card-foreground: 0 0% 98%;
    --popover: 0 0% 3.9%;
    --popover-foreground: 0 0% 98%;
    --primary: 0 0% 98%;
    --primary-foreground: 0 0% 9%;
    --secondary: 0 0% 14.9%;
    --secondary-foreground: 0 0% 98%;
    --muted: 0 0% 14.9%;
    --muted-foreground: 0 0% 63.9%;
    --accent: 0 0% 14.9%;
    --accent-foreground: 0 0% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 0 0% 98%;
    --border: 0 0% 14.9%;
    --input: 0 0% 14.9%;
    --ring: 0 0% 83.1%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}
`;
fs.writeFileSync("src/index.css", indexCss);

console.log("Adding path aliases to tsconfig.json...");
{
  const config = JSON.parse(fs.readFileSync("tsconfig.json", "utf8"));
  config.compilerOptions = config.compilerOptions || {};
  config.compilerOptions.baseUrl = ".";
  config.compilerOptions.paths = { "@/*": ["./src/*"] };
  fs.writeFileSync("tsconfig.json", JSON.stringify(config, null, 2));
}

console.log("Adding path aliases to tsconfig.app.json...");
{
  const p = "tsconfig.app.json";
  let content = fs.readFileSync(p, "utf8");
  const lines = content.split("\n").filter((line) => !line.trim().startsWith("//"));
  content = lines.join("\n");
  content = content.replace(/\/\*[\s\S]*?\*\//g, "");
  content = content.replace(/,(\s*[}\]])/g, "$1");
  const config = JSON.parse(content);
  config.compilerOptions = config.compilerOptions || {};
  config.compilerOptions.baseUrl = ".";
  config.compilerOptions.paths = { "@/*": ["./src/*"] };
  fs.writeFileSync(p, JSON.stringify(config, null, 2));
}

const viteConfig = `import path from "path";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
`;
fs.writeFileSync("vite.config.ts", viteConfig);

console.log("Installing shadcn/ui dependencies...");
run(
  "pnpm install @radix-ui/react-accordion @radix-ui/react-aspect-ratio @radix-ui/react-avatar @radix-ui/react-checkbox @radix-ui/react-collapsible @radix-ui/react-context-menu @radix-ui/react-dialog @radix-ui/react-dropdown-menu @radix-ui/react-hover-card @radix-ui/react-label @radix-ui/react-menubar @radix-ui/react-navigation-menu @radix-ui/react-popover @radix-ui/react-progress @radix-ui/react-radio-group @radix-ui/react-scroll-area @radix-ui/react-select @radix-ui/react-separator @radix-ui/react-slider @radix-ui/react-slot @radix-ui/react-switch @radix-ui/react-tabs @radix-ui/react-toast @radix-ui/react-toggle @radix-ui/react-toggle-group @radix-ui/react-tooltip"
);
run(
  "pnpm install sonner cmdk vaul embla-carousel-react react-day-picker react-resizable-panels date-fns react-hook-form @hookform/resolvers zod"
);

console.log("Installing shadcn/ui components...");
if (fs.existsSync(componentsDir)) {
  for (const ent of fs.readdirSync(componentsDir, { withFileTypes: true })) {
    const src = path.join(componentsDir, ent.name);
    const dest = path.join("src", ent.name);
    fs.cpSync(src, dest, { recursive: true });
  }
} else {
  run(`tar -xzf "${componentsTarball}" -C src`);
}

const componentsJson = {
  $schema: "https://ui.shadcn.com/schema.json",
  style: "default",
  rsc: false,
  tsx: true,
  tailwind: {
    config: "tailwind.config.js",
    css: "src/index.css",
    baseColor: "slate",
    cssVariables: true,
    prefix: "",
  },
  aliases: {
    components: "@/components",
    utils: "@/lib/utils",
    ui: "@/components/ui",
    lib: "@/lib",
    hooks: "@/hooks",
  },
};
fs.writeFileSync("components.json", JSON.stringify(componentsJson, null, 2));

console.log("");
console.log("Setup complete! You can now use Tailwind CSS and shadcn/ui in your project.");
console.log("");
console.log("Included components (40+ total):");
console.log("  - accordion, alert, aspect-ratio, avatar, badge, breadcrumb");
console.log("  - button, calendar, card, carousel, checkbox, collapsible");
console.log("  - command, context-menu, dialog, drawer, dropdown-menu");
console.log("  - form, hover-card, input, label, menubar, navigation-menu");
console.log("  - popover, progress, radio-group, resizable, scroll-area");
console.log("  - select, separator, sheet, skeleton, slider, sonner");
console.log("  - switch, table, tabs, textarea, toast, toggle, toggle-group, tooltip");
console.log("");
console.log("To start developing:");
console.log(`  cd ${projectName}`);
console.log("  pnpm dev");
console.log("");
console.log("Import components like:");
console.log("  import { Button } from '@/components/ui/button'");
console.log("  import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card'");
console.log("  import { Dialog, DialogContent, DialogTrigger } from '@/components/ui/dialog'");

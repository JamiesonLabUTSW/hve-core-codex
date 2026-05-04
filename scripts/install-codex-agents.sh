#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

REPO_ROOT="${repo_root}" node - "$@" <<'NODE'
const fs = require("fs");
const os = require("os");
const path = require("path");

const repoRoot = process.env.REPO_ROOT;
const generatedRoot = path.join(repoRoot, "plugins/hve-core-codex/generated/codex-agents");
const manifestPath = path.join(generatedRoot, "manifest.json");
const installManifestName = "hve-core-codex-install.json";
const generatedMarker = "# hve-core-codex generated agent";

function usage() {
  console.log(`Usage: scripts/install-codex-agents.sh [options]

Install generated HVE Core Codex custom-agent TOML files out-of-band.

Options:
  --scope project|user     Install to project .codex/agents or ~/.codex/agents.
                           Defaults to project.
  --target <path>          Project target directory for --scope project.
                           Defaults to current working directory.
  --profile <name>         Install profile from manifest: core, review, security,
                           automation, or all. Defaults to core.
  --dry-run                Print actions without writing.
  --force                  Update existing HVE-generated files.
  --prune                  Remove previously installed HVE-generated files not in
                           the selected profile.
  --uninstall              Remove files recorded in the install manifest.
  -h, --help               Show this help.
`);
}

function fail(message) {
  console.error(`install-codex-agents: ${message}`);
  process.exit(1);
}

function parseArgs(argv) {
  const options = {
    scope: "project",
    target: process.cwd(),
    profile: "core",
    dryRun: false,
    force: false,
    prune: false,
    uninstall: false
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--scope") {
      options.scope = requireValue(argv, ++index, arg);
    } else if (arg === "--target") {
      options.target = requireValue(argv, ++index, arg);
    } else if (arg === "--profile") {
      options.profile = requireValue(argv, ++index, arg);
    } else if (arg === "--dry-run") {
      options.dryRun = true;
    } else if (arg === "--force") {
      options.force = true;
    } else if (arg === "--prune") {
      options.prune = true;
    } else if (arg === "--uninstall") {
      options.uninstall = true;
    } else if (arg === "--help" || arg === "-h") {
      usage();
      process.exit(0);
    } else {
      fail(`Unknown argument: ${arg}`);
    }
  }

  if (!["project", "user"].includes(options.scope)) {
    fail(`--scope must be project or user, got ${options.scope}`);
  }
  if (options.scope === "user") {
    options.target = os.homedir();
  }

  return options;
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    fail(`${flag} requires a value`);
  }
  return value;
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJson(filePath, value, dryRun) {
  const text = `${JSON.stringify(value, null, 2)}\n`;
  if (dryRun) {
    logAction("write", filePath);
    return;
  }
  fs.writeFileSync(filePath, text, "utf8");
}

function logAction(action, filePath, detail = "") {
  const suffix = detail ? ` ${detail}` : "";
  console.log(`${action}: ${relativeForDisplay(filePath)}${suffix}`);
}

function relativeForDisplay(filePath) {
  const absolute = path.resolve(filePath);
  const cwd = process.cwd();
  const rel = path.relative(cwd, absolute);
  return rel && !rel.startsWith("..") ? rel : absolute;
}

function ensureManifest() {
  if (!fs.existsSync(manifestPath)) {
    fail(`Missing generated manifest: ${relativeForDisplay(manifestPath)}. Run scripts/generate-codex-agents.js first.`);
  }
  return readJson(manifestPath);
}

function destinationRoot(options) {
  if (options.scope === "user") {
    return path.join(os.homedir(), ".codex/agents");
  }
  return path.join(path.resolve(options.target), ".codex/agents");
}

function selectedAgents(manifest, profile) {
  const names = manifest.profiles?.[profile];
  if (!names) {
    const profiles = Object.keys(manifest.profiles || {}).sort().join(", ");
    fail(`Unknown profile ${profile}. Available profiles: ${profiles}`);
  }
  const byName = new Map(manifest.agents.map((agent) => [agent.name, agent]));
  return names.map((name) => {
    const agent = byName.get(name);
    if (!agent) {
      fail(`Profile ${profile} references missing generated agent ${name}`);
    }
    return agent;
  });
}

function hasGeneratedMarker(filePath) {
  if (!fs.existsSync(filePath)) {
    return false;
  }
  const text = fs.readFileSync(filePath, "utf8");
  return text.includes(generatedMarker);
}

function copyAgent(agent, destRoot, options) {
  const src = path.join(repoRoot, agent.outputPath);
  const dest = path.join(destRoot, path.basename(agent.outputPath));

  if (!fs.existsSync(src)) {
    fail(`Generated TOML is missing: ${relativeForDisplay(src)}`);
  }

  if (fs.existsSync(dest)) {
    if (!hasGeneratedMarker(dest)) {
      logAction("conflict", dest, "(not HVE-generated; skipped)");
      return { status: "conflict", dest };
    }
    if (!options.force) {
      logAction("skip", dest, "(exists; use --force to update)");
      return { status: "skipped", dest };
    }
    logAction(options.dryRun ? "would update" : "update", dest);
  } else {
    logAction(options.dryRun ? "would create" : "create", dest);
  }

  if (!options.dryRun) {
    fs.copyFileSync(src, dest);
  }

  return { status: "installed", dest };
}

function readInstallManifest(destRoot) {
  const filePath = path.join(destRoot, installManifestName);
  if (!fs.existsSync(filePath)) {
    return { filePath, manifest: null };
  }
  return { filePath, manifest: readJson(filePath) };
}

function removeGeneratedFile(filePath, options) {
  if (!fs.existsSync(filePath)) {
    logAction("missing", filePath);
    return;
  }
  if (!hasGeneratedMarker(filePath)) {
    logAction("conflict", filePath, "(not HVE-generated; not removed)");
    return;
  }
  logAction(options.dryRun ? "would remove" : "remove", filePath);
  if (!options.dryRun) {
    fs.rmSync(filePath);
  }
}

function uninstall(destRoot, options) {
  const { filePath, manifest } = readInstallManifest(destRoot);
  if (!manifest) {
    console.log(`install-codex-agents: no install manifest found at ${relativeForDisplay(filePath)}`);
    return;
  }
  for (const fileName of manifest.files || []) {
    removeGeneratedFile(path.join(destRoot, fileName), options);
  }
  logAction(options.dryRun ? "would remove" : "remove", filePath);
  if (!options.dryRun && fs.existsSync(filePath)) {
    fs.rmSync(filePath);
  }
}

function prune(destRoot, selectedFileNames, options) {
  const { manifest } = readInstallManifest(destRoot);
  if (!manifest) {
    return;
  }
  const selected = new Set(selectedFileNames);
  for (const fileName of manifest.files || []) {
    if (!selected.has(fileName)) {
      removeGeneratedFile(path.join(destRoot, fileName), options);
    }
  }
}

function install(options) {
  const manifest = ensureManifest();
  const destRoot = destinationRoot(options);
  const agents = selectedAgents(manifest, options.profile);
  const selectedFileNames = agents.map((agent) => path.basename(agent.outputPath));

  console.log(`install-codex-agents: scope=${options.scope} profile=${options.profile} target=${relativeForDisplay(destRoot)}`);

  if (options.uninstall) {
    uninstall(destRoot, options);
    return;
  }

  if (!options.dryRun) {
    fs.mkdirSync(destRoot, { recursive: true });
  } else {
    logAction("would ensure directory", destRoot);
  }

  if (options.prune) {
    prune(destRoot, selectedFileNames, options);
  }

  const results = agents.map((agent) => copyAgent(agent, destRoot, options));
  const installedFiles = results
    .filter((result) => result.status === "installed" || result.status === "skipped")
    .map((result) => path.basename(result.dest))
    .sort();

  writeJson(
    path.join(destRoot, installManifestName),
    {
      schemaVersion: 1,
      installedBy: "scripts/install-codex-agents.sh",
      installedAt: new Date().toISOString(),
      scope: options.scope,
      profile: options.profile,
      plugin: manifest.plugin,
      upstream: manifest.upstream,
      files: installedFiles,
      agents: agents.map((agent) => ({
        name: agent.name,
        displayName: agent.displayName,
        sourcePath: agent.sourcePath,
        outputPath: agent.outputPath
      }))
    },
    options.dryRun
  );

  const conflicts = results.filter((result) => result.status === "conflict").length;
  console.log(
    `install-codex-agents: selected=${agents.length} installedOrKept=${installedFiles.length} conflicts=${conflicts}`
  );
  if (conflicts > 0) {
    process.exitCode = 2;
  }
}

install(parseArgs(process.argv.slice(2)));
NODE

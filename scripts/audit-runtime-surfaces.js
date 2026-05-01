#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const repoRoot = path.resolve(__dirname, "..");
const pluginRoot = path.resolve(process.argv[2] || path.join(repoRoot, "plugins/hve-core-codex"));
const commandsRoot = path.join(pluginRoot, "commands");
const agentsRoot = path.join(pluginRoot, "agents");

function fail(message) {
  console.error(`runtime-surface-audit: ${message}`);
  process.exit(1);
}

function walkMarkdown(root) {
  if (!fs.existsSync(root)) {
    return [];
  }

  const files = [];
  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    const fullPath = path.join(root, entry.name);
    if (entry.isDirectory()) {
      files.push(...walkMarkdown(fullPath));
    } else if (entry.isFile() && entry.name.endsWith(".md")) {
      files.push(fullPath);
    }
  }
  return files.sort();
}

function stripQuotes(value) {
  let result = String(value || "").trim();
  if (
    (result.startsWith("\"") && result.endsWith("\"")) ||
    (result.startsWith("'") && result.endsWith("'"))
  ) {
    result = result.slice(1, -1);
  }
  return result.trim();
}

function parseMarkdown(filePath) {
  const text = fs.readFileSync(filePath, "utf8");
  const match = text.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?/);
  const metadata = {};
  let body = text;

  if (match) {
    body = text.slice(match[0].length);
    for (const line of match[1].split(/\r?\n/)) {
      const item = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
      if (item) {
        metadata[item[1]] = stripQuotes(item[2]);
      }
    }
  }

  return {
    metadata,
    body,
    hasFrontmatter: Boolean(match),
    relPath: path.relative(repoRoot, filePath)
  };
}

function normalizeAgentKey(value) {
  return stripQuotes(value).toLowerCase().replace(/[^a-z0-9]/g, "");
}

const commandFiles = walkMarkdown(commandsRoot);
const agentFiles = walkMarkdown(agentsRoot);

if (commandFiles.length === 0) {
  fail(`missing command markdown files under ${path.relative(repoRoot, commandsRoot)}`);
}

if (agentFiles.length === 0) {
  fail(`missing agent markdown files under ${path.relative(repoRoot, agentsRoot)}`);
}

const errors = [];
const warnings = [];
const agentKeys = new Map();

for (const filePath of agentFiles) {
  const parsed = parseMarkdown(filePath);
  const name = parsed.metadata.name;
  const description = parsed.metadata.description;
  const stem = path.basename(filePath, ".md");

  if (!parsed.hasFrontmatter) {
    errors.push(`${parsed.relPath}: missing frontmatter`);
  }

  if (!name) {
    errors.push(`${parsed.relPath}: missing agent name`);
  }

  if (!description) {
    errors.push(`${parsed.relPath}: missing agent description`);
  }

  for (const key of [name, stem]) {
    const normalized = normalizeAgentKey(key);
    if (normalized) {
      agentKeys.set(normalized, parsed.relPath);
    }
  }
}

for (const filePath of commandFiles) {
  const parsed = parseMarkdown(filePath);
  const description = parsed.metadata.description;
  const heading = parsed.body.match(/^#\s+\S.*$/m);
  const agent = parsed.metadata.agent;

  if (!parsed.hasFrontmatter && !heading) {
    errors.push(`${parsed.relPath}: missing frontmatter and command heading`);
  }

  if (!description && !heading) {
    errors.push(`${parsed.relPath}: missing command description or heading`);
  }

  if (agent) {
    const normalized = normalizeAgentKey(agent);
    if (normalized === "agent") {
      warnings.push(`${parsed.relPath}: uses generic agent placeholder`);
    } else if (!agentKeys.has(normalized)) {
      errors.push(`${parsed.relPath}: agent reference "${stripQuotes(agent)}" does not resolve to a packaged agent`);
    }
  }
}

if (warnings.length > 0) {
  console.warn("runtime-surface-audit: warnings");
  for (const warning of warnings) {
    console.warn(`  - ${warning}`);
  }
}

if (errors.length > 0) {
  console.error("runtime-surface-audit: failed");
  for (const error of errors) {
    console.error(`  - ${error}`);
  }
  process.exit(1);
}

console.log(
  `runtime-surface-audit: ok commands=${commandFiles.length} agents=${agentFiles.length} warnings=${warnings.length}`
);

#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const repoRoot = path.resolve(__dirname, "..");
const pluginRoot = path.join(repoRoot, "plugins/hve-core-codex");
const agentsRoot = path.join(pluginRoot, "agents");
const outputRoot = path.join(pluginRoot, "generated/codex-agents");
const manifestPath = path.join(outputRoot, "manifest.json");
const pluginManifestPath = path.join(pluginRoot, ".codex-plugin/plugin.json");
const lockPath = path.join(repoRoot, "upstream.lock.json");
const scriptRelPath = "scripts/generate-codex-agents.js";

const allowedFrontmatterKeys = new Set([
  "name",
  "description",
  "tools",
  "handoffs",
  "agents",
  "disable-model-invocation",
  "user-invocable",
  "argument-hint"
]);

const builtInAgentNames = new Set(["default", "worker", "explorer"]);
const generatedMarker = "# hve-core-codex generated agent";

function parseArgs(argv) {
  const options = {
    check: false,
    quiet: false
  };

  for (const arg of argv) {
    if (arg === "--check") {
      options.check = true;
    } else if (arg === "--quiet") {
      options.quiet = true;
    } else if (arg === "--help" || arg === "-h") {
      printHelp();
      process.exit(0);
    } else {
      fail(`Unknown argument: ${arg}`);
    }
  }

  return options;
}

function printHelp() {
  console.log(`Usage: node ${scriptRelPath} [--check] [--quiet]

Generate Codex custom-agent TOML from plugins/hve-core-codex/agents/**/*.md.

Options:
  --check   Verify generated files are current without writing them.
  --quiet   Suppress success output.
`);
}

function fail(message) {
  console.error(`generate-codex-agents: ${message}`);
  process.exit(1);
}

function readJsonIfPresent(filePath) {
  if (!fs.existsSync(filePath)) {
    return null;
  }
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
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

function parseAgentMarkdown(filePath) {
  const text = fs.readFileSync(filePath, "utf8");
  const match = text.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?/);
  if (!match) {
    throw new Error(`${relativeToRepo(filePath)}: missing YAML frontmatter`);
  }

  const frontmatter = match[1];
  const body = text.slice(match[0].length).replace(/\s+$/u, "") + "\n";
  const blocks = parseFrontmatterBlocks(frontmatter, filePath);
  const keys = blocks.map((block) => block.key);
  const unknownKeys = keys.filter((key) => !allowedFrontmatterKeys.has(key));

  if (unknownKeys.length > 0) {
    throw new Error(
      `${relativeToRepo(filePath)}: unknown frontmatter key(s): ${unknownKeys.join(", ")}`
    );
  }

  const metadata = Object.fromEntries(blocks.map((block) => [block.key, block.value]));
  const displayName = stripQuotes(metadata.name || "");
  const description = stripQuotes(metadata.description || "");

  if (!displayName) {
    throw new Error(`${relativeToRepo(filePath)}: missing frontmatter name`);
  }
  if (!description) {
    throw new Error(`${relativeToRepo(filePath)}: missing frontmatter description`);
  }

  return {
    body,
    description,
    displayName,
    frontmatter,
    frontmatterBlocks: blocks,
    frontmatterKeys: keys,
    sourcePath: relativeToRepo(filePath),
    sourceAgentPath: path.relative(agentsRoot, filePath).split(path.sep).join("/")
  };
}

function parseFrontmatterBlocks(frontmatter, filePath) {
  const blocks = [];
  let current = null;

  for (const line of frontmatter.split(/\r?\n/)) {
    const match = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
    if (match) {
      current = {
        key: match[1],
        lines: [line],
        value: match[2].trim()
      };
      blocks.push(current);
    } else if (/^\s+/.test(line) || line.trim() === "") {
      if (current) {
        current.lines.push(line);
      }
    } else {
      throw new Error(`${relativeToRepo(filePath)}: unsupported frontmatter line: ${line}`);
    }
  }

  return blocks;
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

function cleanDescription(value) {
  return String(value)
    .replace(/\s*-\s*Brought to you by microsoft\/hve-core\s*$/i, "")
    .trim();
}

function normalizeName(sourceAgentPath) {
  const withoutExt = sourceAgentPath.replace(/\.md$/i, "");
  const slug = withoutExt
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .replace(/_+/g, "_");
  return `hve_${slug}`;
}

function tomlString(value) {
  return JSON.stringify(String(value));
}

function tomlMultilineBasic(value) {
  return String(value)
    .replace(/\r\n/g, "\n")
    .replace(/\r/g, "\n")
    .replace(/\\/g, "\\\\")
    .replace(/"""/g, "\\\"\\\"\\\"");
}

function buildCompatibilitySection(agent) {
  const advisoryBlocks = agent.frontmatterBlocks.filter(
    (block) => block.key !== "name" && block.key !== "description"
  );

  if (advisoryBlocks.length === 0) {
    return "No Copilot-specific frontmatter fields were present on the source agent.";
  }

  const raw = advisoryBlocks.flatMap((block) => block.lines).join("\n");
  return [
    "The original HVE frontmatter contained fields that are not direct Codex custom-agent TOML fields.",
    "Treat these values as workflow guidance only; they do not grant tools, create automatic handoffs, or register nested agent roles.",
    "",
    "```yaml",
    raw,
    "```"
  ].join("\n");
}

function buildDeveloperInstructions(agent) {
  return [
    `Source: ${agent.sourcePath}`,
    `Original HVE agent name: ${agent.displayName}`,
    `Original HVE description: ${agent.description}`,
    "",
    "## Codex Port Compatibility Notes",
    "",
    buildCompatibilitySection(agent),
    "",
    "## Original HVE Agent Instructions",
    "",
    agent.body.trimEnd(),
    ""
  ].join("\n");
}

function buildAgentRecord(agent) {
  const generatedName = normalizeName(agent.sourceAgentPath);
  const clean = cleanDescription(agent.description);
  const description = clean
    ? `HVE Core ${agent.displayName}: ${clean}`
    : `HVE Core ${agent.displayName}`;
  const outputFile = `${generatedName}.toml`;
  const outputPath = `plugins/hve-core-codex/generated/codex-agents/${outputFile}`;
  const advisoryKeys = agent.frontmatterKeys.filter(
    (key) => key !== "name" && key !== "description"
  );

  return {
    ...agent,
    advisoryKeys,
    generatedName,
    outputFile,
    outputPath,
    tomlDescription: description
  };
}

function buildToml(agent) {
  const instructions = buildDeveloperInstructions(agent);
  return [
    generatedMarker,
    `# Source: ${agent.sourcePath}`,
    "# Do not edit this file by hand. Regenerate with scripts/generate-codex-agents.js.",
    `name = ${tomlString(agent.generatedName)}`,
    `description = ${tomlString(agent.tomlDescription)}`,
    "developer_instructions = \"\"\"",
    tomlMultilineBasic(instructions),
    "\"\"\"",
    ""
  ].join("\n");
}

function categorizeProfiles(records) {
  const profiles = {
    all: records.map((record) => record.generatedName),
    core: [],
    review: [],
    security: [],
    automation: []
  };

  for (const record of records) {
    const source = record.sourceAgentPath;
    const name = record.generatedName;

    if (source.startsWith("hve-core/")) {
      profiles.core.push(name);
    }
    if (
      source.startsWith("coding-standards/") ||
      source.includes("review") ||
      source.includes("validator")
    ) {
      profiles.review.push(name);
    }
    if (source.startsWith("security/") || source.startsWith("rai-planning/")) {
      profiles.security.push(name);
    }
    if (
      source.startsWith("ado/") ||
      source.startsWith("github/") ||
      source.startsWith("jira/")
    ) {
      profiles.automation.push(name);
    }
  }

  for (const key of Object.keys(profiles)) {
    profiles[key] = [...new Set(profiles[key])].sort();
  }

  return profiles;
}

function buildReadme(records) {
  return [
    "# Generated Codex Agents",
    "",
    "This directory is generated by `scripts/generate-codex-agents.js` during the HVE Core Codex sync cycle.",
    "",
    "The TOML files are inert while they remain in the plugin payload. To activate them as Codex custom agents, install them explicitly into a project `.codex/agents/` directory or the user `~/.codex/agents/` directory with `scripts/install-codex-agents.sh`.",
    "",
    "Recommended project-scoped dry run:",
    "",
    "```bash",
    "scripts/install-codex-agents.sh --dry-run --scope project --target /path/to/repo",
    "```",
    "",
    `Generated agent count: ${records.length}`,
    ""
  ].join("\n");
}

function buildManifest(records) {
  const pluginManifest = readJsonIfPresent(pluginManifestPath) || {};
  const lock = readJsonIfPresent(lockPath) || {};
  const frontmatterKeys = [
    ...new Set(records.flatMap((record) => record.frontmatterKeys))
  ].sort();

  return {
    schemaVersion: 1,
    generatedBy: scriptRelPath,
    plugin: {
      name: pluginManifest.name || "hve-core-codex",
      version: pluginManifest.version || null
    },
    upstream: {
      repository:
        process.env.HVE_CORE_UPSTREAM_REPOSITORY ||
        lock.source?.repository ||
        "https://github.com/microsoft/hve-core",
      commit: process.env.HVE_CORE_UPSTREAM_COMMIT || lock.source?.commit || null,
      version: process.env.HVE_CORE_UPSTREAM_VERSION || lock.source?.version || null,
      bundle: process.env.HVE_CORE_UPSTREAM_BUNDLE || lock.source?.bundle || "plugins/hve-core-all"
    },
    sourceRoot: "plugins/hve-core-codex/agents",
    outputRoot: "plugins/hve-core-codex/generated/codex-agents",
    generatedAgentCount: records.length,
    frontmatterKeys,
    allowedFrontmatterKeys: [...allowedFrontmatterKeys].sort(),
    builtInAgentNames: [...builtInAgentNames].sort(),
    profiles: categorizeProfiles(records),
    agents: records.map((record) => ({
      name: record.generatedName,
      displayName: record.displayName,
      description: record.tomlDescription,
      sourcePath: record.sourcePath,
      sourceAgentPath: record.sourceAgentPath,
      outputPath: record.outputPath,
      frontmatterKeys: record.frontmatterKeys,
      advisoryKeys: record.advisoryKeys
    }))
  };
}

function generate() {
  const sourceFiles = walkMarkdown(agentsRoot);
  if (sourceFiles.length === 0) {
    throw new Error(`No source agent files found under ${relativeToRepo(agentsRoot)}`);
  }

  const records = sourceFiles.map((file) => buildAgentRecord(parseAgentMarkdown(file)));
  validateRecords(records);

  const files = new Map();
  for (const record of records) {
    files.set(path.join(outputRoot, record.outputFile), buildToml(record));
  }
  files.set(manifestPath, `${JSON.stringify(buildManifest(records), null, 2)}\n`);
  files.set(path.join(outputRoot, "README.md"), buildReadme(records));

  return {
    files,
    records
  };
}

function validateRecords(records) {
  const names = new Map();
  for (const record of records) {
    if (builtInAgentNames.has(record.generatedName)) {
      throw new Error(
        `${record.sourcePath}: generated name collides with built-in agent ${record.generatedName}`
      );
    }
    if (names.has(record.generatedName)) {
      throw new Error(
        `${record.sourcePath}: generated name ${record.generatedName} collides with ${names.get(
          record.generatedName
        )}`
      );
    }
    names.set(record.generatedName, record.sourcePath);
  }
}

function writeGenerated(generated) {
  fs.rmSync(outputRoot, { recursive: true, force: true });
  fs.mkdirSync(outputRoot, { recursive: true });

  for (const [filePath, contents] of [...generated.files.entries()].sort()) {
    fs.mkdirSync(path.dirname(filePath), { recursive: true });
    fs.writeFileSync(filePath, contents, "utf8");
  }
}

function checkGenerated(generated) {
  const expectedPaths = [...generated.files.keys()].sort();
  const actualPaths = listGeneratedFiles(outputRoot).sort();
  const expectedSet = new Set(expectedPaths);
  const actualSet = new Set(actualPaths);
  const issues = [];

  for (const expectedPath of expectedPaths) {
    if (!actualSet.has(expectedPath)) {
      issues.push(`missing generated file: ${relativeToRepo(expectedPath)}`);
      continue;
    }
    const actual = fs.readFileSync(expectedPath, "utf8");
    const expected = generated.files.get(expectedPath);
    if (actual !== expected) {
      issues.push(`stale generated file: ${relativeToRepo(expectedPath)}`);
    }
  }

  for (const actualPath of actualPaths) {
    if (!expectedSet.has(actualPath)) {
      issues.push(`unexpected generated file: ${relativeToRepo(actualPath)}`);
    }
  }

  validateGeneratedToml(generated.records);

  if (issues.length > 0) {
    throw new Error(`generated Codex agents are not current:\n${issues.join("\n")}`);
  }
}

function validateGeneratedToml(records) {
  for (const record of records) {
    const filePath = path.join(outputRoot, record.outputFile);
    if (!fs.existsSync(filePath)) {
      continue;
    }
    const text = fs.readFileSync(filePath, "utf8");
    if (!text.includes(generatedMarker)) {
      throw new Error(`${relativeToRepo(filePath)}: missing generated marker`);
    }
    const name = text.match(/^name = "([^"]+)"$/m)?.[1];
    const description = text.match(/^description = "([\s\S]*?)"$/m)?.[1];
    const instructions = text.match(/^developer_instructions = """\n([\s\S]*)\n"""$/m)?.[1];

    if (name !== record.generatedName) {
      throw new Error(`${relativeToRepo(filePath)}: invalid or missing name`);
    }
    if (!description) {
      throw new Error(`${relativeToRepo(filePath)}: missing description`);
    }
    if (!instructions || !instructions.includes(`Source: ${record.sourcePath}`)) {
      throw new Error(`${relativeToRepo(filePath)}: missing developer_instructions source metadata`);
    }
  }
}

function listGeneratedFiles(root) {
  if (!fs.existsSync(root)) {
    return [];
  }

  const files = [];
  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    const fullPath = path.join(root, entry.name);
    if (entry.isDirectory()) {
      files.push(...listGeneratedFiles(fullPath));
    } else if (entry.isFile()) {
      files.push(fullPath);
    }
  }
  return files;
}

function relativeToRepo(filePath) {
  return path.relative(repoRoot, filePath).split(path.sep).join("/");
}

function main() {
  const options = parseArgs(process.argv.slice(2));

  try {
    const generated = generate();
    if (options.check) {
      checkGenerated(generated);
    } else {
      writeGenerated(generated);
    }
    if (!options.quiet) {
      const action = options.check ? "verified" : "generated";
      console.log(`generate-codex-agents: ${action} ${generated.records.length} Codex agents`);
    }
  } catch (error) {
    fail(error.message);
  }
}

main();

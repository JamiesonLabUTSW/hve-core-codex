# HVE Security Workflow Routes

| User intent | Command asset | Agent or skill assets |
|---|---|---|
| General codebase security review | `plugins/hve-core-codex/commands/security/security-review.md` | `plugins/hve-core-codex/agents/security/security-reviewer.md`, `plugins/hve-core-codex/skills/security-reviewer-formats/SKILL.md` |
| Web app OWASP Top 10 review | `plugins/hve-core-codex/commands/security/security-review-web.md` | `plugins/hve-core-codex/skills/owasp-top-10/SKILL.md` |
| LLM or agentic AI review | `plugins/hve-core-codex/commands/security/security-review-llm.md` | `plugins/hve-core-codex/skills/owasp-llm/SKILL.md`, `plugins/hve-core-codex/skills/owasp-agentic/SKILL.md`, `plugins/hve-core-codex/skills/owasp-mcp/SKILL.md` |
| Secure by Design review | `plugins/hve-core-codex/commands/security/security-review-sbd.md` | `plugins/hve-core-codex/skills/secure-by-design/SKILL.md` |
| Security plan from notes or PRD | `plugins/hve-core-codex/commands/security/security-capture.md` or `plugins/hve-core-codex/commands/security/security-plan-from-prd.md` | `plugins/hve-core-codex/agents/security/security-planner.md`, `plugins/hve-core-codex/docs/templates/security-plan-template.md` |
| SSSC supply chain assessment | `plugins/hve-core-codex/commands/security/sssc-capture.md`, `plugins/hve-core-codex/commands/security/sssc-from-prd.md`, `plugins/hve-core-codex/commands/security/sssc-from-brd.md`, or `plugins/hve-core-codex/commands/security/sssc-from-security-plan.md` | `plugins/hve-core-codex/agents/security/sssc-planner.md`, `plugins/hve-core-codex/docs/templates/sssc-plan-template.md`, `plugins/hve-core-codex/skills/owasp-cicd/SKILL.md` |
| RAI plan from a security plan | `plugins/hve-core-codex/commands/rai-planning/rai-plan-from-security-plan.md` | `plugins/hve-core-codex/agents/rai-planning/rai-planner.md`, `plugins/hve-core-codex/docs/templates/rai-plan-template.md` |
| Risk register | `plugins/hve-core-codex/commands/security/risk-register.md` | `plugins/hve-core-codex/docs/templates/security-plan-template.md` as needed |
| Incident response | `plugins/hve-core-codex/commands/security/incident-response.md` | Security instructions under `plugins/hve-core-codex/instructions/security/` as needed |

If this plugin is installed outside this repository, locate the same paths relative to the installed plugin root.

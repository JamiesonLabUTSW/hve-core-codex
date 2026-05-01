# HVE Security Workflow Routes

Paths are relative to the plugin root. From this wrapper skill directory, prefix them with `../../`.

| User intent | Command asset | Agent or skill assets |
|---|---|---|
| General codebase security review | `commands/security/security-review.md` | `agents/security/security-reviewer.md`, `skills/security-reviewer-formats/SKILL.md` |
| Web app OWASP Top 10 review | `commands/security/security-review-web.md` | `skills/owasp-top-10/SKILL.md` |
| LLM or agentic AI review | `commands/security/security-review-llm.md` | `skills/owasp-llm/SKILL.md`, `skills/owasp-agentic/SKILL.md`, `skills/owasp-mcp/SKILL.md` |
| Secure by Design review | `commands/security/security-review-sbd.md` | `skills/secure-by-design/SKILL.md` |
| Security plan from notes or PRD | `commands/security/security-capture.md` or `commands/security/security-plan-from-prd.md` | `agents/security/security-planner.md`, `docs/templates/security-plan-template.md` |
| SSSC supply chain assessment | `commands/security/sssc-capture.md`, `commands/security/sssc-from-prd.md`, `commands/security/sssc-from-brd.md`, or `commands/security/sssc-from-security-plan.md` | `agents/security/sssc-planner.md`, `docs/templates/sssc-plan-template.md`, `skills/owasp-cicd/SKILL.md` |
| RAI plan from a security plan | `commands/rai-planning/rai-plan-from-security-plan.md` | `agents/rai-planning/rai-planner.md`, `docs/templates/rai-plan-template.md` |
| Risk register | `commands/security/risk-register.md` | `docs/templates/security-plan-template.md` as needed |
| Incident response | `commands/security/incident-response.md` | Security instructions under `instructions/security/` as needed |

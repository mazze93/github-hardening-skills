# github-hardening-skills

> Idempotent, transferable skills for hardening GitHub repositories.
> Each skill is a self-contained runbook: branch protection, Dependabot, auto-merge, CI, and repo settings.

---

## What this is

A set of step-by-step, copy-paste-ready runbooks for securing and automating GitHub repositories.
Every skill document is:
- **Idempotent** — safe to re-apply; checks existing state before creating
- **Transferable** — works on any repo, personal or org
- **Opinionated** — recommends specific settings with clear rationale
- **AI-ingestible** — structured for use as context in Claude, Copilot, or any MCP-connected assistant

---

## Skills index

| # | Skill | What it covers |
|---|---|---|
| 01 | [Branch Protection](skills/01-branch-protection.md) | Rulesets, force push blocking, signed commits, PR requirements |
| 02 | [Dependabot Setup](skills/02-dependabot-setup.md) | `dependabot.yml` for npm, GitHub Actions, and other ecosystems |
| 03 | [Dependabot Auto-merge](skills/03-dependabot-auto-merge.md) | Workflow to auto-approve and merge patch/minor PRs |
| 04 | [CI Workflow](skills/04-ci-workflow.md) | Node.js CI with matrix builds, npm ci, build, test |
| 05 | [Repo Settings](skills/05-repo-settings.md) | General settings hardening: merge methods, branch cleanup, release immutability, push limits |

---

## Template files

Drop-in config files ready to copy into any repo:

```
templates/
  dependabot.yml                          → .github/dependabot.yml
  workflows/ci.yml                        → .github/workflows/ci.yml
  workflows/dependabot-auto-merge.yml     → .github/workflows/dependabot-auto-merge.yml
```

---

## Usage

### As a human
Read the relevant skill doc, follow the steps, use the template files.

### As AI context (Claude, Copilot, MCP)
Point your assistant at any skill file directly:
```
https://raw.githubusercontent.com/mazze93/github-hardening-skills/main/skills/01-branch-protection.md
```
Or clone the repo and reference skill files in your system prompt or context window.

### As a CLI bootstrap script
```bash
# Copy all templates into an existing repo
git clone https://github.com/mazze93/github-hardening-skills
cp github-hardening-skills/templates/dependabot.yml .github/dependabot.yml
cp github-hardening-skills/templates/workflows/ci.yml .github/workflows/ci.yml
cp github-hardening-skills/templates/workflows/dependabot-auto-merge.yml .github/workflows/dependabot-auto-merge.yml
```

---

## Design principles

- **Minimal blast radius** — each skill is scoped; applying one doesn’t break another
- **Explicit over implicit** — every permission, scope, and setting is named and reasoned
- **Security-first defaults** — recommend least-privilege, signed commits, no force pushes
- **No magic** — every step is visible and reversible

---

## License

MIT — use freely, adapt for your org, share with attribution.

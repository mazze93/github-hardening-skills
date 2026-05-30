# Skill 01: Protect the Default Branch via GitHub Rulesets

**Applies to:** Any GitHub repository (personal or org)
**Idempotency:** Check for existing rulesets first. Edit in place rather than creating duplicates.
**Transferability:** Works on any repo. Org-level rulesets apply to all repos at once.

---

## Prerequisites

- Admin or Owner access to the repository
- Private repos on the **Free plan**: rules are saved but **not enforced** — upgrade to Team or Enterprise for enforcement
- Status check enforcement requires at least one CI workflow that has run successfully at least once

---

## Navigation

```
Settings → Rules → Rulesets → New branch ruleset
```

Direct URL:
```
https://github.com/<owner>/<repo>/settings/rules/new?target=branch
```

---

## Idempotency check

Before creating, check if a ruleset already exists:
```
https://github.com/<owner>/<repo>/settings/rules
```
If **"Protect main branch"** already appears in the list, click it to edit in place. Do not create a duplicate.

---

## Configuration

### 1. Ruleset identity

| Field | Value |
|---|---|
| Name | `Protect main branch` |
| Enforcement status | **Active** |

### 2. Target branches

Select **Add target → Include default branch**.

> Why: This is portable. If you rename `main` to something else, the ruleset follows automatically.

### 3. Bypass list

Leave **empty** for personal repos.

For automation-heavy repos: add `github-actions[bot]` as an **app-based bypass only** — never add "Repository admin" as a bypass, as it defeats the ruleset entirely.

### 4. Branch rules

**Always enable these:**

| Rule | Setting | Why |
|---|---|---|
| Restrict creations | On | Prevents new refs on protected branch |
| Restrict deletions | On | Prevents accidental branch deletion |
| Block force pushes | On | Preserves commit history |
| Require linear history | On | Enforces squash or rebase merges |
| Require signed commits | On | Ensures commit authenticity |

**Pull request requirements:**

| Rule | Recommended | Notes |
|---|---|---|
| Require a pull request before merging | On | All changes go through PRs |
| Required approvals | `0` (solo) / `1+` (team) | See warning below |
| Dismiss stale PR approvals on push | On | Re-approval required after new commits |
| Require approval of most recent push | On | Prevents self-approval tricks |
| Require conversation resolution | On | Ensures review comments are addressed |

> **Warning — `0` approvals + auto-merge:** If you set required approvals to `0` and use the Dependabot auto-merge workflow (Skill 03), Dependabot PRs can merge without any human ever seeing them. This is intentional for patch/minor bumps, but understand the tradeoff before enabling it on sensitive repos.

**Status checks:**

| Rule | Setting |
|---|---|
| Require status checks to pass | On |
| Require branches to be up to date | On |

Add exact job name(s) from your CI workflow. For the CI template in Skill 04, the job names expand with the matrix:

```
Build & Test (Node 20.x)
Build & Test (Node 22.x)
```

> **Important:** Job names in the ruleset must match the `name:` field in your Actions YAML **exactly**, including capitalization and parentheses. A mismatch causes the status check to never register as passing, which blocks all merges indefinitely.

---

## Post-setup & verification

1. Click **Create** and confirm the status shows **Active** in the rulesets list.
2. Test: attempt a direct `git push` to `main` — it should be rejected.
3. Test: open a PR and verify required checks appear in the PR's merge section.

---

## Caveats

- **Private/Free plan:** Rules exist in the UI but are not enforced. Merges and direct pushes proceed normally.
- **Signed commits:** Requires each contributor to have GPG or SSH signing configured locally, or to use GitHub's web editor/Codespaces (which signs automatically). Enable **vigilant mode** (`Settings → SSH and GPG keys → Vigilant mode`) to show "Unverified" badges on unsigned commits.
- **Status checks — job name gotcha:** With a matrix build, each matrix variation becomes a separate check. You must add each one individually (e.g., `Build & Test (Node 20.x)` and `Build & Test (Node 22.x)`), or use a summary job that all matrix legs depend on.
- **Bypass list risk:** Any bypass actor can push directly to main. Keep it empty unless you have a specific, documented need.

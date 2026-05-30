# Skill 03: Dependabot Auto-merge Workflow

**Applies to:** Any GitHub repository using Dependabot version updates
**Idempotency:** Check for existing `.github/workflows/dependabot-auto-merge.yml` before creating.
**Transferability:** Drop-in with no repo-specific values. Uses `GITHUB_TOKEN` which is always available.

---

## Prerequisites

- Dependabot version updates configured (Skill 02)
- **Allow auto-merge** enabled: `Settings → General → Pull Requests → Allow auto-merge` checkbox
- Branch protection ruleset in place (Skill 01) for status check gating

---

## Idempotency check

```bash
ls .github/workflows/dependabot-auto-merge.yml
```
If exists → edit in place.

---

## What it does

1. Fires on every Dependabot PR open/update
2. Reads semver bump type via `dependabot/fetch-metadata@v2`
3. **Patch + minor:** auto-approves + enables auto-merge (waits for CI to pass)
4. **Major:** does nothing — PR stays open for manual review

---

## File location

```
.github/workflows/dependabot-auto-merge.yml
```

See template: [`templates/workflows/dependabot-auto-merge.yml`](../templates/workflows/dependabot-auto-merge.yml)

---

## Key design decisions

- `if: github.actor == 'dependabot[bot]'` — never runs on human PRs
- `--squash` merge — keeps linear history, consistent with Skill 01 branch rules
- `permissions: contents: write` + `pull-requests: write` — minimal explicit scope
- `pull_request` trigger (not `pull_request_target`) — safer for forks
- Auto-merge and approve are separate steps — order matters (merge registered before approve fires)

---

## Critical repo setting

After committing, go to:
```
Settings → General → Pull Requests → check "Allow auto-merge"
```
Without this, `gh pr merge --auto` fails with 422.

---

## Variations

**Patch only (conservative):** remove the two `semver-minor` steps.

**Dev deps only:**
```yaml
if: |
  steps.metadata.outputs.update-type == 'version-update:semver-patch' &&
  steps.metadata.outputs.dependency-type == 'direct:development'
```

---

## Post-setup checklist

- [ ] `dependabot-auto-merge.yml` committed to `.github/workflows/`
- [ ] `Allow auto-merge` enabled in `Settings → General`
- [ ] When next Dependabot PR opens: confirm workflow ran, PR shows `Auto-merge enabled`

---

## Caveats

- No CI = instant merge. Add at least a basic CI check (Skill 04) to gate auto-merge
- `dependabot[bot]` is the correct actor name for both version and security update PRs
- Forked repos: `GITHUB_TOKEN` is read-only, workflow will not work
- Private repo + 0 required approvals + no status checks = PRs merge immediately after workflow runs

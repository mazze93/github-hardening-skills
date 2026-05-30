# Skill 03: Dependabot Auto-merge Workflow

**Applies to:** Any GitHub repository using Dependabot version updates
**Idempotency:** Check for existing `.github/workflows/dependabot-auto-merge.yml` before creating. Edit in place if present.
**Transferability:** Drop-in with no repo-specific values. Uses `GITHUB_TOKEN` which is always available.

---

## Prerequisites

All three of these must be in place before the workflow will function correctly:

1. **Skill 02:** Dependabot version updates configured (`.github/dependabot.yml` present and active)
2. **Allow auto-merge** enabled: `Settings → General → Pull Requests → Allow auto-merge` checkbox
3. **Allow Actions to approve PRs** enabled: `Settings → Actions → General → Workflow permissions → Allow GitHub Actions to create and approve pull requests` checkbox
4. **Branch protection ruleset** in place (Skill 01) — strongly recommended to prevent immediate merges without CI

> **Why #3 matters:** The workflow approves PRs using `GITHUB_TOKEN`. GitHub blocks `GITHUB_TOKEN` from approving PRs by default. Without this setting, the "Approve PR" step will fail with a 422 error and auto-merge will not trigger.

---

## Idempotency check

```bash
ls .github/workflows/dependabot-auto-merge.yml
```

If the file exists, edit in place.

---

## What it does

1. Fires on every Dependabot PR open or update (not on human PRs — guarded by `if: github.actor == 'dependabot[bot]'`)
2. Reads semver bump type via `dependabot/fetch-metadata@v2`
3. **Patch + minor bumps:** auto-approves the PR, then enables auto-merge (waits for all required CI checks to pass before merging)
4. **Major bumps:** does nothing — PR stays open for manual review

---

## File location

`.github/workflows/dependabot-auto-merge.yml`

Template: [`templates/workflows/dependabot-auto-merge.yml`](https://github.com/mazze93/github-hardening-skills/blob/main/templates/workflows/dependabot-auto-merge.yml)

---

## Key design decisions

| Decision | Reason |
|---|---|
| `if: github.actor == 'dependabot[bot]'` | Only runs on Dependabot PRs; human PRs are ignored |
| `pull_request` trigger (not `pull_request_target`) | Safer for forked repos; no access to secrets from forks |
| `--squash` merge | Maintains linear history required by Skill 01's ruleset |
| `contents: write` + `pull-requests: write` | Minimum permissions needed; nothing broader |
| `cancel-in-progress: false` on concurrency | Prevents cancelling a run mid-merge, which could leave a PR in a broken state |

---

## Repository settings required

Two settings in `Settings → General` must be enabled before this workflow will work:

**1. Allow auto-merge**
```
Settings → General → Pull Requests → ☑ Allow auto-merge
```
Without this, `gh pr merge --auto` fails with: `Pull request auto merge is not allowed for this repository`.

**2. Allow Actions to create and approve pull requests**
```
Settings → Actions → General → Workflow permissions →
☑ Allow GitHub Actions to create and approve pull requests
```
Without this, the "Approve PR" step fails with HTTP 422 and no merge happens.

---

## Post-setup checklist

- [ ] `dependabot-auto-merge.yml` committed to `.github/workflows/`
- [ ] `Allow auto-merge` enabled in `Settings → General`
- [ ] `Allow GitHub Actions to create and approve pull requests` enabled in `Settings → Actions → General`
- [ ] Workflow appears in `Actions` tab
- [ ] Verify on the next Dependabot PR: workflow runs, PR gets approved, auto-merge waits for CI

---

## Variations

- **Patch only (more conservative):** Remove the `semver-minor` condition from both `if:` blocks
- **Dev dependencies only:** Add a condition `steps.metadata.outputs.dependency-type == 'direct:development'` to both steps
- **Separate limits per ecosystem:** Handled in `dependabot.yml` (Skill 02), not here

---

## Caveats

- **No CI / no required status checks:** If you have not set up required status checks in your branch ruleset (Skill 01), auto-merge triggers immediately when the workflow approves the PR. There is no waiting. This means dependency updates merge with zero validation. Always pair this skill with Skills 01 and 04.
- **Security updates ignore semver gates:** Dependabot security updates do not run through this workflow's major/minor/patch filter — they are handled separately and follow their own schedule. This workflow only processes version updates.
- **Forks:** `GITHUB_TOKEN` cannot push or approve on forked repos. This workflow is only effective on repos you own or have write access to.
- **Required approvals > 0:** If your ruleset requires 1+ human approvals and you also require the Actions bot to approve, you need both. The Actions approval satisfies the bot's role, but a human must still approve separately if `Required approvals: 1`.

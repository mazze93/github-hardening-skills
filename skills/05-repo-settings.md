# Skill 05: GitHub Repository Settings Hardening

**Applies to:** Any GitHub repository
**Idempotency:** Settings are toggles/dropdowns — safe to re-apply. Check current state before toggling.
**Transferability:** Apply to any repo via `Settings → General`.

---

## Navigation

```
https://github.com/<owner>/<repo>/settings
```

---

## Pull Requests section

`Settings → General → Pull Requests`

### Merge methods

| Setting | Recommended | Reason |
|---|---|---|
| Allow merge commits | Off | Creates non-linear history; conflicts with `Require linear history` in rulesets |
| Allow squash merging | On | Preferred: one clean commit per PR; works with Dependabot auto-merge |
| Allow rebase merging | On | Alternative to squash; also satisfies linear history requirement |

**Why both squash and rebase?** Squash is the default for Dependabot PRs (the auto-merge workflow uses `--squash`). Rebase is available for developers who prefer it on their own PRs. Both are safe with the `Require linear history` ruleset rule.

For squash commits, set the default commit message to **"Pull request title and commit details"** — this ensures conventional commit prefixes (e.g., `chore:`) show up in the squash message.

### PR workflow settings

| Setting | Recommended | Reason |
|---|---|---|
| Always suggest updating pull request branches | On | Prompts developers to rebase before merge |
| Allow auto-merge | On | **Required** for Dependabot auto-merge (Skill 03) |
| Automatically delete head branches | On | Keeps branch list clean after merging |

---

## Actions section

`Settings → Actions → General`

### Workflow permissions

| Setting | Recommended | Reason |
|---|---|---|
| Default workflow permissions | Read repository contents and packages | Least privilege default; workflows that need write must declare it explicitly |
| Allow GitHub Actions to create and approve pull requests | On | **Required** for Dependabot auto-merge (Skill 03); without this, the approve step fails with HTTP 422 |

> **Note on fork PR workflows:** Set "Fork pull request workflows" to **"Require approval for first-time contributors who are new to GitHub"** at minimum. This prevents untrusted code from running Actions and exfiltrating secrets.

---

## Commits section

`Settings → General → Commits`

| Setting | Recommended | Reason |
|---|---|---|
| Require contributors to sign off on web-based commits | On (org repos) | Developer Certificate of Origin compliance for open-source orgs |

---

## Releases section

`Settings → General → Releases`

| Setting | Recommended | Reason |
|---|---|---|
| Enable release immutability | On | Prevents modification of published release assets and tags; protects supply chain integrity |

> **Note:** As of mid-2026, release immutability may still be in public beta on some plans. Check whether it's available in your account tier before relying on it.

---

## Pushes section

`Settings → General → Pushes`

| Setting | Recommended | Value | Reason |
|---|---|---|---|
| Limit branches and tags updated per push | On | 5 (default) | Blocks bulk ref updates and accidental mass-tag operations |

---

## Features section

`Settings → General → Features`

| Feature | Recommended | Reason |
|---|---|---|
| Wikis | Off | Use `docs/` folder or GitHub Pages instead; wiki is a separate, unprotected git repo |
| Issues | On (unless using external tracker) | Disable only if you're using Jira, Linear, etc. |
| Projects | Optional | Enable if using GitHub Projects for this repo |

---

## Advanced settings

`Settings → General → Danger Zone`

- Confirm the **default branch** is set to `main` (or whatever your branch protection targets)

`Settings → Branches` (legacy, but still visible):
- Ensure no conflicting legacy branch protection rules exist alongside the Rulesets from Skill 01. Legacy rules and Rulesets can coexist but may cause confusing behavior — prefer Rulesets.

---

## Post-setup checklist

- [ ] Merge commits disabled
- [ ] Squash + rebase merging enabled
- [ ] Squash commit message set to "Pull request title and commit details"
- [ ] Allow auto-merge enabled
- [ ] Automatically delete head branches enabled
- [ ] Workflow permissions set to read-only by default
- [ ] Allow GitHub Actions to create and approve pull requests: **On**
- [ ] Fork PR workflow approval set to first-time contributor or higher
- [ ] Release immutability enabled (if available on your plan)
- [ ] Push limit enabled
- [ ] Wikis disabled
- [ ] Default branch confirmed as `main`

---

## Caveats

- **Disabling merge commits is not retroactive.** Existing merge commits in history are unaffected.
- **Release immutability** may be in preview/beta on some account tiers as of mid-2026. Verify availability before relying on it for supply chain compliance.
- **`Allow GitHub Actions to create and approve pull requests`** is often missed. It is located under `Actions → General`, not under `General → Pull Requests`. Skill 03 will silently fail without it.
- **Legacy branch protection rules** (under `Settings → Branches`) are separate from Rulesets. Both can be active simultaneously and may produce conflicting behavior. Migrate to Rulesets (Skill 01) and remove legacy rules to avoid confusion.

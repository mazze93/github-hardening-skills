# Skill 05: GitHub Repository Settings Hardening

**Applies to:** Any GitHub repository
**Idempotency:** Settings are toggles/dropdowns — safe to re-apply. Check current state first.
**Transferability:** Apply to any repo via `Settings → General`.

---

## Navigation

```
https://github.com/<owner>/<repo>/settings
```

---

## Pull Requests section

### Merge methods

| Setting | Recommended | Reason |
|---|---|---|
| Allow merge commits | ❌ Off | Creates non-linear history; conflicts with `Require linear history` in rulesets |
| Allow squash merging | ✅ On | Preferred: clean single commit per PR |
| Allow rebase merging | ✅ On | Alternative to squash; still linear |

Default commit message for squash: **Pull request title and commit details** (most informative).

### PR workflow settings

| Setting | Recommended | Reason |
|---|---|---|
| Always suggest updating pull request branches | ✅ On | Surfaces `Update branch` button; prevents stale merges |
| Allow auto-merge | ✅ On | Required for Dependabot auto-merge workflow (Skill 03) |
| Automatically delete head branches | ✅ On | Keeps branch list clean after merge; branches are restorable |

---

## Commits section

| Setting | Recommended | Reason |
|---|---|---|
| Require contributors to sign off on web-based commits | ❌ Off (personal) / ✅ On (org) | DCO sign-off is a legal requirement for some open-source orgs; optional for personal |
| Allow comments on individual commits | ✅ On | Harmless; useful for audit trail |

---

## Releases section

| Setting | Recommended | Reason |
|---|---|---|
| Enable release immutability | ✅ On | Prevents release assets and tags from being modified after publish; supply chain integrity |

---

## Pushes section (Preview)

| Setting | Recommended | Reason |
|---|---|---|
| Limit branches and tags updated per push | ✅ On | Blocks bulk ref updates; default limit: 5 |

---

## Features section

Disable unused features to reduce attack surface and UI noise:

| Feature | Recommended for code-only repos |
|---|---|
| Wikis | ❌ Off (use docs/ in repo or GitHub Pages) |
| Issues | ✅ On (unless using external tracker) |
| Sponsorships | Optional |
| Discussions | Optional (enable for community repos) |
| Projects | Optional |

---

## Settings that don’t appear in General

These are in side nav but part of the same hardening pass:

| Location | Setting | Recommendation |
|---|---|---|
| `Branches` | Default branch name | Confirm set to `main` |
| `Actions → General` | Fork pull request workflows | Set to `Require approval for first-time contributors` |
| `Actions → General` | Workflow permissions | Set to `Read repository contents and packages permissions` (not write) |
| `Secrets and variables` | Environment secrets | Store API keys here, not in repo code |
| `Pages` | Only if you use GitHub Pages | Enable; set to deploy from `gh-pages` branch or `docs/` |

---

## Post-setup checklist

- [ ] Merge commits disabled
- [ ] Squash + rebase enabled
- [ ] Allow auto-merge enabled
- [ ] Automatically delete head branches enabled
- [ ] Release immutability enabled
- [ ] Push limit enabled (default: 5)
- [ ] Unused features disabled
- [ ] Actions workflow permissions set to read-only by default

---

## Caveats

- Disabling merge commits on a repo that already has them doesn’t rewrite history
- `Allow auto-merge` is off by default on all new repos — must be manually enabled
- Release immutability only applies to future releases; existing releases are not retroactively locked
- Push limit is a Preview feature — stable behavior expected but may change

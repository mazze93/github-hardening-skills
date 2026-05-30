# Skill 01: Protect the Default/Main Branch via GitHub Rulesets

**Applies to:** Any GitHub repository (personal or org)
**Idempotency:** Check for existing rulesets first. Edit in place rather than creating duplicates.
**Transferability:** Works on any repo. Org-level rulesets apply to all repos at once.

---

## Prerequisites

- Admin or Owner access to the repository
- Private repos require GitHub Team or Enterprise plan for enforcement
- Status check enforcement requires at least one passing Actions workflow

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

Before creating, verify no ruleset already exists:
```
https://github.com/<owner>/<repo>/settings/rules
```
If one named `Protect main branch` exists → edit in place.

---

## Configuration

### Ruleset identity
| Field | Value |
|---|---|
| Ruleset Name | `Protect main branch` |
| Enforcement status | **Active** |

### Target branches
Click **Add target → Include default branch**.
Prefer this over hardcoding `main` — portable if default branch is renamed.

### Bypass list
Leave empty for personal repos. For automation-heavy repos, add `github-actions` as an app bypass only. Never add role-based bypasses (Repository admin, Write).

### Branch rules

#### Always enable
| Rule | Setting |
|---|---|
| Restrict creations | ✅ On |
| Restrict deletions | ✅ On |
| Block force pushes | ✅ On |
| Require linear history | ✅ On |
| Require signed commits | ✅ On |

#### PR requirements
| Rule | Setting |
|---|---|
| Require a pull request before merging | ✅ On |
| Required approvals | `0` (solo) or `1`+ (team) |
| Dismiss stale PR approvals on new commits | ✅ On |
| Require approval of most recent push | ✅ On |
| Require conversation resolution before merging | ✅ On |

#### Status checks (only after CI exists)
| Rule | Setting |
|---|---|
| Require status checks to pass | ✅ On |
| Require branches to be up to date | ✅ On |
| Add checks | Exact job names from your Actions YAML |

> GitHub requires at least one named check before this rule can be saved. Skip until CI is set up.

---

## Save

Click **Create**. Confirm: page redirects to `/settings/rules/<id>` with **Active** enforcement shown.

---

## Post-setup checklist

- [ ] Ruleset shows Active in `Settings → Rules → Rulesets`
- [ ] Target shows `Applies to 1 target: main`
- [ ] Test: attempt direct push to main — should be rejected
- [ ] (When CI exists) Add job names to status checks

---

## Caveats

- **Private repo + free plan:** rules saved but not enforced
- **Signed commits:** requires GPG/SSH signing configured by all contributors or Codespaces GPG enabled
- **Status checks:** job names must exactly match the `name:` field in your Actions YAML
- **Major version ignores in dependabot.yml** are separate from branch protection

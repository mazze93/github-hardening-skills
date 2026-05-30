# Skill 02: Dependabot Setup

**Applies to:** Any GitHub repository with npm, GitHub Actions, Docker, or other package ecosystems
**Idempotency:** Check for existing `.github/dependabot.yml` before creating. Edit in place if present.
**Transferability:** Drop into any repo. Adjust `package-ecosystem` entries to match what the repo uses.

---

## Prerequisites

- Write access to the repository
- For private repos: Dependabot must be enabled in `Settings → Security and quality` (it's on by default for public repos)

---

## Idempotency check

```bash
cat .github/dependabot.yml
# or view in browser:
https://github.com/<owner>/<repo>/blob/main/.github/dependabot.yml
```

If the file exists, **edit in place** by adding or updating `package-ecosystem` entries. Do not create a duplicate file. Duplicate `package-ecosystem` + `directory` pairs cause Dependabot to fail silently.

---

## Navigation

Create the file at:
```
https://github.com/<owner>/<repo>/new/main/.github
```
Set filename to `dependabot.yml`.

Or copy from the template:
```
templates/dependabot.yml → .github/dependabot.yml
```

---

## Baseline configuration

See the full template at [`templates/dependabot.yml`](https://github.com/mazze93/github-hardening-skills/blob/main/templates/dependabot.yml).

Key settings and their rationale:

| Setting | Value | Why |
|---|---|---|
| `interval` | `weekly` | Batches updates; daily is noisy |
| `day` | `monday` | PRs appear at start of week |
| `time` | `09:00` | During working hours |
| `timezone` | `America/New_York` | Change to match your timezone |
| `open-pull-requests-limit` | `10` (npm) / `5` (actions) | Prevents inbox overflow on first run |
| `commit-message.prefix` | `chore` | Conventional commit compatibility |
| `ignore: semver-major` | All ecosystems | Major bumps require manual review |

---

## Labels dependency

The template uses these labels:
- `dependencies`
- `automated`
- `github-actions`

**These labels must exist in the repository before Dependabot creates PRs.** If they don't exist, Dependabot will create PRs but silently omit the labels (it does not error, but your label-based filters and automations will not work).

Create labels at: `https://github.com/<owner>/<repo>/labels`

Or remove the `labels:` block from `dependabot.yml` entirely if you don't use label-based workflows.

---

## Post-setup & operations

- **Activation:** Dependabot activates within minutes of the file being merged to the default branch
- **Status check:** `Insights → Dependency graph → Dependabot → Check for updates`
- **Manual trigger:** Use the "Check for updates" button on the Dependabot page
- **PR commands:** Comment on Dependabot PRs to interact:
  - `@dependabot rebase` — rebase the PR branch
  - `@dependabot merge` — merge immediately (bypasses auto-merge workflow)
  - `@dependabot ignore this minor version` — ignore this bump going forward
  - `@dependabot ignore this major version` — ignore major bumps for this package

---

## Post-setup checklist

- [ ] `.github/dependabot.yml` present on the default branch
- [ ] All relevant `package-ecosystem` entries included
- [ ] Timezone configured correctly for your team
- [ ] Major version bumps in `ignore` block
- [ ] Labels exist in the repository (or `labels:` block removed)
- [ ] Dependency graph shows ecosystems as active

---

## Caveats

- **First-run PR volume:** Dependabot will open up to `open-pull-requests-limit` PRs immediately after activation. The limit prevents more from opening, but the first batch can be large. Review them before enabling auto-merge (Skill 03) to avoid a surge of immediate merges.
- **Security updates bypass the `ignore` block:** If a package has a known CVE, Dependabot will open a security update PR even if you have `version-update:semver-major` in the `ignore` block. Security updates follow their own rules and cannot be suppressed by version type filters.
- **Dependabot does not auto-merge by default.** See Skill 03 for the auto-merge workflow.
- **Private repos on GitHub Free:** Dependabot security updates are available, but some features (like private registry support) require GitHub Advanced Security.

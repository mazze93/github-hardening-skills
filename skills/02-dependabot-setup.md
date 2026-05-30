# Skill 02: Dependabot Setup

**Applies to:** Any GitHub repository with npm, GitHub Actions, Docker, or other package ecosystems
**Idempotency:** Check for existing `.github/dependabot.yml` before creating. Edit in place if present.
**Transferability:** Drop into any repo. Adjust `package-ecosystem` entries to match what the repo uses.

---

## Prerequisites

- Write access to the repository
- For private repos: Dependabot must be enabled in `Settings → Security and quality`

---

## Idempotency check

```bash
cat .github/dependabot.yml
# or
https://github.com/<owner>/<repo>/blob/main/.github/dependabot.yml
```
If it exists → edit in place, merging new ecosystem entries. Duplicate `package-ecosystem` + `directory` pairs cause errors.

---

## Navigation (GitHub UI)

```
https://github.com/<owner>/<repo>/new/main?dependabot_template=1&filename=.github%2Fdependabot.yml
```

---

## Ecosystem reference

| File present | `package-ecosystem` value |
|---|---|
| `package.json` | `npm` |
| `Cargo.toml` | `cargo` |
| `requirements.txt` / `pyproject.toml` | `pip` |
| `go.mod` | `gomod` |
| `.github/workflows/*.yml` | `github-actions` |
| `Dockerfile` | `docker` |

Always include `github-actions` — Action version pinning is a real supply chain risk.

---

## Baseline config (npm + GitHub Actions)

See template: [`templates/dependabot.yml`](../templates/dependabot.yml)

Key decisions:
- `interval: weekly` + `day: monday` + `time: 09:00` + `timezone: America/New_York`
- `open-pull-requests-limit: 10` (npm), `5` (actions)
- `commit-message.prefix: chore` — keeps dep bumps out of feature/fix history
- `ignore: semver-major` — major version bumps need manual review

---

## After committing

- Dependabot activates within minutes
- First run may open many PRs if deps are out of date (capped by `open-pull-requests-limit`)
- Manually trigger: `Insights → Dependency graph → Dependabot → Check for updates`
- Security updates open immediately regardless of schedule

---

## Useful PR commands (comment on any Dependabot PR)

```
@dependabot rebase
@dependabot merge
@dependabot ignore this version
@dependabot ignore this minor version
@dependabot ignore this major version
```

---

## Post-setup checklist

- [ ] `.github/dependabot.yml` present on default branch
- [ ] All relevant ecosystems listed
- [ ] Schedule set with correct timezone
- [ ] Major version bumps ignored
- [ ] Labels exist in repo matching those in config
- [ ] `Insights → Dependency graph → Dependabot` shows entries as active

---

## Caveats

- Security updates and version updates are separate; security PRs ignore schedule
- `github-actions` ecosystem watches `uses:` lines in workflow YAMLs
- First-run PR flood is capped by `open-pull-requests-limit`
- Dependabot does not auto-merge — see Skill 03

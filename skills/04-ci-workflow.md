# Skill 04: Node.js CI Workflow

**Applies to:** Any GitHub repository with a Node.js/npm project
**Idempotency:** Check for existing `.github/workflows/ci.yml` before creating.
**Transferability:** Works for any npm-based repo. Adjust `node-version` matrix as needed.

---

## Prerequisites

- Repository has a `package.json`
- Node.js project with `npm ci`, `npm run build`, or `npm test` scripts

---

## Idempotency check

```bash
ls .github/workflows/ci.yml
```
If exists → edit in place.

---

## What it does

Runs on every push to `main` and every PR targeting `main`:
1. Checks out code
2. Sets up Node.js (matrix across versions)
3. `npm ci` — clean install from lockfile
4. `npm run build --if-present` — skips gracefully if no build script
5. `npm test --if-present` — skips gracefully if no test script

The `--if-present` flag makes the workflow useful for repos that don’t yet have build/test scripts — CI passes without those steps and can be tightened later.

---

## File location

```
.github/workflows/ci.yml
```

See template: [`templates/workflows/ci.yml`](../templates/workflows/ci.yml)

---

## Node version matrix

Default: `[20.x, 22.x]` — LTS + current LTS.

Adjust based on your deployment target:
- Cloudflare Workers: `[18.x, 20.x]` (Workers runtime uses V8, not full Node, but match build toolchain)
- Legacy apps: add `18.x`
- Remove older versions once you’ve confirmed they’re not needed

---

## Connecting to branch protection (Skill 01)

After this workflow runs successfully once, go to:
```
Settings → Rules → Rulesets → Protect main branch → Require status checks to pass
```
Add check name: `Install & build` (must match the `name:` field in the job).

This gates all merges — including Dependabot auto-merges (Skill 03) — behind a passing build.

---

## Post-setup checklist

- [ ] `ci.yml` committed to `.github/workflows/`
- [ ] Workflow runs on next push or PR (check `Actions` tab)
- [ ] Job name `Install & build` appears in status checks dropdown in branch ruleset
- [ ] Add `Install & build` to required status checks in Skill 01 ruleset

---

## Caveats

- `npm ci` requires a lockfile (`package-lock.json`). If only `package.json` is present, use `npm install` instead
- Matrix builds run in parallel and both must pass for the check to be green
- The job name in the ruleset must match the workflow matrix expansion: it will appear as `Install & build (20.x)` and `Install & build (22.x)` — add both, or add the parent job name depending on GitHub’s display

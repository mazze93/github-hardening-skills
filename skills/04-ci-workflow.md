# Skill 04: Node.js CI Workflow

**Applies to:** Any GitHub repository with a Node.js/npm project
**Idempotency:** Check for existing `.github/workflows/ci.yml` before creating. Edit in place if present.
**Transferability:** Works for any npm-based repo. Adjust the `node-version` matrix to match your deployment targets.

---

## Prerequisites

- Repository has a `package.json`
- A `package-lock.json` is present (required for `npm ci`; see caveats if missing)
- Node.js project uses `npm` scripts for build and/or test

---

## Idempotency check

```bash
ls .github/workflows/ci.yml
```

If the file exists, edit in place rather than creating a duplicate workflow.

---

## What it does

Runs on every push to `main` and every PR targeting `main`:

1. Cancels any in-flight run for the same branch/PR (concurrency group)
2. Checks out code
3. Sets up Node.js (matrix across specified versions)
4. `npm ci` — clean, reproducible install from lockfile
5. `npm run build --if-present` — skips silently if no `build` script
6. `npm run test --if-present` — skips silently if no `test` script

---

## File location

`.github/workflows/ci.yml`

Template: [`templates/workflows/ci.yml`](https://github.com/mazze93/github-hardening-skills/blob/main/templates/workflows/ci.yml)

---

## Node version matrix

Default: `[20.x, 22.x]` (current LTS pair as of 2025–2026).

Update this as Node releases cycle. Check active LTS at [nodejs.org/en/about/releases](https://nodejs.org/en/about/releases).

---

## Connecting to branch protection (Skill 01)

After the workflow runs at least once successfully, you can add its job names as required status checks.

Go to: `Settings → Rules → Rulesets → Protect main branch → Require status checks to pass`

Add **both** of these check names (one per matrix leg):

```
Build & Test (Node 20.x)
Build & Test (Node 22.x)
```

> **Critical:** These names must match the `name:` field in the workflow YAML **exactly**. The template uses `Build & Test (Node ${{ matrix.node-version }})`, which expands to the values above at runtime. If you change the job name in the YAML, you must update the ruleset check names to match, or all merges will be blocked.

> **Alternative:** Add a summary job that all matrix legs `needs:`, then require only that one check. This simplifies ruleset configuration when the matrix is large.

---

## Post-setup checklist

- [ ] `ci.yml` committed to `.github/workflows/`
- [ ] Workflow appears in the `Actions` tab and runs successfully
- [ ] Both matrix job names added to required status checks in branch ruleset
- [ ] Verify a PR shows the checks as required before merge is enabled

---

## Caveats

- **`npm ci` requires `package-lock.json`:** If only `package.json` exists, use `npm install` instead. `npm ci` will fail without a lockfile.
- **Matrix jobs are separate checks:** Both `Build & Test (Node 20.x)` and `Build & Test (Node 22.x)` must pass. `fail-fast: false` lets both legs complete even if one fails, so you see both results.
- **`npm test` vs `npm run test`:** The `--if-present` flag only works with `npm run`. The template correctly uses `npm run test --if-present`. Do not change this to `npm test --if-present` — that form silently ignores the flag and will error if no test script exists.
- **Concurrency:** The workflow cancels redundant in-flight runs for the same PR branch. This is safe for CI; it means only the latest push gets a full run.

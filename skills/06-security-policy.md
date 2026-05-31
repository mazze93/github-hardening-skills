# Skill 06: Repository Security Policy

**Applies to:** Any public GitHub repository (recommended for private repos too)
**Idempotency:** Check for an existing `SECURITY.md` at the repo root or `.github/SECURITY.md` before creating. Edit in place if present.
**Transferability:** The template is a fill-in-the-blanks doc. Adjust contact info, SLAs, and scope to match your repo.

---

## What this is and why it matters

A `SECURITY.md` file does three things:

1. **Tells reporters where to send vulnerabilities** — without it, they open public issues, exposing the vulnerability before you can fix it
2. **Activates GitHub's private vulnerability reporting UI** — the "Report a vulnerability" button in the Security tab only appears when this file exists and private reporting is enabled
3. **Sets expectations** — scope, SLAs, and disclosure policy reduce back-and-forth and protect both parties

For a **hardening-focused repo** (like this one), it also signals that you hold your own documentation to the same security standards you advocate for.

---

## Prerequisites

- Write access to the repository
- A contact email or GitHub handle to receive reports
- (Optional but recommended) Private vulnerability reporting enabled: `Settings → Security and quality → Private vulnerability reporting → Enable`

---

## Idempotency check

```bash
# Check both locations GitHub recognizes
ls SECURITY.md 2>/dev/null || ls .github/SECURITY.md 2>/dev/null
```

GitHub checks the repo root first, then `.github/`. Either location works. If either exists, edit in place.

---

## File location

Place the file at **one** of these locations (do not create both):

```
SECURITY.md          # repo root — most visible
.github/SECURITY.md  # .github/ folder — keeps root clean
```

Template: [`templates/SECURITY.md`](https://github.com/mazze93/github-hardening-skills/blob/main/templates/SECURITY.md)

---

## Enable private vulnerability reporting

After committing `SECURITY.md`, enable GitHub's private reporting feature:

```
Settings → Security and quality → Private vulnerability reporting → Enable
```

With this enabled:
- A **"Report a vulnerability"** button appears on the Security tab for visitors
- Reports are submitted as **private GitHub Security Advisories (GHSAs)** — not public issues
- You receive a private notification and can collaborate on a fix before disclosure
- You can request a CVE from GitHub when/if applicable

> **Without private reporting enabled,** `SECURITY.md` still tells reporters where to send issues, but they will not have the in-UI button. They may fall back to email or, worse, open a public issue.

---

## What to include in SECURITY.md

### Required sections

| Section | Purpose |
|---|---|
| **Scope** | What IS and IS NOT a reportable vulnerability for this specific repo |
| **Reporting a vulnerability** | How to submit (private advisory link, email, or both) |
| **Response SLA** | How long until acknowledgement (e.g., 5 business days) |

### Recommended sections

| Section | Purpose |
|---|---|
| **Supported versions** | Which branch/version is maintained and receives fixes |
| **What to include** | Guidance on what makes a useful report |
| **Disclosure policy** | Your coordinated disclosure timeline |

---

## Scope guidance

Tailoring the scope section prevents noise and sets clear expectations:

**Application repos:**
- In scope: authentication bypass, RCE, SSRF, data exfiltration, privilege escalation, insecure defaults
- Out of scope: findings from automated scanners with no proof of exploitability, theoretical issues with no realistic attack path, issues requiring physical access

**Infrastructure/IaC repos:**
- In scope: secrets committed to history, permissions that grant unintended access, supply chain risks in workflow files
- Out of scope: misconfigurations in forked/downstream repos, issues requiring org-owner access to exploit

**Documentation repos (like this one):**
- In scope: guidance that, if followed, would materially weaken security (e.g., a config example that exposes secrets, a workflow that grants excessive permissions)
- Out of scope: typos, general feedback, GitHub platform bugs

---

## Response SLAs

Use realistic timelines you can actually meet. Overpromising and missing them is worse than setting honest longer timelines.

| Repo type | Acknowledgement | Fix / triage | Public disclosure |
|---|---|---|---|
| Production service | 2 business days | 14 days (critical) / 30 days (high) | After fix ships |
| Open-source library | 5 business days | 30 days | 90 days (coordinated) |
| Documentation/config | 5 business days | 14 days | 14 days after fix |

---

## Post-setup checklist

- [ ] `SECURITY.md` committed to repo root or `.github/`
- [ ] File contains: scope, reporting method, and response SLA at minimum
- [ ] Private vulnerability reporting enabled in `Settings → Security and quality`
- [ ] Security tab shows "Report a vulnerability" button when viewed while logged out
- [ ] Contact email or handle in the file is monitored
- [ ] (If org) Org-level security policy at `github.com/<org>/.github` does not conflict

---

## GitHub features unlocked by SECURITY.md + private reporting

| Feature | Requires |
|---|---|
| "Report a vulnerability" button | `SECURITY.md` present + private reporting enabled |
| Private Security Advisories (GHSAs) | Private reporting enabled |
| CVE request via GitHub | Private advisory published |
| Dependabot security alerts | Dependency graph + Dependabot enabled (Skill 02) |
| Code scanning alerts | GitHub Advanced Security or public repo |

---

## Caveats

- **`.github/SECURITY.md` vs repo-root `SECURITY.md`:** GitHub will use the repo-root version if both exist. Pick one location and stick with it.
- **Org-level policy:** If your org has a default `SECURITY.md` in the `.github` repo (`github.com/<org>/.github/SECURITY.md`), that policy applies to all repos that don't have their own. A repo-level `SECURITY.md` overrides it. Know which one reporters will see.
- **Private reporting is per-repo:** Enabling it at the org level does not automatically enable it for all existing repos. It must be enabled individually or via org settings bulk-enable.
- **Email as fallback:** Always include an email address. GitHub's private reporting UI is the primary channel, but reporters may be signed out, on a different platform, or prefer email. Without a fallback, those reports go nowhere.
- **CVEs for documentation repos:** CVEs are not applicable to documentation with no executable code. If your template caused a downstream vulnerability in someone else's repo, that downstream repo would receive the CVE, not yours.

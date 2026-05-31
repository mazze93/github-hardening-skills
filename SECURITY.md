# Security Policy

## Scope

This repository contains **documentation and workflow templates** for hardening GitHub repositories. It does not ship runnable application code or a published package. There is no production service to attack.

Vulnerabilities in scope:

- Incorrect, misleading, or insecure guidance in any skill document that, if followed, would weaken a repository's security posture
- Workflow templates that introduce a supply chain risk, privilege escalation, or secret exfiltration vector
- Broken or dangerous configuration examples that could be copied into production repos

Out of scope:

- GitHub platform bugs (report those to GitHub via [github.com/security](https://github.com/security))
- Typos, grammar issues, or general content feedback (open a regular issue instead)

---

## Supported versions

This repository is a living document. Only the content on the `main` branch is considered current and maintained. There are no versioned releases.

| Branch | Supported |
|---|---|
| `main` | Yes |
| Any other branch | No |

---

## Reporting a vulnerability

**Do not open a public GitHub issue for security reports.**

Use GitHub's private vulnerability reporting:

1. Go to the **Security** tab of this repository
2. Click **"Report a vulnerability"**
3. Fill in the details and submit

This opens a private advisory visible only to the repository maintainer. You will receive a response within **5 business days**.

If you are unable to use GitHub's private reporting, email: **security@mazzeleczzare.com**

---

## What to include in a report

- Which file(s) contain the problematic guidance or template
- A description of the security impact if a developer follows the guidance as written
- If applicable: a corrected version of the config or steps

---

## Disclosure policy

- Maintainer will acknowledge receipt within **5 business days**
- Maintainer will assess, fix, and publish a corrected version within **14 days** for documentation issues
- Credit will be given in the fix commit and/or release notes unless you prefer to remain anonymous
- Coordinated disclosure: please allow 14 days before public disclosure to give time for a fix

---

## No CVEs for documentation repositories

This repo contains no executable code. CVEs are not applicable. If a template or skill document contained guidance that could cause a real CVE in a downstream repo, that will be treated with the same urgency as a code vulnerability.

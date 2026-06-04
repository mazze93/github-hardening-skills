#!/usr/bin/env bash
# bootstrap.sh — Idempotent GitHub repo hardening via gh CLI
# Applies all skills from mazze93/github-hardening-skills
#
# Usage:
#   ./bootstrap.sh <owner> <repo> [--checks "Job 1,Job 2"] [--dry-run]
#
# Examples:
#   ./bootstrap.sh mazze93 my-repo --dry-run
#   ./bootstrap.sh mazze93 my-repo --checks "test,lint" --dry-run
#   ./bootstrap.sh mazze93 my-repo --checks "Build & Test (Node 20.x),Build & Test (Node 22.x)"
#
# Requirements:
#   - gh CLI authenticated: gh auth login
#   - jq installed: brew install jq
#   - Admin or Owner access to the target repo
#
# Idempotency: safe to re-run. Each section checks current state before patching.

set -euo pipefail

# ─── Defaults ─────────────────────────────────────────────────────────────────

OWNER=""
REPO=""
CHECKS_RAW="Build & Test (Node 20.x),Build & Test (Node 22.x)"
DRY_RUN=false

# ─── Arg parsing ──────────────────────────────────────────────────────────────

usage() {
  echo "Usage: $0 <owner> <repo> [--checks \"Job 1,Job 2\"] [--dry-run]"
  echo ""
  echo "Options:"
  echo "  --checks   Comma-separated list of required CI status check job names."
  echo "             Must match the 'name:' field in your Actions YAML exactly."
  echo "             Default: 'Build & Test (Node 20.x),Build & Test (Node 22.x)'"
  echo "  --dry-run  Print all API calls and file writes without executing them."
  echo ""
  echo "Examples:"
  echo "  $0 mazze93 my-repo --dry-run"
  echo "  $0 mazze93 my-repo --checks \"test,lint,typecheck\""
  echo "  $0 mazze93 my-repo --checks \"Build & Test (Node 20.x)\" --dry-run"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --checks)
      CHECKS_RAW="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help|-h)
      usage
      ;;
    -*)
      echo "Unknown flag: $1"
      usage
      ;;
    *)
      if [[ -z "$OWNER" ]]; then
        OWNER="$1"
      elif [[ -z "$REPO" ]]; then
        REPO="$1"
      else
        echo "Unexpected argument: $1"
        usage
      fi
      shift
      ;;
  esac
done

if [[ -z "$OWNER" || -z "$REPO" ]]; then
  echo "✗ Missing required arguments: <owner> and <repo>"
  echo ""
  usage
fi

# Convert comma-separated string → JSON array, trimming whitespace per item
STATUS_CHECKS=$(echo "$CHECKS_RAW" \
  | tr ',' '\n' \
  | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
  | jq -R . \
  | jq -sc .)

# ─── Dry-run wrapper ──────────────────────────────────────────────────────────

api_call() {
  local method="$1"
  local endpoint="$2"
  shift 2

  if [[ "$DRY_RUN" == true ]]; then
    echo "    [DRY-RUN] gh api --method ${method} ${endpoint}"
    for arg in "$@"; do
      echo "              $arg"
    done
  else
    gh api --method "$method" "$endpoint" "$@"
  fi
}

# ─── Helpers ──────────────────────────────────────────────────────────────────

check_deps() {
  for cmd in gh jq; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "✗ Missing dependency: $cmd"
      exit 1
    fi
  done
}

log_ok()     { echo "  ✓ $1"; }
log_skip()   { echo "  · $1 (already set)"; }
log_info()   { echo "  ℹ $1"; }
log_dryrun() { echo "  ~ $1"; }

# ─── Preflight ────────────────────────────────────────────────────────────────

check_auth() {
  echo "── Preflight"

  if [[ "$DRY_RUN" == true ]]; then
    log_dryrun "Skipping auth check in dry-run mode"
    echo ""
    return
  fi

  if ! gh auth status 2>&1 | grep -q "Logged in"; then
    echo "✗ Not authenticated. Run: gh auth login"
    exit 1
  fi

  log_ok "gh CLI authenticated"
  echo ""
}

# ─── Skill 05: Repo Settings ──────────────────────────────────────────────────

apply_repo_settings() {
  echo "── Skill 05: Repo Settings"

  local repo_payload
  repo_payload=$(jq -n '{
    allow_merge_commit:          false,
    allow_squash_merge:          true,
    allow_rebase_merge:          true,
    allow_auto_merge:            true,
    delete_branch_on_merge:      true,
    squash_merge_commit_title:   "PR_TITLE",
    squash_merge_commit_message: "COMMIT_MESSAGES",
    has_wiki:                    false
  }')

  if [[ "$DRY_RUN" == true ]]; then
    log_dryrun "PATCH /repos/${OWNER}/${REPO} — merge strategy, auto-merge, wiki"
    echo "    payload: $repo_payload"
    log_dryrun "PUT /repos/${OWNER}/${REPO}/actions/permissions/workflow — read-only, PR approval"
  else
    api_call PATCH "/repos/${OWNER}/${REPO}" --input - <<< "$repo_payload" > /dev/null
    log_ok "Merge strategy: squash + rebase only, auto-merge enabled, wiki disabled"

    api_call PUT "/repos/${OWNER}/${REPO}/actions/permissions/workflow" \
      --field default_workflow_permissions=read \
      --field can_approve_pull_request_reviews=true > /dev/null
    log_ok "Actions: read-only default permissions, PR approval enabled"
  fi

  echo ""
}

# ─── Skill 02: Dependabot ─────────────────────────────────────────────────────

apply_dependabot() {
  echo "── Skill 02: Dependabot"

  if gh api "/repos/${OWNER}/${REPO}/contents/.github/dependabot.yml" &>/dev/null 2>&1; then
    log_skip ".github/dependabot.yml already exists — skipping"
    echo ""
    return
  fi

  DEPENDABOT_CONTENT=$(cat <<'YAML'
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "09:00"
      timezone: "America/New_York"
    open-pull-requests-limit: 5
    labels:
      - "dependencies"
    commit-message:
      prefix: "chore"
      include: "scope"
    ignore:
      - dependency-name: "*"
        update-types:
          - "version-update:semver-major"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "09:00"
      timezone: "America/New_York"
    open-pull-requests-limit: 5
    labels:
      - "dependencies"
    commit-message:
      prefix: "chore"
      include: "scope"
YAML
)

  if [[ "$DRY_RUN" == true ]]; then
    log_dryrun "PUT /repos/${OWNER}/${REPO}/contents/.github/dependabot.yml — would create file"
  else
    gh api --method PUT "/repos/${OWNER}/${REPO}/contents/.github/dependabot.yml" \
      --field message="chore: add dependabot configuration" \
      --field content="$(echo "$DEPENDABOT_CONTENT" | base64)" > /dev/null
    log_ok ".github/dependabot.yml created"
  fi

  echo ""
}

# ─── Skill 01: Branch Protection Ruleset ──────────────────────────────────────

apply_branch_protection() {
  echo "── Skill 01: Branch Protection Ruleset"

  RULESET_NAME="Protect main branch"

  EXISTING=$(gh api "/repos/${OWNER}/${REPO}/rulesets" 2>/dev/null \
    | jq -r ".[] | select(.name == \"${RULESET_NAME}\") | .id" || echo "")

  if [[ -n "$EXISTING" ]]; then
    log_skip "Ruleset '${RULESET_NAME}' already exists (id: ${EXISTING})"
    log_info "Edit: https://github.com/${OWNER}/${REPO}/settings/rules/${EXISTING}"
    echo ""
    return
  fi

  PAYLOAD=$(jq -n \
    --argjson checks "$STATUS_CHECKS" \
    '{
      name: "Protect main branch",
      target: "branch",
      enforcement: "active",
      conditions: {
        ref_name: {
          include: ["~DEFAULT_BRANCH"],
          exclude: []
        }
      },
      rules: [
        { type: "creation" },
        { type: "deletion" },
        { type: "non_fast_forward" },
        { type: "required_linear_history" },
        {
          type: "pull_request",
          parameters: {
            required_approving_review_count: 0,
            dismiss_stale_reviews_on_push: true,
            require_code_owner_review: false,
            require_last_push_approval: true,
            required_review_thread_resolution: true
          }
        },
        {
          type: "required_status_checks",
          parameters: {
            strict_required_status_checks_policy: true,
            required_status_checks: ($checks | map({ context: . }))
          }
        }
      ]
    }')

  if [[ "$DRY_RUN" == true ]]; then
    log_dryrun "POST /repos/${OWNER}/${REPO}/rulesets — would create '${RULESET_NAME}'"
    echo "    status checks: $(echo "$STATUS_CHECKS" | jq -r 'join(", ")')"
    echo "    payload preview:"
    echo "$PAYLOAD" | jq '.' | sed 's/^/      /'
  else
    gh api --method POST "/repos/${OWNER}/${REPO}/rulesets" \
      --input - <<< "$PAYLOAD" > /dev/null
    log_ok "Ruleset '${RULESET_NAME}' created (active)"
    log_info "Verify: https://github.com/${OWNER}/${REPO}/settings/rules"
  fi

  echo ""
}

# ─── Main ─────────────────────────────────────────────────────────────────────

check_deps

if [[ "$DRY_RUN" == true ]]; then
  echo "▶ DRY-RUN — ${OWNER}/${REPO} (no changes will be made)"
else
  echo "▶ Hardening ${OWNER}/${REPO}"
fi
echo "  Status checks: $(echo "$STATUS_CHECKS" | jq -r 'join(", ")')"
echo ""

check_auth
apply_repo_settings
apply_dependabot
apply_branch_protection

echo "═══════════════════════════════════════════════════════════"
if [[ "$DRY_RUN" == true ]]; then
  echo "~ Dry-run complete. No changes made to ${OWNER}/${REPO}."
  echo "  Re-run without --dry-run to apply."
else
  echo "✓ Hardening complete: ${OWNER}/${REPO}"
fi
echo ""
echo "Manual steps remaining (no public API):"
echo "  · Skill 03: Add dependabot-auto-merge.yml workflow (see templates/)"
echo "  · Skill 04: Add ci.yml — job names must match ruleset status checks"
echo "  · Skill 06: Add SECURITY.md"
echo "  · Signed commits: enable vigilant mode in GitHub profile settings"
echo "  · Fork PR approval: Settings → Actions → Fork pull request workflows"
echo "  · Release immutability: Settings → General → Releases (plan-dependent)"
echo "═══════════════════════════════════════════════════════════"

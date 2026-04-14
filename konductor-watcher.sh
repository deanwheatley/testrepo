#!/bin/bash
# konductor-watcher.sh — File watcher + collision monitor for Konductor.
#
# Watches for file changes, registers them with the Konductor server,
# and polls for collision state changes. Prints color-coded notifications.
#
# Usage:
#   ./konductor-watcher.sh                              ← uses defaults
#   KONDUCTOR_LOG_LEVEL=debug ./konductor-watcher.sh    ← verbose output
#
# Requires: fswatch (macOS: brew install fswatch, Linux: apt install fswatch)
#
# Config: .konductor-watcher.env (created by install.sh)

set -e

# ── Load config ──────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
[ -f "$SCRIPT_DIR/.konductor-watcher.env" ] && source "$SCRIPT_DIR/.konductor-watcher.env"
[ -f ".konductor-watcher.env" ] && source ".konductor-watcher.env"

# Defaults
KONDUCTOR_URL="${KONDUCTOR_URL:-http://localhost:3010}"
KONDUCTOR_WATCH_EXTENSIONS="${KONDUCTOR_WATCH_EXTENSIONS:-ts,tsx,js,jsx,py,java,go,rs,rb,json,yaml,yml,md,html,css}"
KONDUCTOR_LOG_LEVEL="${KONDUCTOR_LOG_LEVEL:-info}"
KONDUCTOR_POLL_INTERVAL="${KONDUCTOR_POLL_INTERVAL:-10}"
KONDUCTOR_LOG_FILE="${KONDUCTOR_LOG_FILE:-}"

# Git context
USER_ID="${KONDUCTOR_USER:-$(git config user.name 2>/dev/null || echo "unknown")}"
REPO="${KONDUCTOR_REPO:-$(git remote get-url origin 2>/dev/null | sed 's/.*[:/]\([^/]*\/[^/]*\)\.git$/\1/' | sed 's/.*[:/]\([^/]*\/[^/]*\)$/\1/' || echo "unknown/unknown")}"
BRANCH="${KONDUCTOR_BRANCH:-$(git branch --show-current 2>/dev/null || echo "unknown")}"

# State tracking
LAST_STATE=""
SESSION_ID=""
REGISTERED_FILES=""

# ── ANSI color codes ─────────────────────────────────────────────────

RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
FG_WHITE="\033[97m"
FG_GREEN="\033[32m"
FG_YELLOW="\033[33m"
FG_RED="\033[31m"
FG_CYAN="\033[36m"
FG_GRAY="\033[90m"
BG_GREEN="\033[42m"
BG_YELLOW="\033[43m"
BG_ORANGE="\033[48;5;208m"
BG_RED="\033[41m"

# ── Logging helpers ──────────────────────────────────────────────────

log_raw() {
  echo -e "$1"
  if [ -n "$KONDUCTOR_LOG_FILE" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') $(echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g')" >> "$KONDUCTOR_LOG_FILE"
  fi
}

log_info() { log_raw "$1"; }

log_debug() {
  if [ "$KONDUCTOR_LOG_LEVEL" = "debug" ]; then
    log_raw "${FG_GRAY}[DEBUG] $1${RESET}"
  fi
}

log_separator() {
  log_raw "${DIM}────────────────────────────────────────────────${RESET}"
}

# ── Check for fswatch ────────────────────────────────────────────────

if ! command -v fswatch &> /dev/null; then
  log_raw "${BG_RED}${FG_WHITE}${BOLD} ✖ MISSING DEPENDENCY ${RESET}"
  log_raw "  fswatch is required but not installed."
  log_raw "  ${BOLD}macOS:${RESET}  brew install fswatch"
  log_raw "  ${BOLD}Linux:${RESET}  apt install fswatch"
  exit 1
fi

# ── Startup banner ───────────────────────────────────────────────────

log_raw ""
log_raw "${BOLD}${FG_CYAN}  ╔═══════════════════════════════════════╗${RESET}"
log_raw "${BOLD}${FG_CYAN}  ║       🔍 KONDUCTOR WATCHER           ║${RESET}"
log_raw "${BOLD}${FG_CYAN}  ╚═══════════════════════════════════════╝${RESET}"
log_raw ""
log_raw "  ${BOLD}User:${RESET}      $USER_ID"
log_raw "  ${BOLD}Repo:${RESET}      $REPO"
log_raw "  ${BOLD}Branch:${RESET}    $BRANCH"
log_raw "  ${BOLD}Server:${RESET}    $KONDUCTOR_URL"
log_raw "  ${BOLD}Log level:${RESET} $KONDUCTOR_LOG_LEVEL"
log_raw "  ${BOLD}Poll:${RESET}      every ${KONDUCTOR_POLL_INTERVAL}s"
[ -n "$KONDUCTOR_LOG_FILE" ] && log_raw "  ${BOLD}Log file:${RESET}  $KONDUCTOR_LOG_FILE"
log_raw ""
log_separator

# ── API helpers ──────────────────────────────────────────────────────

api_call() {
  local endpoint="$1"
  local body="$2"
  log_debug "POST $KONDUCTOR_URL$endpoint"
  log_debug "Body: $body"
  local response
  if [ -n "$KONDUCTOR_API_KEY" ]; then
    response=$(curl -s -X POST "$KONDUCTOR_URL$endpoint" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $KONDUCTOR_API_KEY" \
      -d "$body" 2>/dev/null || echo '{"error":"connection failed"}')
  else
    response=$(curl -s -X POST "$KONDUCTOR_URL$endpoint" \
      -H "Content-Type: application/json" \
      -d "$body" 2>/dev/null || echo '{"error":"connection failed"}')
  fi
  log_debug "Response: $response"
  echo "$response"
}

# ── Parse JSON helpers ───────────────────────────────────────────────

json_val() { echo "$1" | grep -o "\"$2\":\"[^\"]*\"" | head -1 | cut -d'"' -f4; }
json_array_vals() { echo "$1" | grep -o "\"$2\":\[\"[^]]*\]" | head -1 | sed 's/.*\[//;s/\]//;s/"//g'; }

# ── Human-friendly message formatting ────────────────────────────────

format_collision_message() {
  local state="$1" overlaps="$2" shared="$3" files_changed="$4"
  local ts; ts=$(date '+%H:%M:%S')
  case "$state" in
    solo)
      log_raw ""; log_raw "${BG_GREEN}${FG_WHITE}${BOLD} 🟢 SOLO ${RESET}  ${DIM}${ts}${RESET}"
      log_raw "  ${FG_GREEN}Updated:${RESET} $files_changed"
      log_raw "  ${FG_GREEN}No other users active. You're clear.${RESET}"; log_separator ;;
    neighbors)
      log_raw ""; log_raw "${BG_GREEN}${FG_WHITE}${BOLD} 🟢 NEIGHBORS ${RESET}  ${DIM}${ts}${RESET}"
      log_raw "  ${FG_GREEN}Updated:${RESET} $files_changed"
      log_raw "  ${FG_GREEN}Also in repo:${RESET} $overlaps ${DIM}(different files — no conflict)${RESET}"; log_separator ;;
    crossroads)
      log_raw ""; log_raw "${BG_YELLOW}${FG_WHITE}${BOLD} 🟡 CROSSROADS ${RESET}  ${DIM}${ts}${RESET}"
      log_raw "  ${FG_YELLOW}Updated:${RESET} $files_changed"
      log_raw "  ${FG_YELLOW}Same directories:${RESET} $overlaps"
      log_raw "  ${FG_YELLOW}${BOLD}Keep an eye on it.${RESET}"; log_separator ;;
    collision_course)
      log_raw ""; log_raw "${BG_ORANGE}${FG_WHITE}${BOLD} 🟠 COLLISION COURSE ${RESET}  ${DIM}${ts}${RESET}"
      log_raw "  ${FG_YELLOW}Updated:${RESET} $files_changed"
      log_raw "  ${BOLD}${FG_YELLOW}Overlapping users:${RESET} $overlaps"
      log_raw "  ${BOLD}${FG_YELLOW}Shared files:${RESET} $shared"
      log_raw "  ${BOLD}${FG_YELLOW}⚠️  Coordinate with your team before continuing.${RESET}"; log_separator ;;
    merge_hell)
      log_raw ""; log_raw "${BG_RED}${FG_WHITE}${BOLD} 🔴 MERGE HELL ${RESET}  ${DIM}${ts}${RESET}"
      log_raw "  ${FG_RED}Updated:${RESET} $files_changed"
      log_raw "  ${BOLD}${FG_RED}Overlapping users:${RESET} $overlaps"
      log_raw "  ${BOLD}${FG_RED}Conflicting files:${RESET} $shared"
      log_raw "  ${BG_RED}${FG_WHITE}${BOLD} ⛔ STOP — Divergent changes detected. Coordinate immediately. ${RESET}"; log_separator ;;
    none) log_debug "No active session for this user." ;;
    *) log_raw "${FG_GREEN}🟢 [Konductor] State: $state${RESET}"; log_separator ;;
  esac
}

# ── Register files with server ───────────────────────────────────────

register_files() {
  local files_list="$1"
  [ -z "$files_list" ] && return
  local files_json="[" first=true
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    local rel_path; rel_path=$(git ls-files --full-name "$file" 2>/dev/null || echo "$file")
    if [ "$first" = true ]; then files_json="$files_json\"$rel_path\""; first=false
    else files_json="$files_json,\"$rel_path\""; fi
  done <<< "$files_list"
  files_json="$files_json]"
  local display_files; display_files=$(echo "$files_list" | tr '\n' ', ' | sed 's/,$//' | sed 's/^,//' | sed 's/,,*/,/g')
  local body="{\"userId\":\"$USER_ID\",\"repo\":\"$REPO\",\"branch\":\"$BRANCH\",\"files\":$files_json}"
  local response; response=$(api_call "/api/register" "$body")
  local error; error=$(json_val "$response" "error")
  if [ -n "$error" ]; then log_raw "${BG_RED}${FG_WHITE}${BOLD} ⚠️  ERROR ${RESET} $error"; return; fi
  SESSION_ID=$(json_val "$response" "sessionId")
  REGISTERED_FILES="$files_list"
  local state; state=$(json_val "$response" "collisionState")
  check_and_notify "$state" "$display_files"
}

# ── Check status and notify ──────────────────────────────────────────

check_and_notify() {
  local reg_state="$1" files_changed="${2:-}"
  local body="{\"userId\":\"$USER_ID\",\"repo\":\"$REPO\"}"
  local response; response=$(api_call "/api/status" "$body")
  local error; error=$(json_val "$response" "error")
  if [ -n "$error" ]; then log_debug "Status check error: $error"; return; fi
  local state; state=$(json_val "$response" "collisionState")
  [ -z "$state" ] && state="$reg_state"
  local overlaps; overlaps=$(echo "$response" | grep -o '"userId":"[^"]*"' | cut -d'"' -f4 | grep -v "^$USER_ID$" | tr '\n' ', ' | sed 's/,$//')
  local shared; shared=$(json_array_vals "$response" "sharedFiles")
  local current_sig="${state}:${overlaps}"
  if [ "$current_sig" != "$LAST_STATE" ] || [ -n "$files_changed" ]; then
    LAST_STATE="$current_sig"
    format_collision_message "$state" "${overlaps:-none}" "${shared:-none}" "${files_changed:-existing files}"
  fi
}

# ── Background poller ────────────────────────────────────────────────

poll_status() {
  while true; do
    sleep "$KONDUCTOR_POLL_INTERVAL"
    if [ -n "$SESSION_ID" ]; then log_debug "Polling status..."; check_and_notify "" ""; fi
  done
}
poll_status &
POLLER_PID=$!
trap "kill $POLLER_PID 2>/dev/null; exit 0" EXIT INT TERM

# ── Build fswatch filter ─────────────────────────────────────────────

IFS=',' read -ra EXTS <<< "$KONDUCTOR_WATCH_EXTENSIONS"
FSWATCH_FILTERS=""
for ext in "${EXTS[@]}"; do
  FSWATCH_FILTERS="$FSWATCH_FILTERS -e '.*' -i '\\.${ext}$'"
done

# ── Watch for file changes ───────────────────────────────────────────

log_raw ""
log_raw "  ${BOLD}👀 Watching for file changes...${RESET}"
log_raw ""
log_separator

CHANGED_FILES=""
eval fswatch -0 --batch-marker=EOF -r . $FSWATCH_FILTERS | while IFS= read -r -d '' file; do
  if [ "$file" = "EOF" ]; then
    register_files "$CHANGED_FILES"
    CHANGED_FILES=""
  else
    case "$file" in
      */.git/*|*/node_modules/*|*/dist/*|*/.kiro/*) continue ;;
    esac
    CHANGED_FILES="$CHANGED_FILES
$file"
  fi
done

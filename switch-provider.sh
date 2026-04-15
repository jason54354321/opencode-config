#!/usr/bin/env bash
# Switch oh-my-openagent.json between anthropic-primary and github-copilot-primary.
# Only swaps Claude models. Non-Claude models (gpt-5.4, gemini) stay on github-copilot.
#
# Usage:
#   ./switch-provider.sh              # show current provider
#   ./switch-provider.sh copilot      # switch to github-copilot
#   ./switch-provider.sh anthropic    # switch to anthropic
#   ./switch-provider.sh toggle       # toggle between the two

set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$CONFIG_DIR/oh-my-openagent.json"

if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: $CONFIG not found" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "ERROR: jq is required but not found" >&2
  exit 1
fi

detect_current() {
  local model
  model=$(jq -r '.agents.sisyphus.model // empty' "$CONFIG")
  if [[ "$model" == anthropic/* ]]; then
    echo "anthropic"
  elif [[ "$model" == github-copilot/* ]]; then
    echo "copilot"
  else
    echo "unknown"
  fi
}

to_copilot() {
  jq '
    # anthropic uses hyphens (claude-opus-4-6), copilot uses dots (claude-opus-4.6)
    def hyphen_to_dot:
      # Convert last hyphen-digit segment: "claude-opus-4-6" -> "claude-opus-4.6"
      sub("(?<prefix>claude-[a-z]+-\\d+)-(?<minor>\\d+)"; "\(.prefix).\(.minor)");
    def dot_to_hyphen:
      sub("(?<prefix>claude-[a-z]+-\\d+)\\.(?<minor>\\d+)"; "\(.prefix)-\(.minor)");
    def swap:
      if .model and (.model | startswith("anthropic/claude")) then
        .model = (.model | sub("^anthropic/"; "github-copilot/") | hyphen_to_dot)
      else . end
      | if .fallback_models then
          .fallback_models = [.fallback_models[] |
            if startswith("github-copilot/claude") then
              sub("^github-copilot/"; "anthropic/") | dot_to_hyphen
            else . end]
        else . end;
    .agents |= map_values(swap) |
    .categories |= map_values(swap)
  ' "$CONFIG"
}

to_anthropic() {
  jq '
    def hyphen_to_dot:
      sub("(?<prefix>claude-[a-z]+-\\d+)-(?<minor>\\d+)"; "\(.prefix).\(.minor)");
    def dot_to_hyphen:
      sub("(?<prefix>claude-[a-z]+-\\d+)\\.(?<minor>\\d+)"; "\(.prefix)-\(.minor)");
    def swap:
      if .model and (.model | startswith("github-copilot/claude")) then
        .model = (.model | sub("^github-copilot/"; "anthropic/") | dot_to_hyphen)
      else . end
      | if .fallback_models then
          .fallback_models = [.fallback_models[] |
            if startswith("anthropic/claude") then
              sub("^anthropic/"; "github-copilot/") | hyphen_to_dot
            else . end]
        else . end;
    .agents |= map_values(swap) |
    .categories |= map_values(swap)
  ' "$CONFIG"
}

apply_swap() {
  local target="$1"
  local tmp
  tmp=$(mktemp)

  if [[ "$target" == "copilot" ]]; then
    to_copilot > "$tmp"
  else
    to_anthropic > "$tmp"
  fi

  if ! jq empty "$tmp" 2>/dev/null; then
    echo "ERROR: generated invalid JSON, aborting" >&2
    rm -f "$tmp"
    exit 1
  fi

  mv "$tmp" "$CONFIG"
  echo "Switched to: $target"
}

current=$(detect_current)
action="${1:-}"

case "$action" in
  "")
    echo "Current provider: $current"
    echo "Usage: $0 [copilot|anthropic|toggle]"
    ;;
  copilot)
    if [[ "$current" == "copilot" ]]; then
      echo "Already on copilot"
      exit 0
    fi
    apply_swap copilot
    ;;
  anthropic)
    if [[ "$current" == "anthropic" ]]; then
      echo "Already on anthropic"
      exit 0
    fi
    apply_swap anthropic
    ;;
  toggle)
    if [[ "$current" == "anthropic" ]]; then
      apply_swap copilot
    elif [[ "$current" == "copilot" ]]; then
      apply_swap anthropic
    else
      echo "ERROR: cannot detect current provider" >&2
      exit 1
    fi
    ;;
  *)
    echo "Unknown action: $action" >&2
    echo "Usage: $0 [copilot|anthropic|toggle]"
    exit 1
    ;;
esac

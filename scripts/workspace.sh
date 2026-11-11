#!/bin/zsh
# Usage: workspace.sh setup | meeting

MODE="$1"

case "$MODE" in
  setup)
    APPS=("Signal" "Notes" "Safari" "Messages" "Microsoft Teams" "Rex Beta" "Mail" "Microsoft Outlook" "Calendar" "Grok Bot")
    ;;
  meeting)
    APPS=("Safari" "Microsoft Teams" "OBS")
    ;;
  *)
    echo "Usage: workspace.sh setup|meeting"; exit 1
    ;;
esac

go_desktop4() {
  osascript -e 'tell application "System Events" to key code 21 using command down' 2>/dev/null
}

is_running() {
  [[ "$(osascript -e "application \"$1\" is running" 2>/dev/null)" == "true" ]]
}

# 1. Go to Desktop 4 first so the popup lands there
go_desktop4

# 2. Quit only visible apps that aren't part of this mode
ALWAYS_KEEP=("Finder" "Shortcuts" "Raycast" "MSTeams" "obs")
KEEP=("${APPS[@]}" "${ALWAYS_KEEP[@]}")
osascript -e 'tell application "System Events" to get name of every application process whose background only is false' \
  | tr ',' '\n' | sed 's/^ *//' | while read -r proc; do
    [[ -z "$proc" ]] && continue
    if (( ! ${KEEP[(Ie)$proc]} )); then
      osascript -e "tell application \"$proc\" to quit" 2>/dev/null
    fi
  done

# 3. Open only what isn't already running
for app in "${APPS[@]}"; do
  is_running "$app" || open -a "$app"
done

# 4. Wait until every app reports running (max 30s each)
for app in "${APPS[@]}"; do
  for i in {1..30}; do
    is_running "$app" && break
    sleep 1
  done
done

# 5. Back to Desktop 4 before the popup
go_desktop4
sleep 2

exit 0

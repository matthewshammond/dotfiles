#!/bin/zsh
# Usage: workspace.sh setup | meeting

MODE="$1"
KILL=()

case "$MODE" in
  setup)
    APPS=("Notes" "Safari" "Messages" "Signal" "Microsoft Teams" "Rex Beta" "Mail" "Microsoft Outlook" "Calendar" "Grok Bot")
    ;;
  meeting)
    APPS=("Safari" "Microsoft Teams" "OBS")
    KILL=("Micro Snitch" "Little Snitch")
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
sleep 1

# 2. Quit visible apps that aren't part of this mode
ALWAYS_KEEP=("Finder" "Shortcuts" "Raycast" "MSTeams" "obs")
KEEP=("${APPS[@]}" "${ALWAYS_KEEP[@]}")
osascript -e 'tell application "System Events" to get name of every application process whose background only is false' \
  | tr ',' '\n' | sed 's/^ *//' | while read -r proc; do
    [[ -z "$proc" ]] && continue
    if (( ! ${KEEP[(Ie)$proc]} )); then
      osascript -e "tell application \"$proc\" to quit" 2>/dev/null
    fi
  done

# Meeting only: quit menu-bar apps and Übersicht
if [[ "$MODE" == "meeting" ]]; then
  for app in "${KILL[@]}"; do
    osascript -e "quit app \"$app\"" 2>/dev/null || pkill -x "$app"
  done
  pkill -f "bersicht.app"
fi

sleep 2

# 3. Open only what isn't already running
for app in "${APPS[@]}"; do
  is_running "$app" || open -a "$app"
done

# Setup only: relaunch Übersicht
if [[ "$MODE" == "setup" ]]; then
  pgrep -f "bersicht.app" >/dev/null || open -b tracesOf.Uebersicht
fi

# 4. Wait until every app reports running (max 30s each), then let windows settle
for app in "${APPS[@]}"; do
  for i in {1..30}; do
    is_running "$app" && break
    sleep 1
  done
done
sleep 2

# 5. Back to Desktop 4 before the popup
go_desktop4
/opt/homebrew/bin/yabai --restart-service
sleep 1

exit 0

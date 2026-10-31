#!/bin/bash
# Toggle pointer size between max (4.0) and the previous size. Prints new state: on|off
DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$DIR/bin/cursor_size"
[ -x "$BIN" ] || (cd "$DIR" && make >/dev/null 2>&1)
STATE="$HOME/.cache/cursor-size-prev"
mkdir -p "$HOME/.cache"
cur=$("$BIN")
if [ "$1" = "status" ]; then
  awk -v c="$cur" 'BEGIN{print (c>=3.9)?"on":"off"}'; exit 0
fi
if awk -v c="$cur" 'BEGIN{exit !(c>=3.9)}'; then
  prev=$(cat "$STATE" 2>/dev/null); [ -z "$prev" ] && prev=1.0
  awk -v p="$prev" 'BEGIN{exit !(p>=3.9)}' && prev=1.0
  "$BIN" "$prev" && echo off
else
  echo "$cur" > "$STATE"
  "$BIN" 4.0 && echo on
fi

#!/usr/bin/env bash
# Claude Code Status Line — Powerline-style, Nord palette, p10k-inspired

input=$(cat)

# ── Parse JSON fields ──────────────────────────────────────────────────────────
cwd=$(echo "$input"        | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input"      | jq -r '.model.display_name // ""')
used_pct=$(echo "$input"   | jq -r '.context_window.used_percentage // empty')
used_tok=$(echo "$input"   | jq -r '.context_window.used_tokens // empty')
vim_mode=$(echo "$input"   | jq -r '.vim.mode // ""')
session=$(echo "$input"    | jq -r '.session_name // ""')
worktree=$(echo "$input"   | jq -r '.worktree.name // ""')
agent=$(echo "$input"      | jq -r '.agent.name // ""')

# Rate limits — usage % + reset timestamps (Unix epoch integers)
five_pct=$(echo "$input"     | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input"   | jq -r '.rate_limits.five_hour.resets_at // empty')
week_pct=$(echo "$input"     | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset=$(echo "$input"   | jq -r '.rate_limits.seven_day.resets_at // empty')

# ── ANSI helpers ───────────────────────────────────────────────────────────────
reset="\033[0m"
bold="\033[1m"
dim="\033[2m"
fg() { printf "\033[38;5;%sm" "$1"; }
bg() { printf "\033[48;5;%sm" "$1"; }

# Nord-adjacent 256-color palette
C_BG=236        # near-black background
C_SEP=238       # separator bg
C_CYAN=81       # bright cyan      — path
C_BLUE=69       # steel blue       — model
C_GREEN=114     # muted green      — low usage / staged
C_YELLOW=221    # warm yellow      — mid usage / unstaged
C_ORANGE=208    # orange           — high usage
C_RED=196       # red              — critical
C_MAGENTA=141   # purple           — vim / git branch
C_WHITE=253     # off-white
C_DARK=233      # darkest bg
C_TEAL=73       # teal             — worktree
C_PINK=211      # salmon/pink      — session name accent

# Powerline + Nerd Font glyphs
SEP_R=""        # solid right arrow
SEP_L=""        # solid left arrow
SEP_THIN_R=""   # thin right arrow
BRANCH_ICO=""   # git branch
CLOCK_ICO=""    # clock (Nerd Font)
TOKEN_ICO="⬡"   # token hexagon

# ── Color picker by percentage ─────────────────────────────────────────────────
pct_color() {
  local p=$1
  if   [ "$p" -ge 90 ]; then echo $C_RED
  elif [ "$p" -ge 70 ]; then echo $C_ORANGE
  elif [ "$p" -ge 40 ]; then echo $C_YELLOW
  else                        echo $C_GREEN
  fi
}

# ── Format remaining time from an ISO-8601 reset timestamp ────────────────────
# Returns e.g. "1h23m" or "5.3d" or "47m" or empty if unavailable
time_remaining() {
  local reset_ts="$1"
  [ -z "$reset_ts" ] && return
  local reset_epoch="$reset_ts"   # already a Unix epoch integer
  local now
  now=$(date +%s)
  local diff=$(( reset_epoch - now ))
  [ "$diff" -le 0 ] && return
  local days=$(( diff / 86400 ))
  local hours=$(( (diff % 86400) / 3600 ))
  local mins=$(( (diff % 3600) / 60 ))
  if [ "$days" -ge 1 ]; then
    # e.g. "5.3d"
    local frac=$(( (hours * 10) / 24 ))
    printf "%d.%dd" "$days" "$frac"
  elif [ "$hours" -ge 1 ]; then
    printf "%dh%02dm" "$hours" "$mins"
  else
    printf "%dm" "$mins"
  fi
}

# ── Format token count → human readable ───────────────────────────────────────
fmt_tokens() {
  local t="$1"
  [ -z "$t" ] && return
  if [ "$t" -ge 1000000 ]; then
    printf "%.1fM" "$(echo "scale=1; $t/1000000" | bc 2>/dev/null || echo 0)"
  elif [ "$t" -ge 1000 ]; then
    printf "%dk" "$(( t / 1000 ))"
  else
    printf "%d" "$t"
  fi
}

# ── Git info (fast, no locking) ────────────────────────────────────────────────
git_info=""
if git -C "$cwd" rev-parse --git-dir --no-optional-locks &>/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  st=$(git -C "$cwd" status --porcelain --no-optional-locks 2>/dev/null)
  staged=$(echo "$st"   | grep -c '^[MADRCU]' 2>/dev/null || echo 0)
  unstaged=$(echo "$st" | grep -c '^.[MADRCU?]' 2>/dev/null || echo 0)
  dirty=""
  [ "$staged"   -gt 0 ] && dirty="${dirty}$(fg $C_GREEN)+${staged}${reset}"
  [ "$unstaged" -gt 0 ] && dirty="${dirty}$(fg $C_YELLOW)~${unstaged}${reset}"
  git_info="${BRANCH_ICO} ${branch}${dirty:+ $dirty}"
fi

# ── Context bar (12 cells) ─────────────────────────────────────────────────────
ctx_bar=""
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  bar_color=$(pct_color "$used_int")
  filled=$(( used_int * 12 / 100 ))
  [ "$filled" -gt 12 ] && filled=12
  empty=$(( 12 - filled ))
  bar="$(fg $bar_color)"
  for _ in $(seq 1 "$filled" 2>/dev/null); do bar="${bar}█"; done
  bar="${bar}$(fg 240)"
  for _ in $(seq 1 "$empty"  2>/dev/null); do bar="${bar}░"; done
  bar="${bar}${reset}"
  tok_str=""
  if [ -n "$used_tok" ]; then
    tok_str=" · $(fmt_tokens "$used_tok")"
  fi
  ctx_bar="${bar} $(fg $bar_color)${used_int}%${reset}$(fg 244)${tok_str}${reset}"
fi

# ── Rate limit segments ────────────────────────────────────────────────────────
fmt_rate() {
  local pct="$1" reset_ts="$2" label="$3"
  [ -z "$pct" ] && return
  local p
  p=$(printf "%.0f" "$pct")
  local color
  color=$(pct_color "$p")
  local remain
  remain=$(time_remaining "$reset_ts")
  local suffix=""
  [ -n "$remain" ] && suffix="$(fg 244) (${remain})${reset}"
  printf "%b" "$(fg $color)${label}:${p}%${reset}${suffix}"
}

rate_5h=$(fmt_rate "$five_pct" "$five_reset" "5h")
rate_7d=$(fmt_rate "$week_pct" "$week_reset" "7d")

# ── Shorten path (keep last 3 segments, highlight repo root) ──────────────────
short_path=$(echo "$cwd" | sed "s|$HOME|~|" | awk -F'/' '{
  n=NF; if(n<=3){print $0} else {printf "…/%s/%s/%s", $(n-2), $(n-1), $n}
}')

# ── Privilege indicator ────────────────────────────────────────────────────────
if [ "$(id -u)" = "0" ]; then
  priv_icon="$(fg $C_RED)#${reset}"
else
  priv_icon="$(fg $C_GREEN)\$${reset}"
fi

# ── Assemble output ────────────────────────────────────────────────────────────
out=""

# Vim mode badge
if [ "$vim_mode" = "NORMAL" ]; then
  out="${out}$(bg $C_MAGENTA)$(fg $C_DARK)${bold} N $(fg $C_MAGENTA)$(bg $C_BG)${SEP_R}${reset} "
elif [ "$vim_mode" = "INSERT" ]; then
  out="${out}$(bg $C_GREEN)$(fg $C_DARK)${bold} I $(fg $C_GREEN)$(bg $C_BG)${SEP_R}${reset} "
elif [ "$vim_mode" = "VISUAL" ]; then
  out="${out}$(bg $C_YELLOW)$(fg $C_DARK)${bold} V $(fg $C_YELLOW)$(bg $C_BG)${SEP_R}${reset} "
fi

# Privilege + working dir
out="${out}${priv_icon} $(fg $C_CYAN)${bold}${short_path}${reset}"

# Git branch
if [ -n "$git_info" ]; then
  out="${out}  $(fg $C_MAGENTA)${git_info}${reset}"
fi

# Worktree / Agent
if [ -n "$worktree" ]; then
  out="${out}  $(fg $C_TEAL)⎇ ${worktree}${reset}"
fi
if [ -n "$agent" ]; then
  out="${out}  $(fg $C_ORANGE)⚙ ${agent}${reset}"
fi

# Thin separator
out="${out}  $(fg $C_SEP)${SEP_THIN_R}${reset}  "

# Model
if [ -n "$model" ]; then
  out="${out}$(fg $C_BLUE)${bold}✦ ${model}${reset}"
fi

# Context window bar
if [ -n "$ctx_bar" ]; then
  out="${out}  $(fg 244)ctx ${reset}${ctx_bar}"
fi

# Rate limits with time remaining
if [ -n "$rate_5h" ] || [ -n "$rate_7d" ]; then
  out="${out}  $(fg 244)limits ${reset}"
  if [ -n "$rate_5h" ]; then
    out="${out}${rate_5h}"
  fi
  if [ -n "$rate_5h" ] && [ -n "$rate_7d" ]; then
    out="${out}  $(fg 240)│${reset}  "
  fi
  if [ -n "$rate_7d" ]; then
    out="${out}${rate_7d}"
  fi
fi

# Session name
if [ -n "$session" ]; then
  out="${out}  $(fg $C_PINK)${dim}# ${session}${reset}"
fi

printf "%b" "$out"

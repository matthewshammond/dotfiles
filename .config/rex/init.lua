-- Rex config migrated from tmux, zellij, Herdr and Ghostty.

-- Runs an action, then leaves every mode (zellij's SwitchToMode "Normal").
rex.action{
  name  = "then_normal",
  title = "Run an action and return to normal mode",
  args  = { action = "string", args = "object?" },
  run   = function(ctx, args)
    rex.client.queue(args.action, args.args or {})
    rex.client.queue("client.mode.exit_all")
  end,
}

------------------------------------------------------------------------------
-- cmd+k: clear the terminal (your choice); session picker moves to shift+cmd+k
------------------------------------------------------------------------------
rex.bind("shift+cmd+k", "session.switch")

------------------------------------------------------------------------------
-- tmux (~/.tmux.conf), prefix alt+a
------------------------------------------------------------------------------
rex.bind("alt+a>alt+a", "pane.send_key", { key = "alt+a" })
rex.bind("alt+1", "client.tab.goto", { index = 1 })
rex.bind("alt+2", "client.tab.goto", { index = 2 })
rex.bind("alt+3", "client.tab.goto", { index = 3 })
rex.bind("alt+4", "client.tab.goto", { index = 4 })
rex.bind("alt+5", "client.tab.goto", { index = 5 })
rex.bind("alt+6", "client.tab.goto", { index = 6 })
rex.bind("alt+7", "client.tab.goto", { index = 7 })
rex.bind("alt+8", "client.tab.goto", { index = 8 })
rex.bind("alt+9", "client.tab.goto", { index = 9 })
rex.bind("alt+a>r", "client.config.reload")
rex.bind("alt+s", "session.switch")

------------------------------------------------------------------------------
-- Herdr (~/.config/herdr/config.toml), prefix alt+a
------------------------------------------------------------------------------
rex.bind("alt+d", "pane.split", { direction = "right" })
rex.bind("alt+shift+d", "pane.split", { direction = "down" })
rex.bind("alt+w", "pane.close")
rex.bind("alt+[", "pane.focus_previous")
rex.bind("alt+]", "pane.focus_next")
rex.bind("alt+h", "pane.focus", { direction = "left" })
rex.bind("alt+j", "pane.focus", { direction = "down" })
rex.bind("alt+k", "pane.focus", { direction = "up" })
rex.bind("alt+l", "pane.focus", { direction = "right" })
rex.bind("alt+shift+[", "client.tab.previous")
rex.bind("alt+shift+]", "client.tab.next")
rex.bind("alt+t", "client.tab.new")
rex.bind("alt+n", "session.new")
rex.bind("alt+a>g", "session.switch")
rex.bind("alt+a>e", "client.sidebar.toggle")
rex.bind("cmd+k", "com.superlogical.terminal.clear")

------------------------------------------------------------------------------
-- Ghostty (~/.config/ghostty/config)
------------------------------------------------------------------------------
rex.bind("alt+shift+,", "client.config.reload")

------------------------------------------------------------------------------
-- zellij (~/.config/zellij/config.kdl, clear-defaults=true)
------------------------------------------------------------------------------
-- Modes you stay in until you leave them.
for _, m in ipairs({ "pane", "tab", "resize", "move", "scroll", "session", "tmux" }) do
  rex.mode(m, { exclusive = true })
end

-- Normal mode (no Rex mode). alt+h/j/k/l and alt+n lost to Herdr.
rex.bind("alt+left", "pane.focus", { direction = "left" })
rex.bind("alt+down", "pane.focus", { direction = "down" })
rex.bind("alt+up", "pane.focus", { direction = "up" })
rex.bind("alt+right", "pane.focus", { direction = "right" })
rex.bind("alt+i", "client.tab.move", { direction = "backward" })
rex.bind("alt+o", "client.tab.move", { direction = "forward" })
rex.bind("ctrl+g", "client.mode.enter", { name = "locked" })
rex.bind("ctrl+h", "client.mode.enter", { name = "move" })
rex.bind("ctrl+o", "client.mode.enter", { name = "session" })
rex.bind("ctrl+b", "client.mode.enter", { name = "tmux" })
rex.bind("ctrl+s", "client.mode.enter", { name = "scroll" })
rex.bind("ctrl+t", "client.mode.enter", { name = "tab" })
rex.bind("ctrl+p", "client.mode.enter", { name = "pane" })
rex.bind("ctrl+n", "client.mode.enter", { name = "resize" })

-- locked: zellij's keys reach the program until ctrl+g.
rex.bind("locked/ctrl+g", "client.mode.exit_all")
for _, k in ipairs({ "alt+left", "alt+down", "alt+up", "alt+right", "alt+i", "alt+o",
                     "ctrl+h", "ctrl+o", "ctrl+b", "ctrl+s", "ctrl+t", "ctrl+p", "ctrl+n" }) do
  rex.bind("locked/" .. k, "pane.send_key", { key = k })
end

-- shared_except "locked" (lines 129-146) and the mode keys (lines 150-168),
-- in every mode except locked.
local enters = {
  ["ctrl+h"] = "move", ["ctrl+o"] = "session", ["ctrl+b"] = "tmux", ["ctrl+s"] = "scroll",
  ["ctrl+t"] = "tab", ["ctrl+p"] = "pane", ["ctrl+n"] = "resize",
}
local not_in = { ["ctrl+b"] = { scroll = true, tmux = true }, ["ctrl+s"] = { scroll = true } }
for _, m in ipairs({ "pane", "tab", "resize", "move", "scroll", "session", "tmux" }) do
  rex.bind(m .. "/alt+left", "pane.focus", { direction = "left" })
  rex.bind(m .. "/alt+down", "pane.focus", { direction = "down" })
  rex.bind(m .. "/alt+up", "pane.focus", { direction = "up" })
  rex.bind(m .. "/alt+right", "pane.focus", { direction = "right" })
  rex.bind(m .. "/alt+h", "pane.focus", { direction = "left" })
  rex.bind(m .. "/alt+j", "pane.focus", { direction = "down" })
  rex.bind(m .. "/alt+k", "pane.focus", { direction = "up" })
  rex.bind(m .. "/alt+l", "pane.focus", { direction = "right" })
  rex.bind(m .. "/alt+i", "client.tab.move", { direction = "backward" })
  rex.bind(m .. "/alt+o", "client.tab.move", { direction = "forward" })
  rex.bind(m .. "/alt+n", "pane.split", { direction = "auto" })
  rex.bind(m .. "/ctrl+g", "client.mode.enter", { name = "locked" })
  for key, target in pairs(enters) do
    if target ~= m and not (not_in[key] and not_in[key][m]) then
      rex.bind(m .. "/" .. key, "client.mode.enter", { name = target })
    end
  end
  rex.bind(m .. "/enter", "client.mode.exit_all")
  rex.bind(m .. "/esc", "client.mode.exit_all")
end

-- pane
rex.bind("pane/left", "pane.focus", { direction = "left" })
rex.bind("pane/down", "pane.focus", { direction = "down" })
rex.bind("pane/up", "pane.focus", { direction = "up" })
rex.bind("pane/right", "pane.focus", { direction = "right" })
rex.bind("pane/c", "then_normal", { action = "pane.rename" })
rex.bind("pane/d", "then_normal", { action = "pane.split", args = { direction = "down" } })
rex.bind("pane/f", "then_normal", { action = "pane.zoom" })
rex.bind("pane/h", "pane.focus", { direction = "left" })
rex.bind("pane/j", "pane.focus", { direction = "down" })
rex.bind("pane/k", "pane.focus", { direction = "up" })
rex.bind("pane/l", "pane.focus", { direction = "right" })
rex.bind("pane/n", "then_normal", { action = "pane.split", args = { direction = "auto" } })
rex.bind("pane/p", "pane.focus_next")
rex.bind("pane/ctrl+p", "client.mode.exit_all")
rex.bind("pane/r", "then_normal", { action = "pane.split", args = { direction = "right" } })
rex.bind("pane/x", "then_normal", { action = "pane.close" })

-- tab
rex.bind("tab/left", "client.tab.previous")
rex.bind("tab/down", "client.tab.next")
rex.bind("tab/up", "client.tab.previous")
rex.bind("tab/right", "client.tab.next")
for i = 1, 9 do
  rex.bind("tab/" .. i, "then_normal", { action = "client.tab.goto", args = { index = i } })
end
rex.bind("tab/b", "then_normal", { action = "pane.move_to_new_tab" })
rex.bind("tab/h", "client.tab.previous")
rex.bind("tab/j", "client.tab.next")
rex.bind("tab/k", "client.tab.previous")
rex.bind("tab/l", "client.tab.next")
rex.bind("tab/n", "then_normal", { action = "client.tab.new" })
rex.bind("tab/r", "then_normal", { action = "client.tab.rename" })
rex.bind("tab/ctrl+t", "client.mode.exit_all")
rex.bind("tab/x", "then_normal", { action = "client.tab.close" })

-- resize
rex.bind("resize/left", "pane.resize", { direction = "left" })
rex.bind("resize/down", "pane.resize", { direction = "down" })
rex.bind("resize/up", "pane.resize", { direction = "up" })
rex.bind("resize/right", "pane.resize", { direction = "right" })
rex.bind("resize/h", "pane.resize", { direction = "left" })
rex.bind("resize/j", "pane.resize", { direction = "down" })
rex.bind("resize/k", "pane.resize", { direction = "up" })
rex.bind("resize/l", "pane.resize", { direction = "right" })
rex.bind("resize/ctrl+n", "client.mode.exit_all")

-- move
rex.bind("move/left", "pane.move", { direction = "left" })
rex.bind("move/down", "pane.move", { direction = "down" })
rex.bind("move/up", "pane.move", { direction = "up" })
rex.bind("move/right", "pane.move", { direction = "right" })
rex.bind("move/h", "pane.move", { direction = "left" })
rex.bind("move/ctrl+h", "client.mode.exit_all")
rex.bind("move/j", "pane.move", { direction = "down" })
rex.bind("move/k", "pane.move", { direction = "up" })
rex.bind("move/l", "pane.move", { direction = "right" })

-- scroll
rex.bind("scroll/ctrl+s", "client.mode.exit_all")

-- session
rex.bind("session/ctrl+o", "client.mode.exit_all")

-- tmux
rex.bind("tmux/left", "then_normal", { action = "pane.focus", args = { direction = "left" } })
rex.bind("tmux/down", "then_normal", { action = "pane.focus", args = { direction = "down" } })
rex.bind("tmux/up", "then_normal", { action = "pane.focus", args = { direction = "up" } })
rex.bind("tmux/right", "then_normal", { action = "pane.focus", args = { direction = "right" } })
rex.bind("tmux/shift+'", "then_normal", { action = "pane.split", args = { direction = "down" } })
rex.bind("tmux/shift+5", "then_normal", { action = "pane.split", args = { direction = "right" } })
rex.bind("tmux/,", "then_normal", { action = "client.tab.rename" })
rex.bind("tmux/[", "client.mode.enter", { name = "scroll" })
rex.bind("tmux/ctrl+b", "then_normal", { action = "pane.send_key", args = { key = "ctrl+b" } })
rex.bind("tmux/c", "then_normal", { action = "client.tab.new" })
rex.bind("tmux/h", "then_normal", { action = "pane.focus", args = { direction = "left" } })
rex.bind("tmux/j", "then_normal", { action = "pane.focus", args = { direction = "down" } })
rex.bind("tmux/k", "then_normal", { action = "pane.focus", args = { direction = "up" } })
rex.bind("tmux/l", "then_normal", { action = "pane.focus", args = { direction = "right" } })
rex.bind("tmux/n", "then_normal", { action = "client.tab.next" })
rex.bind("tmux/o", "pane.focus_next")
rex.bind("tmux/p", "then_normal", { action = "client.tab.previous" })
rex.bind("tmux/z", "then_normal", { action = "pane.zoom" })
rex.bind("tmux/x", "then_normal", { action = "pane.close" })

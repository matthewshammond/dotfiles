local hosts = {}

local function hide_all()
	for _, host in ipairs(hosts) do
		host:set({ popup = { drawing = "off" } })
	end
end

local M = {}

function M.controller(host, opts)
	table.insert(hosts, host)
	local token = 0
	local hide_delay = (opts and opts.hide_delay) or 0.08

	local function keep()
		token = token + 1
		for _, other in ipairs(hosts) do
			if other ~= host then
				other:set({ popup = { drawing = "off" } })
			end
		end
		host:set({ popup = { drawing = "on" } })
	end

	local function hide_now()
		token = token + 1
		hide_all()
	end

	-- Cancelled if keep() runs first (sibling icon or volume slider).
	local function hide_soon()
		token = token + 1
		local mine = token
		sbar.delay(hide_delay, function()
			if mine == token then
				hide_all()
			end
		end)
	end

	local function bind_icon(item)
		item:subscribe("mouse.entered", keep)
		item:subscribe("mouse.exited", hide_now)
	end

	local function bind_sticky(item)
		item:subscribe("mouse.entered", keep)
		item:subscribe("mouse.exited", hide_soon)
	end

	return {
		keep = keep,
		hide_now = hide_now,
		hide_soon = hide_soon,
		bind_icon = bind_icon,
		bind_sticky = bind_sticky,
	}
end

return M

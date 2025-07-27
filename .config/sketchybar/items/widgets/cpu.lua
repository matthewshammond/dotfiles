local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0")

local cpu = sbar.add("graph", "widgets.cpu" , 42, {
  position = "right",
  graph = { color = colors.yellow },
  background = {
    height = 28,
    color = colors.transparent or 0x00000000,  -- Fallback to hex value
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = { 
    string = icons.cpu,
    color = colors.cpu_widget_icon or colors.white,
  },
  label = {
    string = "cpu ??%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    align = "right",
    padding_right = 0,
    width = 0,
    y_offset = 4
  },
  padding_right = settings.paddings + 6
})

-- Function to update CPU colors based on current theme
local function update_cpu_colors()
    local query_result = cpu:query()
    local label_string = query_result and query_result.label and query_result.label.string or "cpu 0%"
    local load = tonumber(label_string:match("cpu (%d+)%%") or "0")
    
    -- Use custom widget colors if available, otherwise fall back to standard colors
    local graph_color = colors.cpu_widget_graph or colors.orange
    local text_color = colors.cpu_widget_text or colors.white
    
    if load > 30 then
        if load < 60 then
            graph_color = colors.cpu_widget_graph or colors.yellow
        elseif load < 80 then
            graph_color = colors.cpu_widget_graph or colors.orange
        else
            graph_color = colors.cpu_widget_graph or colors.red
        end
    end
    
    cpu:set({
        graph = { color = graph_color },
        icon = { color = colors.cpu_widget_icon or colors.white },
        label = { color = text_color },
    })
end

cpu:subscribe("cpu_update", function(env)
  -- Also available: env.user_load, env.sys_load
  local load = tonumber(env.total_load)
  cpu:push({ load / 100. })

  -- Use custom widget colors if available, otherwise fall back to standard colors
  local graph_color = colors.cpu_widget_graph or colors.orange
  local text_color = colors.cpu_widget_text or colors.white
  
  if load > 30 then
    if load < 60 then
      graph_color = colors.cpu_widget_graph or colors.yellow
    elseif load < 80 then
      graph_color = colors.cpu_widget_graph or colors.orange
    else
      graph_color = colors.cpu_widget_graph or colors.red
    end
  end

  cpu:set({
    graph = { color = graph_color },
    icon = { color = colors.cpu_widget_icon or colors.white },
    label = { 
      string = "cpu " .. env.total_load .. "%",
      color = text_color,
    },
  })
end)

-- Subscribe to theme changes
cpu:subscribe("theme_changed", function()
    update_cpu_colors()
end)

cpu:subscribe("mouse.clicked", function(env)
  sbar.exec("open -a 'Activity Monitor'")
end)

-- Background around the cpu item
sbar.add("bracket", "widgets.cpu.bracket", { cpu.name }, {
  background = { 
    color = colors.cpu_widget_bg or colors.transparent, 
    border_width = 0, 
  }
})

-- Background around the cpu item
sbar.add("item", "widgets.cpu.padding", {
  position = "right",
  width = settings.group_paddings
})

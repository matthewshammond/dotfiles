local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local popup = require("helpers.popup")

local popup_width = 250

local volume_percent = sbar.add("item", "widgets.volume1", {
  position = "right",
  icon = { drawing = false },
  label = {
    string = "??%",
    padding_left = -1,
    font = { family = settings.font.numbers },
    color = colors.volume_widget_text or colors.white,
  },
})

local volume_icon = sbar.add("item", "widgets.volume2", {
  position = "right",
  padding_right = -1,
  icon = {
    string = icons.volume._100,
    width = 0,
    align = "left",
    color = colors.volume_widget_icon or colors.bg2,
    font = {
      style = settings.font.style_map["Regular"],
      size = 14.0,
    },
  },
  label = {
    width = 25,
    align = "left",
    color = colors.volume_widget_text or colors.white,
    font = {
      style = settings.font.style_map["Regular"],
      size = 14.0,
      color = colors.bg2 or 0xff3c3836,  -- Fallback to hex value
    },
  },
})

local volume_bracket = sbar.add("bracket", "widgets.volume.bracket", {
  volume_icon.name,
  volume_percent.name
}, {
  background = { color = colors.volume_widget_bg or colors.transparent },
  popup = { align = "center" }
})

sbar.add("item", "widgets.volume.padding", {
  position = "right",
  width = settings.group_paddings
})

local volume_slider = sbar.add("slider", popup_width, {
  position = "popup." .. volume_bracket.name,
  slider = {
    background = {
      height = 6,
      corner_radius = 3,
      color = colors.bg1 or 0xff2d2d2d,  -- Fallback to hex value
    },
    knob= {
      string = "􀀁",
      drawing = true,
    },
  },
  background = { color = colors.bg1 or 0xff2d2d2d, height = 2, y_offset = -20 },  -- Fallback to hex value
  click_script = 'osascript -e "set volume output volume $PERCENTAGE"'
})

volume_percent:subscribe("volume_change", function(env)
  local volume = tonumber(env.INFO)
  local icon = icons.volume._0
  if volume > 60 then
    icon = icons.volume._100
  elseif volume > 30 then
    icon = icons.volume._66
  elseif volume > 10 then
    icon = icons.volume._33
  elseif volume > 0 then
    icon = icons.volume._10
  end

  local lead = ""
  if volume < 10 then
    lead = "0"
  end

  volume_icon:set({ label = icon })
  volume_percent:set({ label = lead .. volume .. "%" })
  volume_slider:set({ slider = { percentage = volume } })
end)

local volume_popup = popup.controller(volume_bracket)
volume_popup.bind_sticky(volume_slider)

local current_audio_device = "None"
local function volume_show_details(env)
  if env and env.BUTTON == "right" then
    sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
    return
  end

  local drawing = volume_bracket:query().popup.drawing
  local already_open = drawing == "on" or drawing == true
  volume_popup.keep()
  if already_open then
    return
  end

  sbar.remove('/volume.device\\.*/')
  sbar.exec("SwitchAudioSource -t output -c", function(result)
    current_audio_device = result:sub(1, -2)
    sbar.exec("SwitchAudioSource -a -t output", function(available)
      local counter = 0
      for device in string.gmatch(available, '[^\r\n]+') do
        local device_item = sbar.add("item", "volume.device." .. counter, {
          position = "popup." .. volume_bracket.name,
          width = popup_width,
          align = "center",
          label = { string = device, color = colors.yellow },
          click_script = 'SwitchAudioSource -s "' .. device .. '"'
        })
        volume_popup.bind_sticky(device_item)
        counter = counter + 1
      end
    end)
  end)
end

local function volume_scroll(env)
  local delta = env.SCROLL_DELTA
  sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume_popup.bind_sticky(volume_icon)
volume_popup.bind_sticky(volume_percent)
volume_icon:subscribe("mouse.clicked", volume_show_details)
volume_icon:subscribe("mouse.entered", volume_show_details)
volume_icon:subscribe("mouse.scrolled", volume_scroll)
volume_percent:subscribe("mouse.clicked", volume_show_details)
volume_percent:subscribe("mouse.entered", volume_show_details)
volume_percent:subscribe("mouse.scrolled", volume_scroll)

-- Subscribe to theme changes to update colors
volume_percent:subscribe("theme_changed", function()
    volume_percent:set({
        label = { color = colors.volume_widget_text or colors.white }
    })
end)

volume_icon:subscribe("theme_changed", function()
    volume_icon:set({
        icon = { color = colors.volume_widget_icon or colors.bg2 }
    })
end)


local icons = require("icons")
local colors = require("colors")

local whitelist = { ["Spotify"] = true,
                    ["Music"] = true    };

-- Simplified media widget based on SketchyBar creator's example
local media = sbar.add("item", {
  position = "right",
  icon = { drawing = false },
  drawing = false,
  updates = "on",  -- Explicitly set updates=on as suggested by creator
  popup = {
    align = "right",
    horizontal = true,
  }
})

sbar.add("item", {
  position = "popup." .. media.name,
  icon = { 
    string = icons.media.back,
  },
  label = { drawing = false },
  click_script = "osascript -e 'tell application \"System Events\" to key code 123'",
})
sbar.add("item", {
  position = "popup." .. media.name,
  icon = { 
    string = icons.media.play_pause,
  },
  label = { drawing = false },
  click_script = "osascript -e 'tell application \"System Events\" to key code 49'",
})
sbar.add("item", {
  position = "popup." .. media.name,
  icon = { 
    string = icons.media.forward,
  },
  label = { drawing = false },
  click_script = "osascript -e 'tell application \"System Events\" to key code 124'",
})



-- Simplified media change handler based on creator's example
media:subscribe("media_change", function(env)
  -- Debug: Print what app is being detected
  print("Media app detected: " .. (env.INFO.app or "nil"))
  print("Media state: " .. (env.INFO.state or "nil"))
  print("Artist: " .. (env.INFO.artist or "nil"))
  print("Title: " .. (env.INFO.title or "nil"))
  
  if whitelist[env.INFO.app] then
    media:set({
      drawing = (env.INFO.state == "playing") and true or false,
      label = (env.INFO.artist or "") .. ": " .. (env.INFO.title or "")
    })
  else
    print("App not in whitelist: " .. (env.INFO.app or "nil"))
  end
end)

media:subscribe("mouse.clicked", function(env)
  media:set({ popup = { drawing = "toggle" }})
end)

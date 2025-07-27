# SketchyBar Theme System

A comprehensive theme system for [SketchyBar](https://github.com/FelixKratz/SketchyBar) that allows complete customization of colors for all widgets, spaces, and UI elements.

## Credits

This theme system is built on top of:
- **[SketchyBar](https://github.com/FelixKratz/SketchyBar)** - A highly customizable macOS status bar replacement by [@FelixKratz](https://github.com/FelixKratz)
- **[SbarLua](https://github.com/FelixKratz/SbarLua)** - A Lua API for SketchyBar

## Features

- **Multiple Built-in Themes**: Nord, Dark, Light, Dracula, Tokyo Night, Waves, and more
- **Theme Cycling**: Click the Apple icon to cycle through themes
- **Complete Widget Customization**: Customize colors for CPU, WiFi, Battery, Volume widgets
- **Widget Management**: Enable/disable widgets and reorder them easily
- **Space Customization**: Full control over space colors and appearance
- **Minimal & Full Themes**: Support for both minimal (icons only) and full (with app icons) themes
- **Automatic Theme Detection**: Themes are automatically loaded from the `themes/` directory
- **Future-Proof**: Easy to add new themes and widgets

## Installation

### Prerequisites

1. **Install SketchyBar**:
   ```bash
   # Using Homebrew
   brew install sketchybar
   
   # Or build from source
   git clone https://github.com/FelixKratz/SketchyBar.git
   cd SketchyBar
   make
   sudo make install
   ```

2. **Install SbarLua**:
   ```bash
   # Clone SbarLua
   git clone https://github.com/FelixKratz/SbarLua.git ~/.config/sketchybar/sbarlua
   
   # Add to your shell profile (.zshrc, .bashrc, etc.)
   echo 'export CONFIG_DIR="$HOME/.config/sketchybar"' >> ~/.zshrc
   source ~/.zshrc
   ```

### Setup This Configuration

1. **Clone this repository**:
   ```bash
   git clone <your-repo-url> ~/.config/sketchybar
   cd ~/.config/sketchybar
   ```

2. **Install dependencies**:
   ```bash
   # Install required fonts
   brew install --cask font-sf-pro
   brew install --cask font-jetbrains-mono
   
   # Or download manually from:
   # https://developer.apple.com/fonts/sf-pro/
   # https://www.jetbrains.com/lp/mono/
   ```

3. **Build event providers**:
   ```bash
   cd helpers/event_providers
   make
   cd ../..
   ```

4. **Start SketchyBar**:
   ```bash
   # Start the service
   brew services start sketchybar
   
   # Or run manually
   sketchybar --config ~/.config/sketchybar/sketchybarrc
   ```

## Usage

### Theme Cycling

- **Click the Apple icon** (🍎) in the status bar to cycle through themes
- **Right-click the Apple icon** to access the original menu system

### Available Themes

- **Nord** - Minimal Nord theme with space icons only
- **Nord - Full** - Full Nord theme with app icons
- **Dark** - Clean dark theme
- **Light** - Light theme for bright environments
- **Dracula** - Purple-based dark theme
- **Tokyo Night** - Blue-based dark theme
- **Waves** - Minimal theme matching wave backgrounds

## Widget Management

### Enable/Disable Widgets

Each theme file has a `widgets` section where you can control which widgets appear:

```lua
-- In your theme file (e.g., waves.lua)
widgets = {
    "cpu",      -- Enable CPU widget
    -- "wifi",   -- Comment out to disable WiFi widget
    "volume",   -- Enable Volume widget
    "battery",  -- Enable Battery widget
}
```

### Reorder Widgets

The order widgets appear (left to right) is determined by their order in the `widgets` array:

```lua
widgets = {
    "battery",  -- Battery widget (leftmost)
    "cpu",      -- CPU widget
    "volume",   -- Volume widget
    "wifi",     -- WiFi widget (rightmost)
}
```

### Available Widgets

- **cpu** - CPU usage with graph
- **wifi** - Network upload/download speeds
- **volume** - Volume control with percentage
- **battery** - Battery status with percentage

### Adding New Widgets

The system is designed to be easily extensible. To add a new widget:

1. **Create the widget file** (e.g., `items/widgets/memory.lua`)
2. **Add to widget registry** in `items/widgets/init.lua`:
   ```lua
   local WIDGET_REGISTRY = {
       cpu = "items.widgets.cpu",
       wifi = "items.widgets.wifi",
       volume = "items.widgets.volume",
       battery = "items.widgets.battery",
       memory = "items.widgets.memory",  -- Add new widget here
   }
   ```
3. **Add to theme files** as needed:
   ```lua
   widgets = {
       "cpu",
       "memory",  -- Enable new widget
       "battery",
   }
   ```

The widget will automatically be available in all themes!

### Example: Minimal Setup

```lua
widgets = {
    "cpu",      -- Only show CPU widget
    "battery",  -- And battery widget
}
```

## Creating New Themes

### Step 1: Copy the Sample Template

```bash
cp themes/sample.lua themes/my_new_theme.lua
```

### Step 2: Edit Your Theme

Open `themes/my_new_theme.lua` and modify the colors. The file will contain a complete template with all possible customization options:

```lua
-- Sample Theme Template
-- Copy this file and rename it to your theme name (e.g., my_theme.lua)
-- Then edit the colors and remove/comment out any widget variables you don't want to customize

return {
    -- ========================================
    -- REQUIRED: Basic Theme Properties
    -- ========================================
    name = "My New Theme",
    
    -- Theme behavior: true for minimal themes (icons only), false for full themes (with app icons)
    minimal_spaces = true,
    
    -- ========================================
    -- REQUIRED: Basic Colors
    -- ========================================
    colors = {
        -- Core colors (required for all themes)
        black = 0xff1a1a1a,
        white = 0xffffffff,
        red = 0xffd65d0e,
        green = 0xff689d6a,
        blue = 0xff458588,
        yellow = 0xffd79921,
        orange = 0xffd65d0e,
        magenta = 0xffb16286,
        grey = 0xffd5c4a1,
        transparent = 0x00000000,
        
        -- Border colors
        border = 0x00000000,
        border2 = 0x00000000,
        
        -- Bar configuration
        bar = {
            bg = 0x00000000,      -- Bar background
            border = 0xffd65d0e,  -- Bar border
        },
        
        -- Popup configuration
        popup = {
            bg = 0xff2d2d2d,      -- Popup background
            border = 0x3bd65d0e,  -- Popup border
        },
        
        -- Background colors
        bg1 = 0xff2d2d2d,
        bg2 = 0xff3c3836,
        
        -- ========================================
        -- OPTIONAL: Widget Colors
        -- ========================================
        -- Remove or comment out any widget colors you don't want to customize
        -- Widgets will fall back to standard colors if not defined
        
        -- CPU Widget
        cpu_widget_bg = 0x00000000,      -- Background (transparent)
        cpu_widget_text = 0xff2d2d2d,    -- Text color
        cpu_widget_graph = 0xffd65d0e,   -- Graph color
        
        -- WiFi Widget
        wifi_widget_bg = 0x00000000,         -- Background (transparent)
        wifi_widget_text = 0xff2d2d2d,       -- General text color
        wifi_widget_icon = 0xff1a1a1a,       -- Icon color
        wifi_widget_upload = 0xff2d2d2d,     -- Upload text color
        wifi_widget_download = 0xff2d2d2d,   -- Download text color
        
        -- Battery Widget
        battery_widget_bg = 0x20ffffff,      -- Background (subtle white)
        battery_widget_text = 0xff2d2d2d,    -- Text color
        battery_widget_icon = 0xff1a1a1a,    -- Icon color
        
        -- Volume Widget
        volume_widget_bg = 0x20ffffff,       -- Background (subtle white)
        volume_widget_text = 0xff2d2d2d,     -- Text color
        volume_widget_icon = 0xff1a1a1a,     -- Icon color
        
        -- ========================================
        -- OPTIONAL: Space Colors
        -- ========================================
        -- Remove or comment out any space colors you don't want to customize
        
        -- Basic Spaces
        space_bg = 0x00000000,           -- Space background
        space_text = 0xffd5c4a1,         -- Space text color
        space_icon = 0xffd5c4a1,         -- Space icon color
        
        -- Active Spaces
        space_active_bg = 0x00000000,        -- Active space background
        space_active_text = 0xffd65d0e,      -- Active space text
        space_active_icon = 0xffd65d0e,      -- Active space icon
        
        -- Space Brackets
        space_bracket_bg = 0x00000000,       -- Bracket background
        space_bracket_border = 0x00000000,   -- Bracket border
        
        -- ========================================
        -- OPTIONAL: App Icon Colors (for full themes)
        -- ========================================
        -- Remove or comment out if using minimal_spaces = true
        
        app_icon_bg = 0x00000000,            -- App icon background
        app_icon_text = 0xffd5c4a1,          -- App icon text
        app_icon_active_bg = 0x00000000,     -- Active app icon background
        app_icon_active_text = 0xffd65d0e,   -- Active app icon text
        
        -- ========================================
        -- OPTIONAL: Front App Colors
        -- ========================================
        
        front_app_bg = 0x00000000,           -- Front app background
        front_app_text = 0xffd5c4a1,         -- Front app text
        
        -- ========================================
        -- OPTIONAL: Menu Colors
        -- ========================================
        
        menu_bg = 0x00000000,                -- Menu background
        menu_text = 0xffd5c4a1,              -- Menu text
        menu_active_bg = 0x00000000,         -- Active menu background
        menu_active_text = 0xffd65d0e,       -- Active menu text
        
        -- ========================================
        -- OPTIONAL: Toggle Colors
        -- ========================================
        
        toggle_bg = 0x00000000,              -- Toggle background
        toggle_text = 0xffd5c4a1,            -- Toggle text
        toggle_active_bg = 0x00000000,       -- Active toggle background
        toggle_active_text = 0xffd65d0e,     -- Active toggle text
    },
    
    -- ========================================
    -- REQUIRED: Bar Configuration
    -- ========================================
    bar_config = {
        height = 30,
        corner_radius = 20,
        y_offset = 2,
    },
}
```

### Step 3: Done!

The theme will automatically be detected and added to the theme list. No need to manually register it!

## Theme Types

### Minimal Themes (`minimal_spaces = true`)
- Show only space icons (no app icons)
- Clean, minimal appearance
- Examples: Nord, Waves

### Full Themes (`minimal_spaces = false`)
- Show space numbers with app icons
- Include toggle functionality
- Examples: Nord Full, Dark, Light

## Widget Customization

Themes can include custom colors for every widget and UI element. If not specified, widgets will fall back to standard colors.

### Available Widget Colors

- **CPU Widget**: `cpu_widget_bg`, `cpu_widget_text`, `cpu_widget_graph`
- **WiFi Widget**: `wifi_widget_bg`, `wifi_widget_text`, `wifi_widget_icon`, `wifi_widget_upload`, `wifi_widget_download`
- **Battery Widget**: `battery_widget_bg`, `battery_widget_text`, `battery_widget_icon`
- **Volume Widget**: `volume_widget_bg`, `volume_widget_text`, `volume_widget_icon`

### Space Colors

- **Basic Spaces**: `space_bg`, `space_text`, `space_icon`
- **Active Spaces**: `space_active_bg`, `space_active_text`, `space_active_icon`
- **Space Brackets**: `space_bracket_bg`, `space_bracket_border`

## Color Format

The theme system supports **two color formats** for maximum flexibility:

### **Option 1: Standard Hex Colors (Recommended)**
Use familiar `#RRGGBB` format that works with colorizers:

```lua
-- Basic colors
color("#2E3440")           -- Standard hex color (fully opaque)
color("#2E3440", 200)      -- With custom alpha (0-255)
transparent("#2E3440", 90) -- With percentage transparency (0-100)

-- Examples
color("#000000")           -- Black
color("#ffffff")           -- White
transparent("#ffffff", 0)  -- Transparent
transparent("#ffffff", 50) -- 50% transparent white
```

### **Option 2: Traditional 0x Format**
Use the original `0xAARRGGBB` format:

```lua
0xff000000  -- Black (fully opaque)
0xffffffff  -- White (fully opaque)
0x00000000  -- Transparent
0x20ffffff  -- Semi-transparent white
```

### **Why Use Standard Hex?**
- **Colorizers work** - Vim/VS Code will show actual colors
- **Easier to read** - `#2E3440` vs `0xfa2e3440`
- **Familiar format** - Standard web/design color format
- **Better transparency control** - Use percentages (0-100) instead of hex values

## Troubleshooting

### Themes Not Loading
- Ensure the `themes/` directory exists in your SketchyBar config
- Check that theme files have the `.lua` extension
- Verify theme files return a valid table with required properties

### Widgets Not Updating
- Make sure widgets subscribe to the `theme_changed` event
- Restart SketchyBar after making changes: `brew services restart sketchybar`

### Font Issues
- Install required fonts (SF Pro, JetBrains Mono)
- Check font paths in `settings.lua`

## Directory Structure

```
~/.config/sketchybar/
├── themes/
│   ├── sample.lua          # Template file with all variables
│   ├── nord.lua            # Nord minimal theme
│   ├── nord_full.lua       # Nord full theme
│   ├── dark.lua            # Dark theme
│   ├── light.lua           # Light theme
│   ├── dracula.lua         # Dracula theme
│   ├── tokyo_night.lua     # Tokyo Night theme
│   └── waves.lua           # Waves theme
├── items/                  # Widget and item definitions
├── helpers/                # Helper scripts and event providers
├── themes.lua              # Theme manager
├── colors.lua              # Color system
├── bar.lua                 # Bar configuration
├── init.lua                # Initialization
└── sketchybarrc           # Main configuration file
```

## Contributing

1. Fork the repository
2. Create a new theme file in the `themes/` directory
3. Test your theme thoroughly
4. Submit a pull request

## License

This project is licensed under the same license as SketchyBar (GPL-3.0).

## Acknowledgments

- [@FelixKratz](https://github.com/FelixKratz) for creating SketchyBar and SbarLua
- The SketchyBar community for inspiration and support 
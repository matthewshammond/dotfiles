# 🚀 Dotfiles

> A powerful, automated macOS setup and configuration system

![macOS](https://img.shields.io/badge/macOS-Sequoia-black?style=flat&logo=apple)
![Shell](https://img.shields.io/badge/Shell-zsh-blue?style=flat&logo=gnu-bash)
![Package Manager](https://img.shields.io/badge/Package%20Manager-Homebrew-yellow?style=flat&logo=homebrew)
![Editor](https://img.shields.io/badge/Editor-Neovim-green?style=flat&logo=neovim)
![Terminal](https://img.shields.io/badge/Terminal-Ghostty-purple?style=flat&logo=terminal)

This repository contains my personal dotfiles and system configuration, designed to quickly set up a new macOS system with all my preferred tools, applications, and settings. It features a powerful installation script that handles everything from installing software to configuring system preferences.

## ✨ Features

- 🔄 **One-Command Setup**: Fully automated installation process
- 🎨 **Custom UI/UX**: Carefully crafted system preferences and UI settings
- 🛠️ **Development Tools**: Comprehensive development environment setup
- 🔒 **Security Focus**: Enhanced security configurations and tools
- 🖥️ **Modern Terminal**: Feature-rich shell configuration with Starship cross-shell prompt
- 📦 **Package Management**: Curated selection of CLI and GUI applications
- 🎯 **Productivity**: Optimized workflow with carefully selected tools
- 🔐 **GPG & SSH**: Secure configuration for development and communication
- 🍺 **Homebrew**: Extensive collection of formulae and casks
- 🐍 **Language Support**: Python, Ruby, Go, Rust, and Node.js environments

## 🚀 Quick Start

1. Clone this repository:

   ```bash
   git clone https://github.com/matthewshammond/dotfiles.git ~/.dotfiles
   ```

2. Run the installation script:

   ```bash
   cd ~/.dotfiles
   ./install.zsh
   ```

> **Note**: The installation process is interactive and will prompt you for:
>
> - Computer name
> - Which programming languages to install
> - Whether to include pentesting tools
> - Various other configuration options

## 🎯 What Gets Installed

### 🛠️ Development Tools

- Neovim (with LazyVim)
- Git + GitHub CLI
- Docker
- VSCode
- Language environments (Python, Ruby, Go, Rust)
- Development utilities (cmake, gcc, etc.)

### 📱 Applications

- 1Password
- Ghostty
- Firefox
- ChatGPT
- Raycast
- and many more...

### 🔒 Security Tools

- GPG Suite
- Little Snitch
- VPN clients
- Firewall configurations
- Optional: Pentesting toolkit

### 💻 System Configurations

- Custom UI/UX settings
- Enhanced privacy controls
- Optimized Finder preferences
- Improved security defaults
- Touch ID for sudo

## ⚙️ Customization

The installation process is interactive and allows you to choose:

- Which programming languages to install
- Whether to include pentesting tools
- System name and identity
- Various optional components

## 🎨 Theme & Appearance

- **Terminal**: Ghostty with PowerLevel10k prompt
- **Color Scheme**: Custom-crafted theme with dynamic switching via sketchybar
- **Font**: JetBrains Mono & Hack Nerd Font
- **Icons**: Custom system icons and symbols
- **Theme Switching**: Dynamic theme switching capabilities through sketchybar configuration

## ⚡ Performance Optimizations

- **Fast zsh Startup**: Optimized `.zshrc` with lazy loading using `zsh-defer`
- **Clean Loading**: No background processes or job completion messages
- **Progressive Enhancement**: Essential features load immediately, heavier plugins load after first prompt
- **Language Manager Optimization**: pyenv, rbenv, and goenv only initialize when used

### Theme Customization

This setup includes advanced theme switching capabilities through sketchybar. For detailed information about theme switching, customization options, and new features, please refer to the [sketchybar README](.config/sketchybar/README.md).

## 🔧 Components

- `.zshrc`: Shell configuration and aliases
- `.gitconfig`: Git preferences and aliases
- `.config/nvim`: Neovim configuration (LazyVim)
- `.p10k.zsh`: PowerLevel10k prompt configuration
- `.config/ghostty`: Ghostty terminal configuration
- `Brewfile`: Package declarations
- `scripts/`: Installation and setup scripts
- And much more...

## 📋 Post-Installation

After running the installation script, a few manual steps are required:

1. Sign in to your Apple ID
2. Configure application-specific settings
3. Set up security features (FileVault, Firewall)
4. Import GPG keys and configure SSH
5. Review the full checklist in the installation output

## 🤝 Contributing

Feel free to fork this repository and customize it for your needs. If you have suggestions or improvements, pull requests are welcome!

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Homebrew](https://brew.sh/) - The missing package manager for macOS
- [LazyVim](https://github.com/LazyVim/LazyVim) - Neovim configuration
- [PowerLevel10k](https://github.com/romkatv/powerlevel10k) - Cross-shell prompt
- [Ghostty](https://github.com/mitchellh/ghostty) - Modern terminal emulator
- And all the amazing open-source projects that make this possible!

---

<p align="center">Made by Matt Hammond</p>

# 🚀 Dotfiles

> A powerful, automated macOS setup and configuration system

![macOS](https://img.shields.io/badge/macOS-Sonoma-black?style=flat&logo=apple)
![Shell](https://img.shields.io/badge/Shell-zsh-blue?style=flat&logo=gnu-bash)
![Package Manager](https://img.shields.io/badge/Package%20Manager-Homebrew-yellow?style=flat&logo=homebrew)
![Editor](https://img.shields.io/badge/Editor-Neovim-green?style=flat&logo=neovim)
![Terminal](https://img.shields.io/badge/Terminal-iTerm2-purple?style=flat&logo=iterm2)

This repository contains my personal dotfiles and system configuration, designed to quickly set up a new macOS system with all my preferred tools, applications, and settings. It features a powerful installation script that handles everything from installing software to configuring system preferences.

## ✨ Features

- 🔄 **One-Command Setup**: Fully automated installation process
- 🎨 **Custom UI/UX**: Carefully crafted system preferences and UI settings
- 🛠️ **Development Tools**: Comprehensive development environment setup
- 🔒 **Security Focus**: Enhanced security configurations and tools
- 🖥️ **Modern Terminal**: Feature-rich shell configuration with Powerlevel10k
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
   ./install.sh "$HOME"
   ```

3. Follow the interactive prompts to customize your installation.

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
- iTerm2
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

- **Terminal**: iTerm2 with Powerlevel10k
- **Color Scheme**: Custom-crafted theme
- **Font**: JetBrains Mono & Hack Nerd Font
- **Icons**: Custom system icons and symbols

## 🔧 Components

- `.zshrc`: Shell configuration and aliases
- `.gitconfig`: Git preferences and aliases
- `.config/nvim`: Neovim configuration (LazyVim)
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
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Zsh theme
- And all the amazing open-source projects that make this possible!

---

<p align="center">Made by Matt Hammond</p>

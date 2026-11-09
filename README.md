# 🚀 Dotfiles

> A powerful, automated macOS setup and configuration system

![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-black?style=flat&logo=apple)
![Shell](https://img.shields.io/badge/Shell-zsh-blue?style=flat&logo=gnu-bash)
![Package Manager](https://img.shields.io/badge/Package%20Manager-Homebrew-yellow?style=flat&logo=homebrew)
![Editor](https://img.shields.io/badge/Editor-Neovim-green?style=flat&logo=neovim)
![Terminal](https://img.shields.io/badge/Terminal-Rex-purple?style=flat&logo=terminal)

My personal dotfiles and macOS setup. One script takes a freshly installed Mac to my
complete setup: apps, shell, window management, themes and system preferences.

Anyone is welcome to use the public part. My own machines also pull a private
submodule (`private/`) with things like SSH, Git and GPG config.

## 🧭 Which setup do I need?

| Where | What to run |
| --- | --- |
| **My laptop / Mac mini** (full setup + private files + projects) | [New Mac setup](#-new-mac-setup-my-machines) |
| **Any other Mac / VM** (public dotfiles only) | [Public install](#-public-install-anyone) |
| **Remote server, Linux box, a friend's computer** (just Neovim) | [Neovim only](#-neovim-only) |

## 🔐 New Mac setup (my machines)

Start from a fresh macOS install. Nothing needs to be downloaded first.

**1. Install the Command Line Tools.** Open Terminal and run:

```sh
git --version
```

macOS offers to install the Command Line Tools. Click **Install** and wait for it to finish.

**2. Load my SSH key temporarily** (from 1Password on the iPhone):

1. iPhone → 1Password → SSH key → copy the **private key**.
2. Paste it into a note in the **On My iPhone** Notes account (it never syncs to iCloud).
   Select the whole key from `-----BEGIN` through `-----END…-----` and copy it.
   Universal Clipboard makes it available on the Mac.
3. On the Mac:

```sh
{ pbpaste; echo; } | ssh-add -t 3600 -    # loads the key into memory for 1 hour - never written to disk
pbcopy < /dev/null                        # clears the clipboard
```

`ssh-add` should print `Identity added: (stdin)`. The `echo` adds back the final line
break that gets lost when copying.

**3. Clone with the private submodule** (type `yes` to trust github.com):

```sh
git clone --recurse-submodules git@github.com:matthewshammond/dotfiles.git ~/.dotfiles
```

**4. Run the installer:**

```sh
cd ~/.dotfiles && ./install.zsh
```

It asks for the computer name, asks you to sign in to the App Store, then runs unattended.

**5. Afterwards:**

- 1Password → Settings → Developer → turn on **Use the SSH agent**. My `~/.ssh/config`
  uses 1Password's agent from now on.
- Remove the temporary key with `ssh-add -D`. It also expires on its own after an hour or a restart.
- Delete the note on the iPhone.
- Work through the to-do list the installer prints at the end.

## 🌍 Public install (anyone)

```sh
git clone https://github.com/matthewshammond/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./install.zsh
```

An `https` clone skips everything private automatically.

> **Note**: Read `install.zsh` and the `Brewfile` before running this on your own Mac. The installer
> changes a lot of system settings (Dock, Finder, hot corners, menu bar, computer name...).

## ✏️ Neovim only

For a remote server (Linux or macOS) or someone else's computer. This installs Neovim plus
what LazyVim needs, then pulls my Neovim config from this repo:

```sh
sudo -v
curl -fsSL "https://gist.githubusercontent.com/matthewshammond/7febd4e8e34ba08bd255a7fc60ea076c/raw" | bash
```

## ⚙️ What the installer does

In order:

1. Checks for the Xcode Command Line Tools and Rosetta 2
2. **My machines only:** fetches `private/` and clones the
   repos listed in `private/repos.txt` into `~/projects`. This runs first because the
   temporary SSH key only lasts an hour.
3. Installs Homebrew, everything in the [`Brewfile`](Brewfile) (`brew bundle`), and a base Python
   with pyenv (projects use pyenv-virtualenv venvs; nothing is pip-installed globally)
4. Links the dotfiles into `~` with GNU Stow (public files, then `private/`). Existing files are moved to
   `~/.dotfiles-backup/` and never deleted.
5. Sets up the launchd jobs: a Pushover notification at each login (`reboot.zsh`) and CUPS job-history
   cleanup at boot (`cups.sh`)
6. Imports my GPG public key, installs zsh-defer, Neovim plugins, SbarLua and fonts
7. Configures Touch ID for sudo, turns off Siri and the Spotlight shortcut (Raycast takes Cmd+Space),
   and sets the macOS defaults (Dock, Finder, screenshots, hot corners...)
8. Offers to open the Raycast settings import

It's safe to re-run. It ends with a summary listing anything that failed (missing packages,
repos that didn't clone...), or the step where it stopped.

To only re-link dotfiles (no installs, no system changes), run `./install.zsh --link`.

## 🔁 Day-to-day

```sh
./install.zsh --link                      # re-link everything (no installs, no system changes)
brew bundle --file ~/.dotfiles/Brewfile   # install anything new added to the Brewfile
gpc                                       # show what changed in private
gpc "Add server to ssh config"            # commit + push private, then record it here
```

**How private files work:** `private/` is a submodule
([dotfiles-private](https://github.com/matthewshammond/dotfiles-private)). Stow links it into `~`
as a second package, so `~/.ssh/config` points straight at `private/.ssh/config`. Edit files where
they live (`~/.ssh/config`, `~/.gitconfig`...), then run `gpc "message"` to commit and push them.
Forgetting just leaves uncommitted changes in `private/`. Nothing gets out of sync.

**Adding software:** use Homebrew if it's there, then the Mac App Store (`mas` lines in the
Brewfile), and only download from the developer's website as a last resort (list below).

## 📥 Apps installed by hand

These aren't on Homebrew or the App Store:

- **Rex**: terminal (beta, moving to Homebrew after the beta)
- **IPMIView**: Supermicro server management
- **Parallels Toolbox**: comes with Parallels

## 📁 Layout

| Path | What it is |
| --- | --- |
| `install.zsh` | Main installer (`--link` to only re-link) |
| `Brewfile` | Every Homebrew formula, cask and App Store app |
| `scripts/brew.zsh` | Installs Homebrew, runs `brew bundle`, sets up language versions |
| `.zshrc`, `aliases.zsh`, `.p10k.zsh` | Shell: zsh + Powerlevel10k, lazy-loaded plugins, aliases and functions |
| `.config/rex` | Rex terminal |
| `.config/ghostty` | Ghostty, kept as a quick drop-down terminal |
| `.config/nvim` | Neovim (LazyVim) |
| `.config/sketchybar` | Status bar and the theme switcher ([README](.config/sketchybar/README.md)) |
| `.config/yabai`, `.config/skhd` | Tiling window manager and hotkeys |
| `.config/karabiner` | Keyboard remapping |
| `.config/atuin` | Shell history sync |
| `.config/herdr` | herdr config (kept for reference; not installed) |
| `.claude` | Claude Code settings and status line |
| `private/` | Private submodule: SSH/Git/GPG config, Raycast export, `repos.txt` (my machines only) |

## 📋 Post-Installation

### 🖼️ Wallpaper setup for sketchybar themes

Sketchybar changes the wallpaper along with the theme, but macOS has to initialize its
wallpaper system first:

1. **System Settings → Wallpaper**
2. **Change the wallpaper to ANY image** (not the default macOS wallpaper)
3. **Make sure "Show on all Spaces" is enabled**

> **Note**: Simply enabling/disabling "Show on all Spaces" on the default wallpaper is not sufficient. You must actually change the wallpaper to a different image first.

### ⌨️ Permissions

yabai, skhd, sketchybar and Karabiner-Elements need Accessibility (and some need Screen
Recording) permissions. macOS prompts for them on first launch. Confirm that 8 Spaces exist.
yabai creates them once its scripting addition loads.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Homebrew](https://brew.sh/) - The missing package manager for macOS
- [LazyVim](https://github.com/LazyVim/LazyVim) - Neovim configuration
- [PowerLevel10k](https://github.com/romkatv/powerlevel10k) - zsh prompt
- [SketchyBar](https://github.com/FelixKratz/SketchyBar) and [yabai](https://github.com/asmvik/yabai)
- And all the amazing open-source projects that make this possible!

---

<p align="center">Made by Matt Hammond</p>

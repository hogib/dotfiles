# dotfiles

Personal configuration files for my Linux setup, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

Each top-level directory is a Stow package. Running `stow <package>` from the repo root symlinks the contents into `$HOME`.

```
dotfiles/
├── git/    # Git config
├── hypr/   # Hyprland window manager (hypridle)
├── kitty/  # Kitty terminal
├── niri/   # Niri Wayland compositor
├── nvim/   # Neovim editor
├── tmux/   # Tmux + TPM plugins
└── zsh/    # Zsh shell, oh-my-zsh, aliases & functions
```

## Contents

### Git (`git/`)
Global `.gitconfig`: rebase on pull, zdiff3 conflicts, histogram diffs, SSH for GitHub URLs.

### Hyprland (`hypr/`)
Hyprland window-manager config, currently containing an **hypridle** idle-management configuration.

### Kitty (`kitty/`)
Kitty terminal config and theme.

### Niri (`niri/`)
Full [Niri](https://github.com/YaLTeR/niri) Wayland compositor setup, using the [Noctalia](https://github.com/noctalia-dev/noctalia-shell) shell, split across several KDL files:

| File | Purpose |
|---|---|
| `config.kdl` | Main config entry point |
| `binds.kdl` | Keyboard / mouse bindings (Turkish Q layout) |
| `decorations.kdl` | Layout, focus ring, shadows & background effects |
| `env.kdl` | Environment variables |
| `inputs.kdl` | Keyboard, touchpad & mouse settings |
| `laptop.kdl` | Laptop-specific settings (lid switch) |
| `startup.kdl` | Autostart applications |
| `windowrules.kdl` | Per-application window rules |
| `workspaces.kdl` | Named workspaces |
| `monitors.kdl` | Machine-specific outputs (optional, not tracked) |

### Neovim (`nvim/`)
Lua-based Neovim config using [lazy.nvim](https://github.com/folke/lazy.nvim) as plugin manager. Entry point: `init.lua` → `Config/`.

### Tmux (`tmux/`)
`C-a` prefix, vim-style pane navigation, status bar on top via [tmux-powerkit](https://github.com/fabioluciano/tmux-powerkit). Plugins are managed by [TPM](https://github.com/tmux-plugins/tpm) and are not tracked.

### Zsh (`zsh/`)
Oh-My-Zsh setup with [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme and the following plugins:

`you-should-use` · `git` · `fzf-tab` · `archlinux` · `zsh-autosuggestions` · `extract` · `web-search` · `colored-man-pages` · `rust` · `rsync` · `cp` · `sudo` · `kitty` · `zsh-history-substring-search` · `zsh-vi-mode` · `fast-syntax-highlighting`

Key tools wired up in `.zshrc`:

| Tool | Role |
|---|---|
| [eza](https://github.com/eza-community/eza) | `ls` / `ll` / `tree` replacement |
| [bat](https://github.com/sharkdp/bat) | `cat` replacement |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` |
| [direnv](https://direnv.net/) | Per-directory env vars |

## Installation

> **Requires:** git, GNU Stow

```bash
# Clone
git clone https://github.com/hogib/dotfiles ~/dotfiles
cd ~/dotfiles

# Stow the packages you want
stow git hypr kitty niri nvim tmux zsh

# Install tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
# then inside tmux: prefix + I
```

## License

[MIT](LICENSE)

# dotfiles

Personal configuration files for my Linux setup, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

Each top-level directory is a Stow package. Running `stow <package>` from the repo root symlinks the contents into `$HOME`.

```
dotfiles/
├── fastfetch/     # Fastfetch system info display configs
├── fetch_configs/ # hyfetch / transfetch color configs
├── hypr/          # Hyprland window manager (hypridle)
├── niri/          # Niri Wayland compositor
├── nvim/          # Neovim editor
└── zsh/           # Zsh shell, oh-my-zsh, aliases & functions
```

## Contents

### Hyprland (`hypr/`)
Hyprland window-manager config, currently containing an **hypridle** idle-management configuration.

### Niri (`niri/`)
Full [Niri](https://github.com/YaLTeR/niri) Wayland compositor setup split across several KDL files:

| File | Purpose |
|---|---|
| `config.kdl` | Main config entry point |
| `binds.kdl` | Keyboard / mouse bindings |
| `decorations.kdl` | Window borders, shadows & blur |
| `env.kdl` | Environment variables |
| `inputs.kdl` | Keyboard, touchpad & mouse settings |
| `laptop.kdl` | Laptop-specific overrides |
| `noctalia.kdl` | Machine-specific overrides |
| `startup.kdl` | Autostart applications |
| `windowrules.kdl` | Per-application window rules |

### Neovim (`nvim/`)
Lua-based Neovim config using [lazy.nvim](https://github.com/folke/lazy.nvim) as plugin manager. Entry point: `init.lua` → `Config/`.

### Zsh (`zsh/`)
Oh-My-Zsh setup with [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme and the following plugins:

`git` · `fzf-tab` · `archlinux` · `zsh-autosuggestions` · `extract` · `rust` · `sudo` · `you-should-use` · `zsh-shift-select` · `kitty` · `zsh-history-substring-search` · `zsh-vi-mode` · `zsh-syntax-highlighting` · `poetry`

Key tools wired up in `.zshrc`:

| Tool | Role |
|---|---|
| [eza](https://github.com/eza-community/eza) | `ls` / `ll` / `tree` replacement |
| [bat](https://github.com/sharkdp/bat) | `cat` replacement |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` |
| [thefuck](https://github.com/nvbn/thefuck) | Command correction |
| [direnv](https://direnv.net/) | Per-directory env vars |

### Fastfetch (`fastfetch/`)
Multiple [Fastfetch](https://github.com/fastfetch-cli/fastfetch) config presets:

| Preset | Alias |
|---|---|
| `config.jsonc` | `fastfetch` / `neofetch` |
| `config-archbtw.jsonc` | `archfetch` |
| `config-ytu-transparent.jsonc` | `ytufetch` |
| `config-compact.jsonc` | – |
| `config-pokemon.jsonc` | – |
| `config-v2.jsonc` | – |

### Fetch configs (`fetch_configs/`)
[hyfetch](https://github.com/hykilpikonna/hyfetch) presets for pride-flag-coloured Neofetch output:

- `hyfetchbi.json` — bi flag (`bifetch`)
- `transfetch.json` — trans flag (`transfetch`)

## Installation

> **Requires:** git, GNU Stow

```bash
# Clone
git clone https://github.com/hogib/dotfiles ~/dotfiles
cd ~/dotfiles

# Stow the packages you want
stow zsh
stow nvim
stow niri
stow hypr
stow fastfetch
stow fetch_configs
```

## License

[MIT](LICENSE)

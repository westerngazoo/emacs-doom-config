# emacs-doom-config

Personal Doom Emacs configuration plus terminal dotfiles (Ghostty, starship, zsh).
The repo is cloned directly to `~/.config/doom` — Doom reads `config.el`, `init.el`,
and `packages.el` from there; everything else (`dotfiles/`, `install.sh`, this file)
is ignored by Doom.

## Layout

```
~/.config/doom/            <- this repo
  config.el                Doom user config (theme, keybinds, LSP, etc.)
  init.el                  enabled Doom modules
  packages.el              extra packages
  dotfiles/
    ghostty-config         -> symlinked to ~/.config/ghostty/config
    starship.toml          -> symlinked to ~/.config/starship.toml
    zshrc                  -> symlinked to ~/.zshrc
  install.sh               creates the symlinks above, clones shader pack
```

`install.sh` is safe to re-run — existing non-symlink files are backed up with a
timestamp before being replaced.

---

## Update an already-configured machine

```sh
cd ~/.config/doom && git pull && ./install.sh && ~/.config/emacs/bin/doom sync
```

Then restart Emacs and open a new shell.

---

## Quick-start — Windows (WSL, already configured)

If WSL is already set up and you just need to pull the latest config:

```sh
cd ~/.config/doom && git pull && ./install.sh && ~/.config/emacs/bin/doom sync
```

If grip-mode is new (markdown preview), also run:

```sh
sudo apt install pipx -y && pipx install grip
```

Then restart Emacs. Aerospace is macOS-only and is skipped automatically by `install.sh`.

---

## Fresh setup — macOS

```sh
# 1. Emacs + toolchain (Homebrew)
brew install emacs-mac --cask    # or: brew install emacs-mac@29
brew install --cask font-jetbrains-mono-nerd-font
brew install pandoc cmake libtool          # markdown preview + vterm build deps

# 2. CLI tools used by the prompt and aliases
brew install starship eza bat zoxide fzf fd ripgrep \
             lazygit glow btop fastfetch tldr

# 3. Rust toolchain (for the wari project / rustic)
brew install rustup-init && rustup-init -y
source ~/.cargo/env
rustup component add rust-analyzer rustfmt clippy

# 4. Embedded toolchains (ARM + RISC-V, J-Link EDU)
brew install --cask segger-jlink          # JLinkGDBServer
brew install arm-none-eabi-gdb            # ARM GDB
brew install riscv64-elf-gdb              # RISC-V GDB
cargo install probe-rs-tools              # Rust-native alternative flasher

# 4. Doom Emacs
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs

# 5. This config
git clone https://github.com/westerngazoo/emacs-doom-config ~/.config/doom

# 6. Symlink the terminal dotfiles + clone Ghostty shaders
cd ~/.config/doom && ./install.sh

# 7. Build
~/.config/emacs/bin/doom sync
```

Restart the shell, then run `emacs`.

---

## Fresh setup — Windows / WSL

> Everything runs inside WSL (Ubuntu 22.04+ recommended). Open PowerShell as
> Administrator and run `wsl --install` if you haven't set it up yet, then
> reboot and launch Ubuntu from the Start menu.

### Step 1 — Enable zsh

```sh
sudo apt update && sudo apt install -y zsh git
chsh -s $(which zsh)   # log out and back in for this to take effect
```

### Step 2 — Emacs + build tools

Emacs needs `cmake` and `libtool-bin` to compile the vterm native module (the
terminal inside Emacs). `pandoc` powers the markdown split-preview.

```sh
sudo apt install -y emacs build-essential cmake libtool-bin pandoc \
                    fd-find ripgrep zoxide bat pipx tmux

# Debian/Ubuntu ships bat as `batcat` and fd as `fdfind` — alias them:
mkdir -p ~/.local/bin
ln -sf "$(which batcat)" ~/.local/bin/bat
ln -sf "$(which fdfind)" ~/.local/bin/fd
```

### Step 3 — Rust toolchain

Needed for the Rust LSP (rust-analyzer) and for building `eza` (better `ls`).

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
rustup component add rust-analyzer rustfmt clippy
cargo install eza
```

### Step 4 — CLI tools (prompt, fuzzy find, markdown reader, etc.)

```sh
# starship — the prompt
curl -sS https://starship.rs/install.sh | sh

# grip — markdown live-preview inside Emacs
pipx install grip
pipx ensurepath   # adds ~/.local/bin to PATH

# Embedded toolchains (ARM + RISC-V, J-Link EDU)
sudo apt install -y gcc-arm-none-eabi gdb-multiarch
cargo install probe-rs-tools
# Download J-Link Linux installer from https://www.segger.com/downloads/jlink/
# and run: sudo dpkg -i JLink_Linux_*.deb

# lazygit, glow, btop, fastfetch — grab latest binaries from GitHub releases:
#   https://github.com/jesseduffield/lazygit/releases
#   https://github.com/charmbracelet/glow/releases
#   https://github.com/aristocratos/btop/releases
#   https://github.com/fastfetch-cli/fastfetch/releases
# Extract each binary to ~/.local/bin/
```

### Step 5 — JetBrains Mono Nerd Font

Download `JetBrainsMono.zip` from https://github.com/ryanoasis/nerd-fonts/releases,
unzip into `~/.local/share/fonts/`, then run:

```sh
fc-cache -f
```

Set your terminal (Windows Terminal or Ghostty) to use **JetBrainsMono Nerd Font**.

### Step 6 — Doom Emacs + this config

```sh
# Doom itself
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs

# This config
git clone https://github.com/westerngazoo/emacs-doom-config ~/.config/doom

# Symlink dotfiles and create org/roam directory
cd ~/.config/doom && ./install.sh

# Install all packages
~/.config/emacs/bin/doom sync
```

Restart the shell, then run `emacs`.

### WSL notes

- `zshrc` guards macOS-only bits (`pmset`, `open -a`) with an `$OSTYPE` check —
  the shared file works as-is on WSL.
- Ghostty has a Linux build; the `macos-option-as-alt` line in `ghostty-config`
  is silently ignored on Linux.
- `~/.local/bin` must be on `PATH` — `pipx ensurepath` handles this.
- **Aerospace** is macOS-only — `install.sh` skips it on Linux automatically.

---

## What's configured

- **Theme** — warm-paper light (`#faf9f5` background) with blue-forward syntax
- **Font** — JetBrains Mono Nerd Font
- **Languages** — Rust (`+lsp +tree-sitter`), Emacs Lisp, sh, markdown, org
- **Projects** — projectile auto-discovers anything under `~/projects/`
- **Terminal** — Ghostty themed to match, starship prompt, eza/bat/zoxide aliases

See `dotfiles/` for the terminal configs and `config.el` for the Emacs setup.

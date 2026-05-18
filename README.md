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

Run everything inside the WSL distro (Ubuntu/Debian assumed).

```sh
# 1. Emacs 29+ and build deps
sudo apt update
sudo apt install -y emacs git build-essential cmake libtool-bin \
                    pandoc fd-find ripgrep zoxide bat
# Note: on Debian/Ubuntu, bat is installed as `batcat` and fd as `fdfind`.
# The zshrc aliases assume `bat`/`fd` — symlink them:
mkdir -p ~/.local/bin
ln -sf "$(which batcat)" ~/.local/bin/bat
ln -sf "$(which fdfind)" ~/.local/bin/fd

# 2. CLI tools not reliably in apt — install via their own methods
curl -sS https://starship.rs/install.sh | sh                 # starship
cargo install eza                                            # eza (needs Rust, see step 4)
# lazygit, glow, btop, fastfetch: grab latest release binary from their
# GitHub releases pages, or use your distro's backports.

# 3. JetBrains Mono Nerd Font
#    Download from https://github.com/ryanoasis/nerd-fonts/releases
#    (JetBrainsMono.zip), unzip into ~/.local/share/fonts, then: fc-cache -f

# 4. Rust toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
rustup component add rust-analyzer rustfmt clippy

# 5. Doom Emacs
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs

# 6. This config
git clone https://github.com/westerngazoo/emacs-doom-config ~/.config/doom

# 7. Symlink dotfiles + clone Ghostty shaders
cd ~/.config/doom && ./install.sh

# 8. Build
~/.config/emacs/bin/doom sync
```

Restart the shell, then run `emacs`.

### WSL notes

- The `zshrc` guards macOS-only bits (`pmset`, `open -a`) behind an `$OSTYPE`
  check, so the shared file works as-is on WSL.
- Ghostty has a Linux build; the `macos-option-as-alt` line in `ghostty-config`
  is simply ignored on Linux.
- If `zsh` is not your shell yet: `sudo apt install zsh && chsh -s $(which zsh)`.
- `~/.local/bin` must be on `PATH` for the `bat`/`fd` symlinks to resolve.
- **Aerospace** is macOS-only — `install.sh` skips it on Linux automatically.
- **grip** (markdown preview): install with `pipx install grip` after adding pipx
  (`sudo apt install pipx` or `pip install --user pipx`). Then run `doom sync` once
  to install the `grip-mode` Emacs package.

---

## What's configured

- **Theme** — warm-paper light (`#faf9f5` background) with blue-forward syntax
- **Font** — JetBrains Mono Nerd Font
- **Languages** — Rust (`+lsp +tree-sitter`), Emacs Lisp, sh, markdown, org
- **Projects** — projectile auto-discovers anything under `~/projects/`
- **Terminal** — Ghostty themed to match, starship prompt, eza/bat/zoxide aliases

See `dotfiles/` for the terminal configs and `config.el` for the Emacs setup.

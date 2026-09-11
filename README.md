# Omarchy Cursor 🖱️

A modern, native cursor theme manager and shell plugin for [Omarchy Linux](https://omarchy.org/).

Browse, discover, download, and switch cursor themes seamlessly across **Hyprland**, **GTK 3/4**, and **XWayland** with instant live switching and persistence.

---

## Features

- **Omarchy Top Bar Widget:** Quick-glance icon displaying your active cursor theme and size.
- **Interactive Popup Panel:**
  - View installed cursor themes and click any to switch live.
  - Quick cursor size switching (`24px`, `28px`, `32px`, `48px`).
  - Curated discovery catalog of top community cursor themes with 1-click installation.
- **Unified 4-Point System Synchronization:**
  - **Hyprland Compositor:** Live reload via `hyprctl setcursor`.
  - **Hyprland Config:** Automatically manages environment variables in `~/.config/hypr/hyprland.lua` and startup in `autostart.lua`.
  - **GTK Applications:** Updates `gsettings` and GTK 3 / GTK 4 `settings.ini`.
  - **XWayland Fallback:** Updates `~/.icons/default/index.theme`.
- **Full-Featured CLI (`omarchy-cursor`):**
  - Run in scripts, keybindings, or directly in your terminal.
  - Interactive TUI switcher using `gum` or `fzf`.
  - Built-in search across official Arch and AUR repositories.

---

## Installation

### As an Omarchy Shell Plugin

You can install and enable this plugin directly using the Omarchy CLI:

```bash
omarchy plugin add https://github.com/muhamm-ad-ahmad/omarchy-cursor.git --enable
```

To enable or move it to a specific section on the bar:

```bash
omarchy bar move io.github.muhamm-ad-ahmad.omarchy-cursor --section right
```

---

## Standalone CLI Usage

The bundled CLI tool `bin/omarchy-cursor` can also be symlinked or placed in `~/.local/bin/`:

```bash
ln -sf ~/.config/omarchy/plugins/io.github.muhamm-ad-ahmad.omarchy-cursor/bin/omarchy-cursor ~/.local/bin/omarchy-cursor
```

### CLI Commands

```bash
# Show current active theme and size
omarchy-cursor current

# List all locally installed cursor themes
omarchy-cursor list

# Apply a theme and size across Hyprland, GTK, and XWayland
omarchy-cursor set breeze_cursors 24

# Open interactive TUI theme switcher
omarchy-cursor switch

# Browse curated online themes and install from AUR
omarchy-cursor browse

# Search Arch and AUR repositories for cursor packages
omarchy-cursor search "catppuccin"

# Install a specific cursor package
omarchy-cursor install bibata-cursor-theme
```

---

## Curated Cursor Themes Catalog

The plugin includes quick-install support for popular themes:
- **Bibata Modern** (`bibata-cursor-theme`)
- **Catppuccin** (`catppuccin-cursors`)
- **Breeze & BreezeX** (`breeze-cursors`, `breezex-cursor-theme`)
- **Capitaine** (`capitaine-cursors`)
- **Nordzy** (`nordzy-cursors`)
- **Posy's Cursors** (`posy-cursor-tweaks`)
- **Volantes** (`volantes-cursors`)
- **Apple Cursor** (`apple-cursor`)
- **Oreo Cursors** (`oreo-cursors-git`)
- **Material Cursors** (`material-cursors`)
- **Phinger Cursors** (`phinger-cursors`)

---

## License

[MIT](LICENSE) © Muhammad Ahmad

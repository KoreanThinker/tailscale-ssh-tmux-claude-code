# Step 3: Install & Configure tmux

> **Goal:** Install tmux and configure it for a productive remote development workflow. With tmux, your terminal sessions persist even when you disconnect — reconnect and pick up exactly where you left off.

**Prerequisites:** [Step 2: Configure Tailscale SSH](./02-ssh-configuration.md) completed.

---

## What is tmux?

tmux (terminal multiplexer) lets you run multiple terminal sessions inside a single window and, most importantly, **detach** from them. When you close your SSH connection — whether intentionally or because your WiFi dropped — tmux keeps everything running on the server. When you reconnect, you reattach and find every process, every cursor position, every piece of output exactly as you left it.

This is the single most important tool for remote development. Without tmux, a dropped SSH connection means:

- Lost terminal history
- Killed running processes (compilers, dev servers, tests)
- Lost context (which directory, which files were open)

With tmux, a dropped connection means... nothing. You reconnect and continue.

---

## Core Concepts

tmux organizes your terminal into three levels:

```
┌─────────────────────────────────────────────────────────────────────┐
│ Session: "dev"                                                      │
│                                                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                │
│  │ Window 1:   │  │ Window 2:   │  │ Window 3:   │                │
│  │ "claude"    │  │ "code"      │  │ "server"    │  ...           │
│  │             │  │             │  │             │                │
│  │ ┌─────────┐ │  │ ┌────┬────┐ │  │ ┌────┬────┐ │                │
│  │ │         │ │  │ │    │    │ │  │ │    │    │ │                │
│  │ │  Pane 1 │ │  │ │ P1 │ P2 │ │  │ │ P1 │ P2 │ │                │
│  │ │         │ │  │ │    │    │ │  │ │    │    │ │                │
│  │ │         │ │  │ ├────┴────┤ │  │ └────┴────┘ │                │
│  │ │         │ │  │ │  Pane 3 │ │  │             │                │
│  │ └─────────┘ │  │ └─────────┘ │  │             │                │
│  └─────────────┘  └─────────────┘  └─────────────┘                │
│                                                                     │
│  Status bar: [dev] 1:claude* 2:code 3:server          host  14:30  │
└─────────────────────────────────────────────────────────────────────┘
```

- **Session** — a collection of windows. You can have multiple sessions (e.g., one per project). Sessions persist independently.
- **Window** — like a tab in a browser. Each window fills the entire terminal. Switch between them with `prefix + number`.
- **Pane** — a split within a window. Panes share the window space. Split vertically or horizontally.

### The prefix key

Almost all tmux commands start with a **prefix key** — a two-key chord that tells tmux "the next key is a tmux command, not terminal input." The default is `Ctrl+b`, but our configuration remaps it to `Ctrl+a` (easier to reach).

Throughout this guide, `prefix` means `Ctrl+a`.

---

## Installation

### macOS

```bash
brew install tmux
```

### Linux (Debian/Ubuntu)

```bash
sudo apt update && sudo apt install -y tmux
```

### Linux (Fedora/RHEL)

```bash
sudo dnf install -y tmux
```

### Linux (Arch)

```bash
sudo pacman -S tmux
```

### From source (latest version)

If your package manager has an old version:

```bash
# Install dependencies
sudo apt install -y build-essential libevent-dev ncurses-dev bison

# Download and compile
VERSION=3.5a
curl -LO "https://github.com/tmux/tmux/releases/download/${VERSION}/tmux-${VERSION}.tar.gz"
tar xzf "tmux-${VERSION}.tar.gz"
cd "tmux-${VERSION}"
./configure && make
sudo make install
```

### Verify installation

```bash
tmux -V
```

```
tmux 3.5a
```

---

## Configuration

Our project includes a ready-to-use configuration file at [`configs/.tmux.conf`](../../configs/.tmux.conf). This section explains what each part does so you can customize it.

### Install the configuration

```bash
# Copy the config to your home directory
cp configs/.tmux.conf ~/.tmux.conf

# If tmux is already running, reload it
tmux source-file ~/.tmux.conf
```

### Configuration walkthrough

#### Prefix key

```bash
unbind C-b
set -g prefix C-a
bind C-a send-prefix
```

Remaps the prefix from `Ctrl+b` to `Ctrl+a`. The `a` key is on the home row, making the prefix much more comfortable to type hundreds of times per day. If you need to send a literal `Ctrl+a` to a program inside tmux, press `Ctrl+a` twice.

#### General settings

```bash
set -sg escape-time 0           # No delay after pressing Escape
set -g history-limit 50000      # 50k lines of scrollback (default: 2000)
set -g focus-events on          # Vim/Neovim auto-reload on focus
set -g display-time 3000        # Status messages visible for 3 seconds
set -g status-keys vi           # Vi bindings in tmux command prompt
```

The `escape-time 0` is critical if you use Vim or Neovim — without it, pressing `Escape` has a noticeable delay.

#### Colors and terminal

```bash
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"
```

Enables 256-color and true color (24-bit) support. Essential for modern themes in Vim/Neovim, bat, delta, and other tools.

#### Numbering

```bash
set -g base-index 1             # Windows start at 1, not 0
setw -g pane-base-index 1       # Panes start at 1, not 0
set -g renumber-windows on      # Close window 2 → window 3 becomes 2
```

Starting at 1 is more ergonomic — the `1` key is right next to `prefix`, while `0` is far away.

#### Split bindings

```bash
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind \\ split-window -h -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"
```

- `prefix + |` — split left/right (vertical divider)
- `prefix + -` — split top/bottom (horizontal divider)
- `prefix + \` — same as `|` but without Shift

All new panes and windows inherit the current working directory.

#### Pane navigation

```bash
bind -n M-Left  select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up    select-pane -U
bind -n M-Down  select-pane -D
```

`Alt + Arrow` moves between panes **without pressing prefix first**. This is much faster when you are constantly switching between panes.

#### Mouse support

```bash
set -g mouse on
```

Enables clicking on panes to focus them, dragging pane borders to resize, and scrolling through output with the mouse wheel. Useful especially when accessing from a mobile terminal.

#### Copy mode (Vi-style)

```bash
setw -g mode-keys vi
bind v copy-mode
bind -T copy-mode-vi v   send-keys -X begin-selection
bind -T copy-mode-vi y   send-keys -X copy-selection-and-cancel
```

- `prefix + v` — enter copy mode (scroll through output)
- `v` — start selecting text (in copy mode)
- `y` — copy selected text (in copy mode)
- `Ctrl+v` — toggle rectangle selection

#### Status bar

The configuration includes a **Catppuccin Mocha**-inspired status bar with:

- Left: session name with blue accent
- Center: window list with green highlight on the active window
- Right: hostname and clock
- Pane borders: subtle gray, with blue for the active pane

---

## Installing TPM (Tmux Plugin Manager)

TPM manages tmux plugins automatically. Install it:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then, inside tmux, install the configured plugins:

```
prefix + I    (capital I, for Install)
```

This downloads and activates all plugins listed in the config. You should see a message like:

```
TMUX environment reloaded.
Done, press ESCAPE to continue.
```

### Plugin management commands

| Command | Action |
|---|---|
| `prefix + I` | Install new plugins |
| `prefix + U` | Update existing plugins |
| `prefix + Alt + u` | Remove plugins no longer in config |

---

## Essential Plugins

Our configuration includes four plugins:

### tmux-sensible

Sensible default settings that most users agree on. Handles edge cases in different terminal types and adds quality-of-life improvements.

### tmux-yank

Copies text from tmux to your system clipboard. Works on macOS, Linux (X11 and Wayland), and even over SSH (using OSC 52 escape sequences).

After copying text in copy mode (`y`), it is available in your system clipboard.

### tmux-resurrect

Saves and restores tmux sessions across system restarts. After a reboot, you can restore all your windows, panes, and their layout.

- **Save:** `prefix + Ctrl+s`
- **Restore:** `prefix + Ctrl+r`

Our config also enables pane content capture and Neovim session restoration:

```bash
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'
```

### tmux-continuum

Automatically saves your tmux environment every 15 minutes (configurable) and automatically restores the last saved session when tmux starts.

```bash
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'
```

With resurrect + continuum, your tmux environment is essentially persistent. Even after a machine reboot, starting tmux brings back your entire workspace.

---

## Your First tmux Session

### Start a new session

```bash
tmux new-session -s dev
```

This creates a session named "dev" and attaches to it. You should see the status bar appear at the bottom.

### Basic operations to try

```bash
# Split horizontally (top and bottom)
prefix + -

# Split vertically (left and right)
prefix + |

# Navigate between panes
Alt + Arrow keys

# Create a new window
prefix + c

# Switch to window 1
prefix + 1

# Detach from the session (it keeps running!)
prefix + d

# List running sessions
tmux ls

# Reattach to the session
tmux attach -t dev
```

### The magic moment

Here is the workflow that makes tmux indispensable for remote work:

1. SSH into your dev machine: `ssh user@dev-machine`
2. Start or reattach to tmux: `tmux attach -t dev || tmux new -s dev`
3. Work normally — run servers, edit code, compile things
4. Close your laptop lid. Walk away. Your WiFi drops. It does not matter.
5. Later, from any device: `ssh user@dev-machine`
6. Reattach: `tmux attach -t dev`
7. Everything is exactly as you left it. Processes running. Output preserved. Cursor in the same spot.

---

## Summary

At this point, you should have:

- [x] tmux installed
- [x] Configuration file in place (`~/.tmux.conf`)
- [x] TPM installed and plugins loaded
- [x] Created your first tmux session
- [x] Understood the detach/reattach workflow

**Next:** [Step 4: tmux Panes & Workflow Mastery](./04-tmux-workflow.md) — learn the key bindings, workflows, and layouts that make you productive in tmux.

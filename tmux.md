# 🪟 Tmux Cheatsheet

This cheatsheet reflects the custom configuration found in `config/tmux/tmux.conf`.

## 🎹 Key Bindings

**Prefix:** `Ctrl + Alt + Shift + Space` (Hyper/Space)

### 🚀 Essentials
| Key | Action |
|-----|--------|
| `Prefix` + `r` | Reload tmux configuration |
| `Prefix` + `t` | **Sesh** (Session Manager) - fuzzy find and connect to sessions |
| `Prefix` + `:` | Enter command mode |
| `Prefix` + `[` | Enter copy mode (vi-style) |

### 🪟 Window Management
| Key | Action |
|-----|--------|
| `Prefix` + `c` | Create new window |
| `Alt` + `1-9` | Switch to window 1-9 (No prefix needed) |
| `Prefix` + `Shift + Left` | Move current window left |
| `Prefix` + `Shift + Right` | Move current window right |
| `Prefix` + `&` | Kill current window |

### 📋 Pane Management
| Key | Action |
|-----|--------|
| `Prefix` + `\|` | Split pane horizontally (side-by-side) |
| `Prefix` + `-` | Split pane vertically (top-and-bottom) |
| `Alt` + `h/j/k/l` | Navigate panes (No prefix needed) |
| `Prefix` + `h/j/k/l` | Navigate panes |
| `Prefix` + `z` | Toggle zoom current pane |
| `Prefix` + `x` | Kill current pane |

### 📝 Copy Mode (vi-style)
| Key | Action |
|-----|--------|
| `v` | Begin selection |
| `C-v` | Rectangle toggle |
| `y` | Copy selection and cancel |
| `q` | Exit copy mode |

---

## ⚡ Sesh (Session Manager)
Triggered by `Prefix` + `t`. Use the following keys within the fuzzy finder:

| Key | Action |
|-----|--------|
| `Ctrl + a` | Show all sessions |
| `Ctrl + t` | Show tmux sessions |
| `Ctrl + g` | Show config directories |
| `Ctrl + x` | Show zoxide directories |
| `Ctrl + f` | Find files/directories |
| `Ctrl + d` | Kill selected tmux session |
| `Tab` | Move down |
| `Shift + Tab` | Move up |

---
*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*

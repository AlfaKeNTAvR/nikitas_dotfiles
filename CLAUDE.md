# nikitas_dotfiles

Modular bash dotfiles for quick setup on any Ubuntu machine. The core design
principle: **everything is reversible**. This repo is meant for guest machines —
make yourself comfortable, then run `dotfiles-nuke` and the machine is back to
its original state.

## The reversibility rule

Every change `install.sh` or a setup script makes to the host system MUST be
fully undone by `uninstall.sh` (and therefore `dotfiles-nuke`, which calls it).
When adding new functionality, always implement the undo path at the same time.

Checklist for any new feature that touches the host:

1. **Config files** — back up the original to `$XDG_DATA_HOME/nikitas_dotfiles/`
   before modifying. `uninstall.sh` restores from the backup. See
   `setup/terminator.sh` for the pattern.
2. **Packages** — install via `ensure_dep <pkg>` so they're tracked in
   `installed_deps`. On uninstall, check reverse dependencies with
   `apt-cache rdepends --installed` before removing — never remove a package
   that other installed software depends on. This prevents breaking GNOME,
   Ubuntu, or any other software already on the machine.
3. **Dotfiles (`.bashrc`, etc.)** — append with a marker; remove by grepping
   out the marker.
4. **Anything else** (systemd units, cron jobs, symlinks, etc.) — record what
   was added and write the removal logic in `uninstall.sh`.

If a change can't be cleanly reversed, don't make it automatically — document
it as a manual step instead.

## Architecture

- `install.sh` — adds source line to `~/.bashrc`, installs dependencies, runs setup scripts
- `uninstall.sh` — reverses everything install did (restores original configs from backups)
- `bash/init.sh` — sources all `*.sh` files from `bash/lib/`
- `bash/lib/*.sh` — individual feature modules (bookmarks, history, dotfiles commands, etc.)
- `setup/*.sh` — one-time configuration scripts (e.g., Terminator settings)

## Conventions

- **No `git -C`:** always use plain `git` commands.
- Shell code targets bash (not POSIX sh). Use `set -euo pipefail` in scripts.
- Backups live in `$XDG_DATA_HOME/nikitas_dotfiles/` (defaults to `~/.local/share/nikitas_dotfiles/`).

## Testing

```bash
bash tests/test_uninstall.sh
```

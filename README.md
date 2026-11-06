# System Configuration

Canonical source of truth for this NixOS configuration:

- repo path: `~/system-configuration`
- compatibility path: `/etc/nixos` -> symlink to this repo

## Daily workflow

1. Edit config in `~/system-configuration`.
2. Review changes with `git status` and `git diff`.
3. Apply locally with `./scripts/switch`.
4. Commit and push to GitHub.

Example:

```bash
git status
git diff
./scripts/switch
git add .
git commit -m "feat(nixos): describe change"
git push origin main
```

## Ticket worktrees

Use `ticket-worktree` to create isolated frontend/API worktrees for Jira tickets without copying repositories. See [Ticket worktrees](docs/ticket-worktrees.md) for branch conventions, explicit branch mappings, and cleanup.

## GitHub sync

GitHub stores the source repo only. A rebuild is still required on each machine.

On this machine:

```bash
git pull --rebase
./scripts/switch
```

On a new machine:

```bash
git clone <repo-url> ~/system-configuration
sudo ln -sfn ~/system-configuration /etc/nixos
sudo nixos-rebuild switch --flake path:~/system-configuration#<hostname>
```

## Laptop operations and recovery

For the `nixos` laptop's firewall boundary, Syncthing/Tailscale assumptions, memory-pressure policy, lock-before-suspend behavior, privileged groups, and rollback procedures, see [Laptop Operations Baseline](docs/laptop-operations.md).

Before a risky switch, record the current generation:

```bash
nixos-rebuild list-generations
```

If a switch is unsuccessful but the current session remains usable, roll back immediately:

```bash
sudo nixos-rebuild switch --rollback
```

Otherwise reboot and select a known-good NixOS generation in the systemd-boot menu. The host automatically removes generations older than 30 days, so do not run ad hoc garbage collection until you have confirmed the rollback window is sufficient.

## Host layout

- `hosts/common/`: shared NixOS modules and Home Manager wiring
- `hosts/<hostname>/`: per-machine system config and hardware config
- `home/yoran.nix`: shared user config
- `home/yoran/hosts/<hostname>.nix`: per-machine user overrides

## Adding a new machine

1. Copy `hosts/nixos/` to `hosts/<hostname>/`.
2. Replace `hardware-configuration.nix` with the new machine's generated file.
3. Add any user-only machine overrides in `home/yoran/hosts/<hostname>.nix`.
4. Rebuild with `sudo nixos-rebuild switch --flake path:~/system-configuration#<hostname>`.

`flake.nix` auto-discovers host directories under `hosts/`, so you do not need to edit it for another x86_64 host.

## Encrypted Wallpaper

The moving wallpapers are stored in the repo as encrypted files:

- encrypted assets: `assets/wallpapers/<name>.mp4.age`
- local runtime files: `~/.local/share/wallpapers/<name>.mp4`
- active wallpaper pointer: `~/.local/share/wallpapers/current.mp4`

Helper scripts:

```bash
./scripts/encrypt-wallpaper /path/to/video.mp4 2
./scripts/decrypt-wallpaper
./scripts/set-wallpaper 2
```

`./scripts/switch` will also decrypt all `assets/wallpapers/*.mp4.age` files automatically when your private key exists at `~/.ssh/id_ed25519_personal`.

# FireLauncher — Project Context for Claude

## Project Goal

Speed up Amazon Fire TV devices using ADB over Wi-Fi. No root. No warranty issues. Everything is reversible.

The origin of this project: Prime Video stopped opening on the owner's Fire TV due to RAM exhaustion from Amazon bloatware running in background. The goal is to fix that and make the experience usable again — and package that fix for others.

## Approach

1. **Diagnose** — connect via ADB, dump RAM usage, running processes, installed packages
2. **Debloat** — use `pm disable-user --user 0` (NOT `pm uninstall`) to disable safe Amazon background services
3. **Tune** — reduce system animation scales, clear caches
4. **Restore** — one-command rollback via `restore.sh` using a logged list of what was disabled

## Key Constraints

- **Never use `pm uninstall` on system packages** — only `pm disable-user`
- `pm disable-user` is reversible: package stays installed, just inactive for user 0
- Scripts must work on macOS, Linux, and ideally Windows (future)
- Target devices: Fire TV Stick (all generations), Stick 4K, Stick Lite, Fire TV Cube

## Project Structure

```
FireLauncher/
├── scripts/
│   ├── diagnose.sh     # Full diagnostic report → saves firetv_report_*.txt
│   ├── optimize.sh     # Interactive: debloat + animations + cache clear
│   └── restore.sh      # Re-enables all packages from firetv_disabled_*.txt
├── packages/
│   └── bloatware.txt   # Annotated package list with SAFE / CAUTION / KEEP levels
├── docs/               # (empty — future: per-model guides, launcher setup)
├── CLAUDE.md           # This file
└── README.md
```

## GitHub

- Repo: https://github.com/artifu/FireLauncher
- Intent: share publicly, mention on LinkedIn

## In-Progress / Next Steps

- [ ] Test `diagnose.sh` and `optimize.sh` against owner's actual device
- [ ] Identify owner's Fire TV model (Stick / Stick 4K / Lite / Cube) for model-specific tuning
- [ ] Add more safe-to-disable packages discovered during real testing
- [ ] `docs/` guide per Fire TV model
- [ ] Windows `.bat` / PowerShell equivalents
- [ ] Optional: lightweight launcher setup guide (FLauncher via sideload)

## ADB Quick Reference

```bash
# Install (macOS)
brew install android-platform-tools

# Enable on Fire TV: Settings > My Fire TV > Developer Options > ADB Debugging ON
# Find IP: Settings > My Fire TV > About > Network

adb connect <IP>:5555
adb devices

# Diagnose
./scripts/diagnose.sh

# Optimize (interactive)
./scripts/optimize.sh

# Restore everything
./scripts/restore.sh
```

## Safety Notes

| Action | Reversible? |
|--------|-------------|
| `pm disable-user` | Yes — `pm enable <pkg>` or `restore.sh` |
| Animation scale changes | Yes — `restore.sh` resets to 1.0 |
| `pm trim-caches` | Yes — cache rebuilds on next app launch |
| `pm clear <pkg>` | Mostly yes — clears cache + data; app stays installed |
| `pm uninstall` | **No — never used in this project** |

Emergency reset: hold Fire TV remote power button 20 seconds → force reboot. ADB still works after reboot.

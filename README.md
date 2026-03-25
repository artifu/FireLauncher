# FireLauncher 🔥

> Speed up your Fire TV with ADB — no root required.

FireLauncher is a set of shell scripts to diagnose, debloat, and optimize Amazon Fire TV devices via ADB over Wi-Fi. No root. No warranty voiding. Everything is reversible.

---

## Why?

Fire OS ships with a lot of Amazon services running in the background — ads, sync, voice listeners, shopping apps — most of which you never use. Over time (and especially on older devices), these eat RAM and slow down everything, sometimes to the point where core apps like **Prime Video itself won't even open**.

This project gives you a clean, safe workflow to:
- See exactly what's consuming your device's memory
- Disable bloatware without uninstalling anything
- Tune system animations
- Clear caches
- Restore everything with one command if needed

---

## Requirements

- Amazon Fire TV (any model — Stick, Stick 4K, Stick Lite, Cube)
- A computer with [Android Platform Tools](https://developer.android.com/tools/releases/platform-tools) installed
- Fire TV and computer on the **same Wi-Fi network**

---

## Setup

### 1. Enable ADB on your Fire TV

```
Settings → My Fire TV → Developer Options
  → ADB Debugging: ON
  → Apps from Unknown Sources: ON
```

### 2. Find your Fire TV's IP address

```
Settings → My Fire TV → About → Network
```

### 3. Install ADB on your computer

- **macOS:** `brew install android-platform-tools`
- **Linux:** `sudo apt install adb`
- **Windows:** Download [Platform Tools](https://developer.android.com/tools/releases/platform-tools) and add to PATH

### 4. Clone this repo

```bash
git clone https://github.com/YOUR_USERNAME/FireLauncher.git
cd FireLauncher
chmod +x scripts/*.sh
```

---

## Usage

### Diagnose — see what's running

```bash
./scripts/diagnose.sh
```

Generates a full report with:
- Device info and Fire OS version
- RAM usage breakdown
- Top processes by memory consumption
- Installed packages list
- Running services
- Disk usage

The report is saved as `firetv_report_YYYYMMDD_HHMMSS.txt` in the current directory.

---

### Optimize — speed things up

```bash
./scripts/optimize.sh
```

Interactive menu with four options:

| Option | What it does |
|--------|-------------|
| 1 | Full optimization: disable bloatware + reduce animations + clear cache |
| 2 | Only clear cache + fix Prime Video launch issues |
| 3 | Only reduce animations (instant speed boost) |
| 4 | Only disable bloatware |

Every disabled package is logged to `firetv_disabled_YYYYMMDD_HHMMSS.txt` so restore is always possible.

---

### Restore — undo everything

```bash
./scripts/restore.sh
# or pass a specific log file:
./scripts/restore.sh firetv_disabled_20240101_120000.txt
```

Re-enables all previously disabled packages and resets animations to defaults.

---

## What gets disabled

See [`packages/bloatware.txt`](packages/bloatware.txt) for the full annotated list with risk levels.

**Safe to disable (examples):**

| Package | App |
|---------|-----|
| `com.amazon.dee.app` | Alexa Hands-Free |
| `com.amazon.mp3` | Amazon Music |
| `com.amazon.photos` | Amazon Photos |
| `com.amazon.mShop.android.shopping` | Amazon Shopping |
| `com.amazon.cloud9` | Silk Browser |
| `com.amazon.imdb.tv.android.app` | IMDb TV / Freevee |
| `com.amazon.contentservice` | Ads & Sponsored Content |
| `com.amazon.advertising.identitymanagement` | Ad Identity Manager |

> **Note:** `pm disable-user` only disables the package for the current user. The app remains installed and can be re-enabled at any time. This is fundamentally different from `pm uninstall`.

---

## Safety

| Action | Reversible? |
|--------|-------------|
| `pm disable-user` | Yes — via `pm enable` or `restore.sh` |
| Reducing animations | Yes — via `restore.sh` |
| Clearing cache | Yes — cache rebuilds on next app launch |
| `pm uninstall` | **No** — this project never uses it |

**Never run `pm uninstall` on system packages.** If you brick your UI somehow, you can still connect via ADB and run `restore.sh` — or hold the remote power button for 20 seconds to force reboot.

---

## Project Structure

```
FireLauncher/
├── scripts/
│   ├── diagnose.sh   # Full diagnostic report
│   ├── optimize.sh   # Interactive optimizer
│   └── restore.sh    # Undo all changes
├── packages/
│   └── bloatware.txt # Annotated list of safe-to-disable packages
└── README.md
```

---

## Contributing

PRs welcome — especially for:
- Testing on specific Fire TV models (Cube, 4K Max, etc.)
- Adding more safe-to-disable packages
- Windows batch script equivalents (`.bat` / PowerShell)
- Alternative launcher setup guides

---

## Disclaimer

This project is provided as-is. Use at your own risk. All operations are designed to be reversible, but the author takes no responsibility for any issues with your device. Always keep a backup of your disabled packages log.

---

## License

MIT

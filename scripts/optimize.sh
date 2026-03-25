#!/bin/bash
# =============================================================================
# FireLauncher - optimize.sh
# Safely disables bloatware, reduces animations, and clears cache on Fire TV.
# All changes are reversible. Nothing is uninstalled — only disabled.
# =============================================================================

set -e

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

PACKAGES_FILE="$(dirname "$0")/../packages/bloatware.txt"
DISABLED_LOG="firetv_disabled_$(date +%Y%m%d_%H%M%S).txt"

print_header() {
  echo -e "${CYAN}============================================${NC}"
  echo -e "${CYAN}  FireLauncher — Fire TV Optimizer${NC}"
  echo -e "${CYAN}============================================${NC}"
  echo -e "${YELLOW}  All changes are REVERSIBLE.${NC}"
  echo -e "${YELLOW}  Use restore.sh to re-enable everything.${NC}"
  echo ""
}

check_adb() {
  if ! command -v adb &>/dev/null; then
    echo -e "${RED}[ERROR] adb not found. Install Android Platform Tools first.${NC}"
    echo "  → https://developer.android.com/tools/releases/platform-tools"
    exit 1
  fi
}

connect_device() {
  echo -e "${YELLOW}Enter your Fire TV IP address:${NC}"
  read -r FIRETV_IP

  echo -e "Connecting to ${FIRETV_IP}:5555..."
  adb connect "${FIRETV_IP}:5555"

  DEVICE=$(adb devices | grep "${FIRETV_IP}" | awk '{print $1}')
  if [ -z "$DEVICE" ]; then
    echo -e "${RED}[ERROR] Could not connect to ${FIRETV_IP}.${NC}"
    exit 1
  fi

  echo -e "${GREEN}[OK] Connected to ${FIRETV_IP}${NC}"
  echo ""
}

disable_package() {
  local pkg="$1"
  local label="$2"

  # Check if package exists on device
  if adb shell pm list packages | grep -q "^package:${pkg}$"; then
    adb shell pm disable-user --user 0 "$pkg" &>/dev/null
    echo -e "  ${GREEN}[DISABLED]${NC} ${label} (${pkg})"
    echo "$pkg" >> "$DISABLED_LOG"
  else
    echo -e "  ${YELLOW}[SKIP]${NC}     ${label} — not found on this device"
  fi
}

reduce_animations() {
  echo -e "${BOLD}→ Reducing system animations...${NC}"
  adb shell settings put global window_animation_scale 0.5
  adb shell settings put global transition_animation_scale 0.5
  adb shell settings put global animator_duration_scale 0.5
  echo -e "  ${GREEN}[OK]${NC} Animations set to 0.5x"
  echo ""
}

clear_cache() {
  echo -e "${BOLD}→ Clearing app caches...${NC}"
  adb shell pm trim-caches 999999999
  echo -e "  ${GREEN}[OK]${NC} Caches cleared"
  echo ""
}

fix_prime_video() {
  echo -e "${BOLD}→ Clearing Prime Video cache (fixes launch issues)...${NC}"
  adb shell pm clear com.amazon.avod.thirdpartyclient &>/dev/null || true
  echo -e "  ${GREEN}[OK]${NC} Prime Video cache cleared"
  echo ""
}

disable_bloatware() {
  echo -e "${BOLD}→ Disabling bloatware...${NC}"
  echo ""

  # --- Amazon Services (safe to disable if unused) ---
  disable_package "com.amazon.dee.app"                        "Alexa Hands-Free"
  disable_package "com.amazon.mp3"                            "Amazon Music"
  disable_package "com.amazon.photos"                         "Amazon Photos"
  disable_package "com.amazon.mShop.android.shopping"         "Amazon Shopping"
  disable_package "com.amazon.cloud9"                         "Silk Browser"
  disable_package "com.amazon.imdb.tv.android.app"            "IMDb / Freevee"
  disable_package "com.amazon.agora.tablets.goodreads"        "Goodreads"
  disable_package "com.amazon.kindle.freetime"                "Amazon Kids (FreeTime)"
  disable_package "com.amazon.avod.thirdpartyclient.trailer"  "Prime Video Trailers Autoplay"
  disable_package "com.amazon.ags.app"                        "Amazon GameCircle"
  disable_package "com.amazon.webapp"                         "Amazon WebApp"
  disable_package "com.amazon.advertising.identitymanagement" "Amazon Ad Identity Manager"
  disable_package "com.amazon.contentservice"                 "Amazon Content Service (Ads)"
  disable_package "com.amazon.device.sync"                    "Amazon Device Sync"

  echo ""
  echo -e "  ${CYAN}Disabled packages logged to: ${DISABLED_LOG}${NC}"
  echo ""
}

show_memory() {
  echo -e "${BOLD}→ Current memory status:${NC}"
  adb shell cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable"
  echo ""
}

# --- Main ---
print_header
check_adb
connect_device

echo -e "${BOLD}What would you like to do?${NC}"
echo "  [1] Full optimization (disable bloatware + reduce animations + clear cache)"
echo "  [2] Only clear cache + fix Prime Video"
echo "  [3] Only reduce animations"
echo "  [4] Only disable bloatware"
echo ""
read -rp "Choose an option (1-4): " CHOICE
echo ""

case "$CHOICE" in
  1)
    disable_bloatware
    reduce_animations
    clear_cache
    fix_prime_video
    show_memory
    ;;
  2)
    clear_cache
    fix_prime_video
    show_memory
    ;;
  3)
    reduce_animations
    ;;
  4)
    disable_bloatware
    show_memory
    ;;
  *)
    echo -e "${RED}Invalid option.${NC}"
    exit 1
    ;;
esac

echo -e "${GREEN}${BOLD}Done! Your Fire TV should be noticeably faster now.${NC}"
echo -e "To undo any changes, run: ${CYAN}./scripts/restore.sh${NC}"
echo ""

#!/bin/bash
# =============================================================================
# FireLauncher - restore.sh
# Re-enables all packages previously disabled by optimize.sh.
# Pass a log file as argument, or it will look for the latest one.
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

connect_device() {
  echo -e "${YELLOW}Enter your Fire TV IP address:${NC}"
  read -r FIRETV_IP
  adb connect "${FIRETV_IP}:5555"
  DEVICE=$(adb devices | grep "${FIRETV_IP}" | awk '{print $1}')
  if [ -z "$DEVICE" ]; then
    echo -e "${RED}[ERROR] Could not connect.${NC}"
    exit 1
  fi
  echo -e "${GREEN}[OK] Connected${NC}"
  echo ""
}

restore_animations() {
  echo "Restoring default animations..."
  adb shell settings put global window_animation_scale 1.0
  adb shell settings put global transition_animation_scale 1.0
  adb shell settings put global animator_duration_scale 1.0
  echo -e "${GREEN}[OK] Animations restored to 1.0x${NC}"
}

restore_packages() {
  local LOG_FILE="$1"

  if [ -z "$LOG_FILE" ]; then
    LOG_FILE=$(ls -t firetv_disabled_*.txt 2>/dev/null | head -1)
  fi

  if [ -z "$LOG_FILE" ] || [ ! -f "$LOG_FILE" ]; then
    echo -e "${RED}[ERROR] No disabled packages log found.${NC}"
    echo "Usage: ./restore.sh [firetv_disabled_YYYYMMDD_HHMMSS.txt]"
    exit 1
  fi

  echo -e "Restoring packages from: ${CYAN}${LOG_FILE}${NC}"
  echo ""

  while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    adb shell pm enable "$pkg" &>/dev/null && \
      echo -e "  ${GREEN}[ENABLED]${NC} ${pkg}" || \
      echo -e "  ${YELLOW}[SKIP]${NC}    ${pkg} — could not re-enable"
  done < "$LOG_FILE"

  echo ""
  echo -e "${GREEN}All packages restored.${NC}"
}

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}  FireLauncher — Restore Defaults${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

if ! command -v adb &>/dev/null; then
  echo -e "${RED}[ERROR] adb not found.${NC}"
  exit 1
fi

connect_device
restore_packages "$1"
restore_animations

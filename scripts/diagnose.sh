#!/bin/bash
# =============================================================================
# FireLauncher - diagnose.sh
# Connects to a Fire TV via ADB and generates a full diagnostic report.
# =============================================================================

set -e

REPORT_FILE="firetv_report_$(date +%Y%m%d_%H%M%S).txt"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
  echo -e "${CYAN}============================================${NC}"
  echo -e "${CYAN}  FireLauncher — Fire TV Diagnostic Tool${NC}"
  echo -e "${CYAN}============================================${NC}"
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
    echo -e "${RED}[ERROR] Could not connect. Make sure ADB is enabled on your Fire TV.${NC}"
    echo "  → Settings > My Fire TV > Developer Options > ADB Debugging: ON"
    exit 1
  fi

  echo -e "${GREEN}[OK] Connected to ${FIRETV_IP}${NC}"
  echo ""
}

run_diagnostics() {
  echo -e "${CYAN}Running diagnostics... saving to ${REPORT_FILE}${NC}"
  echo ""

  {
    echo "========================================"
    echo "  Fire TV Diagnostic Report"
    echo "  Generated: $(date)"
    echo "========================================"
    echo ""

    echo "--- Device Info ---"
    adb shell getprop ro.build.description
    adb shell getprop ro.build.version.release
    adb shell getprop ro.product.model
    adb shell getprop ro.product.manufacturer
    echo ""

    echo "--- Memory Overview ---"
    adb shell cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable|Buffers|Cached"
    echo ""

    echo "--- Top Processes by RAM ---"
    adb shell top -n 1 -s rss | head -30
    echo ""

    echo "--- Disk Usage ---"
    adb shell df /data
    echo ""

    echo "--- Installed Packages (user-installed) ---"
    adb shell pm list packages -3
    echo ""

    echo "--- All Packages (system + user) ---"
    adb shell pm list packages -f
    echo ""

    echo "--- Running Services ---"
    adb shell dumpsys activity services | grep -E "ServiceRecord|packageName" | head -60
    echo ""

    echo "--- Battery & Thermal ---"
    adb shell dumpsys battery
    echo ""

  } | tee "$REPORT_FILE"

  echo ""
  echo -e "${GREEN}[DONE] Report saved to: ${REPORT_FILE}${NC}"
}

print_header
check_adb
connect_device
run_diagnostics

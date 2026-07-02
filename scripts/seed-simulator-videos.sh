#!/usr/bin/env bash
set -euo pipefail

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

DEVICE="${1:-booted}"
OUT_DIR="${TMPDIR:-/tmp}/mint-mock-videos"
mkdir -p "$OUT_DIR"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg is required. Install it with: brew install ffmpeg" >&2
  exit 1
fi

make_video() {
  local name="$1"
  local color="$2"
  local output="$OUT_DIR/$name.mp4"
  ffmpeg -y \
    -f lavfi -i "color=c=$color:s=1080x1920:d=3:r=30" \
    -f lavfi -i "sine=frequency=420:duration=3" \
    -c:v libx264 -pix_fmt yuv420p -c:a aac -shortest \
    "$output" >/dev/null 2>&1
  echo "$output"
}

videos=(
  "$(make_video mirror-ripple '#b9d1ec')"
  "$(make_video neon-city '#eadfbd')"
  "$(make_video beach-memory '#bcebe5')"
  "$(make_video stargazing '#d9b6e8')"
  "$(make_video cherry-anime '#ecc0d2')"
  "$(make_video city-grade '#c7c0f0')"
)

xcrun simctl bootstatus "$DEVICE" -b >/dev/null
xcrun simctl addmedia "$DEVICE" "${videos[@]}"

echo "Added ${#videos[@]} mock videos to simulator Photos for device: $DEVICE"

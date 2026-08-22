#!/bin/bash
# hypr-screenshot.sh
# Screenshot tool for Hyprland using grim + slurp + hyprpicker (freeze overlay).
# Extracted and adapted from basecamp/omarchy's bin/omarchy-capture-screenshot.
#
# Deps: grim slurp hyprpicker jq wl-clipboard libnotify
#       satty (optional, for the post-capture editor)
#
# Usage: hypr-screenshot.sh [smart|region|windows|fullscreen] [slurp|copy|save] [--editor=<name>]
#   mode 1 (default: smart)
#     smart      - drag to select; a plain click snaps to the window/monitor under the cursor
#     region     - always freeform drag selection
#     windows    - slurp highlights each open window on the active workspace, click one
#     fullscreen - captures the focused monitor, no selection UI
#   mode 2 (default: slurp)
#     slurp - save to file + copy to clipboard + notify with an "edit" action
#     copy  - clipboard only, no file
#     save  - file only, no clipboard

set -euo pipefail

OUTPUT_DIR="${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}"
[[ -d $OUTPUT_DIR ]] || mkdir -p "$OUTPUT_DIR"

SCREENSHOT_EDITOR="${SCREENSHOT_EDITOR:-satty}"

# Parse --editor=<name> from any position
ARGS=()
for arg in "$@"; do
  case $arg in
  --editor=*) SCREENSHOT_EDITOR="${arg#--editor=}" ;;
  *) ARGS+=("$arg") ;;
  esac
done
set -- "${ARGS[@]:-}"

open_editor() {
  local filepath="$1"
  if [[ $SCREENSHOT_EDITOR == "satty" ]]; then
    satty --filename "$filepath" \
      --output-filename "$filepath" \
      --actions-on-enter save-to-clipboard \
      --save-after-copy \
      --copy-command 'wl-copy'
  else
    "$SCREENSHOT_EDITOR" "$filepath"
  fi
}

MODE="${1:-smart}"
PROCESSING="${2:-slurp}"

# Handles portrait/rotated monitors correctly
JQ_MONITOR_GEO='
  def format_geo:
    .x as $x | .y as $y |
    (.width / .scale | floor) as $w |
    (.height / .scale | floor) as $h |
    .transform as $t |
    if $t == 1 or $t == 3 then
      "\($x),\($y) \($h)x\($w)"
    else
      "\($x),\($y) \($w)x\($h)"
    end;
'

get_rectangles() {
  # All monitors, whether focused or not, so smart-mode can snap on any screen.
  local ws_ids
  ws_ids=$(hyprctl monitors -j | jq -c '[.[].activeWorkspace.id]')
  hyprctl monitors -j | jq -r "${JQ_MONITOR_GEO} .[] | format_geo"
  # All windows on any monitor's currently-visible workspace (not just the focused monitor's).
  hyprctl clients -j | jq -r --argjson wss "$ws_ids" '.[] | select(.workspace.id as $w | $wss | index($w) != null) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
}

# Keep hyprpicker alive until grim has captured, so the shot sees the frozen
# overlay instead of live content shifting mid-teardown.
cleanup_freeze() {
  [[ -n ${PID:-} ]] && kill "$PID" 2>/dev/null
}
trap cleanup_freeze EXIT

case "$MODE" in
region)
  hyprpicker -r -z >/dev/null 2>&1 &
  PID=$!
  sleep .1
  SELECTION=$(slurp 2>/dev/null)
  ;;
windows)
  hyprpicker -r -z >/dev/null 2>&1 &
  PID=$!
  sleep .1
  SELECTION=$(get_rectangles | slurp -r 2>/dev/null)
  ;;
fullscreen)
  SELECTION=$(hyprctl monitors -j | jq -r "${JQ_MONITOR_GEO} .[] | select(.focused == true) | format_geo")
  ;;
smart | *)
  RECTS=$(get_rectangles)
  hyprpicker -r -z >/dev/null 2>&1 &
  PID=$!
  sleep .1
  SELECTION=$(echo "$RECTS" | slurp 2>/dev/null)

  # A click-not-drag (area < 20px^2) snaps to the window/monitor under the cursor,
  # to avoid accidental 2px screenshots.
  if [[ $SELECTION =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]]; then
    if ((${BASH_REMATCH[3]} * ${BASH_REMATCH[4]} < 20)); then
      click_x="${BASH_REMATCH[1]}"
      click_y="${BASH_REMATCH[2]}"
      while IFS= read -r rect; do
        if [[ $rect =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+) ]]; then
          rect_x="${BASH_REMATCH[1]}"
          rect_y="${BASH_REMATCH[2]}"
          rect_width="${BASH_REMATCH[3]}"
          rect_height="${BASH_REMATCH[4]}"
          if ((click_x >= rect_x && click_x < rect_x + rect_width && click_y >= rect_y && click_y < rect_y + rect_height)); then
            SELECTION="${rect_x},${rect_y} ${rect_width}x${rect_height}"
            break
          fi
        fi
      done <<<"$RECTS"
    fi
  fi
  ;;
esac

[[ -z ${SELECTION:-} ]] && exit 0

FILENAME="screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"
FILEPATH="$OUTPUT_DIR/$FILENAME"

case "$PROCESSING" in
slurp)
  grim -g "$SELECTION" "$FILEPATH" || exit 1
  echo "$FILEPATH"
  wl-copy <"$FILEPATH"
  (
    ACTION=$(notify-send -a "hypr-screenshot" "Screenshot saved to clipboard and file" "Click to edit" -t 10000 -i "$FILEPATH" -A "default=edit")
    [[ $ACTION == "default" ]] && open_editor "$FILEPATH"
  ) >/dev/null 2>&1 &
  ;;
copy)
  grim -g "$SELECTION" - | wl-copy
  ;;
save)
  grim -g "$SELECTION" "$FILEPATH" || exit 1
  echo "$FILEPATH"
  ;;
esac

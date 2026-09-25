#!/usr/bin/env bash
# hypr-music-shader.sh — audio-reactive screen shader для Hyprland
#
# Використання:
#   ./hypr-music-shader.sh <preset> [файл_або_плеєр]
#
# Приклади:
#   ./hypr-music-shader.sh pulse                    # реагує на будь-який звук у системі
#   ./hypr-music-shader.sh wave ~/Music/track.mp3   # програє файл через mpv і реагує на нього
#   ./hypr-music-shader.sh chromatic
#
# Пресети лежать поруч як *.frag.tpl. Ctrl+C коректно вимикає шейдер.

set -euo pipefail

SHADER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTIVE_SHADER="$SHADER_DIR/active.frag"
OFF_SHADER="$SHADER_DIR/off.frag"
CAVA_CONFIG="$SHADER_DIR/cava.conf"
FIFO="/tmp/hypr-music-shader.fifo"
SMOOTHING="${SMOOTHING:-0.35}"   # 0..1: більше = різкіше реагує, менше = плавніше

# з Hyprland 0.55 конфіг може бути на Lua (hyprland.lua) — тоді `hyprctl keyword`
# не працює ("keyword can't work with non-legacy parsers"), треба `hyprctl eval`
# з hl.config(...). Визначаємо це один раз при старті.
USE_LUA=0
[[ -f "$HOME/.config/hypr/hyprland.lua" ]] && USE_LUA=1

apply_shader() {
    local path="$1"
    if [[ "$USE_LUA" == "1" ]]; then
        hyprctl eval "hl.config({ decoration = { screen_shader = '${path}' } })" >/dev/null 2>&1
    else
        hyprctl keyword decoration:screen_shader "${path}" >/dev/null 2>&1
    fi
}

PRESET="${1:-pulse}"
AUDIO_TARGET="${2:-}"
TEMPLATE="$SHADER_DIR/${PRESET}.frag.tpl"

if [[ ! -f "$TEMPLATE" ]]; then
    echo "Немає такого пресету: '$PRESET'"
    echo "Доступні пресети:"
    for f in "$SHADER_DIR"/*.frag.tpl; do
        basename "$f" .frag.tpl
    done
    exit 1
fi

command -v cava    >/dev/null 2>&1 || { echo "Постав cava (напр. sudo pacman -S cava / sudo apt install cava)"; exit 1; }
command -v hyprctl >/dev/null 2>&1 || { echo "hyprctl не знайдено — це точно Hyprland?"; exit 1; }

CAVA_PID=""
LOOP_PID=""
DEBUG="${DEBUG:-0}"

cleanup() {
    echo
    echo "Вимикаю шейдер і зупиняю аналіз звуку..."
    # НЕ скидаємо на screen_shader = '' — це відомий баг Hyprland
    # ("all shaders must use same shading language version" /
    #  "Unsetting screen_shader results in garbled image"). Замість цього
    # ставимо легкий no-op шейдер, який просто пропускає картинку як є.
    apply_shader "$OFF_SHADER" || true
    [[ -n "$LOOP_PID" ]] && kill "$LOOP_PID" >/dev/null 2>&1 || true
    [[ -n "$CAVA_PID" ]] && kill "$CAVA_PID" >/dev/null 2>&1 || true
    rm -f "$FIFO" "$ACTIVE_SHADER"
}
# лише EXIT: він спрацьовує і при звичайному завершенні, і при Ctrl+C —
# два трапи (EXIT + INT) викликали cleanup двічі
trap cleanup EXIT

rm -f "$FIFO"
mkfifo -m 600 "$FIFO"

cava -p "$CAVA_CONFIG" > "$FIFO" &
CAVA_PID=$!

reactive_loop() {
    local bass=0 mid=0 treble=0
    local tick=0
    # ВАЖЛИВО: редирект < "$FIFO" стоїть після `done`, тобто fifo відкривається
    # ОДИН раз на весь цикл. Якщо його поставити на рядку з `read`, bash буде
    # переоткривати fifo щоразу — у момент між закриттям і відкриттям рідера
    # немає, і cava (писач) може впасти по SIGPIPE. Саме через це раніше
    # нічого не відбувалось.
    while IFS=';' read -r b m t _; do
        b=${b:-0}; m=${m:-0}; t=${t:-0}

        # нормалізація 0..100 -> 0.0..1.0 + експоненційне згладжування
        read -r bass mid treble <<< "$(awk -v b="$b" -v m="$m" -v t="$t" \
            -v pb="$bass" -v pm="$mid" -v pt="$treble" -v s="$SMOOTHING" '
            BEGIN {
                nb=b/100; nm=m/100; nt=t/100
                printf "%.4f %.4f %.4f", pb+(nb-pb)*s, pm+(nm-pm)*s, pt+(nt-pt)*s
            }')"

        sed -e "s/__BASS__/${bass}/g" \
            -e "s/__MID__/${mid}/g" \
            -e "s/__TREBLE__/${treble}/g" \
            "$TEMPLATE" > "$ACTIVE_SHADER"

        apply_shader "$ACTIVE_SHADER"

        if [[ "$DEBUG" == "1" ]]; then
            tick=$((tick + 1))
            if (( tick % 10 == 0 )); then
                echo "bass=$bass mid=$mid treble=$treble" >&2
            fi
        fi
    done < "$FIFO"
}

reactive_loop &
LOOP_PID=$!

echo "Пресет: $PRESET"
echo "Частота оновлення шейдера регулюється параметром framerate у $CAVA_CONFIG"

if [[ -n "$AUDIO_TARGET" ]]; then
    command -v mpv >/dev/null 2>&1 || { echo "Для відтворення файлу треба mpv (sudo pacman -S mpv)"; exit 1; }
    echo "Граю: $AUDIO_TARGET (Ctrl+C — стоп)"
    mpv --no-video --really-quiet "$AUDIO_TARGET"
else
    echo "Реагую на будь-який звук у системі. Онови музику в Spotify/браузері/плеєрі."
    echo "Ctrl+C — вихід."
    wait "$LOOP_PID"
fi

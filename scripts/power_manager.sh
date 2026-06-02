#!/bin/bash

# Початковий стан
LAST_STATE=$(cat /sys/class/power_supply/ADP1/online)

while true; do
    CURRENT_STATE=$(cat /sys/class/power_supply/ADP1/online)

    if [ "$CURRENT_STATE" != "$LAST_STATE" ]; then
        if [ "$CURRENT_STATE" -eq "0" ]; then
            # РЕЖИМ БАТАРЕЇ (Світла немає)
            notify-send -u critical "Battery Mode" "NVIDIA is sleeping. Don't use prime-run!"
            hyprctl keyword monitor ,60,auto,1 # Знижуємо до 60Hz
            hyprctl keyword decoration:blur:enabled false # Вимикаємо блюр для економії
        else
            # РЕЖИМ МЕРЕЖІ (Світло є)
            notify-send "AC Mode" "Performance restored"
            hyprctl keyword monitor ,144,auto,1 # Повертаємо 144Hz (або твої герци)
            hyprctl keyword decoration:blur:enabled true
        fi
        LAST_STATE=$CURRENT_STATE
    fi
    sleep 2
done

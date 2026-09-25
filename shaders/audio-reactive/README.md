# Audio-reactive shader для Hyprland

## Як це працює
Hyprland не передає аудіодані в шейдер напряму — доступні лише `tex`, `v_texcoord`
і `time`. Тому скрипт:

1. слухає системний звук через `cava` (працює з PulseAudio і PipeWire);
2. рахує рівень bass/mid/treble і згладжує його;
3. підставляє ці числа прямо в текст `.frag`-файлу (`sed`);
4. застосовує оновлений шейдер через `hyprctl keyword decoration:screen_shader`
   (класичний `hyprland.conf`) або `hyprctl eval "hl.config(...)"` (новий
   Lua-конфіг `hyprland.lua`, з Hyprland 0.55+) — скрипт сам визначає, який
   у тебе конфіг.

Між оновленнями картинка не завмирає — у шейдерах додатково використано
вбудований `time` для безперервної анімації.

Шейдери написані під сучасний GLSL ES 3.00 (`#version 300 es`, `in`/`out`,
`texture()`), бо саме таку версію очікує вершинний шейдер Hyprland — зі старим
синтаксисом (`varying`, `gl_FragColor`, `texture2D`, без `#version`) лінкування
падає з помилкою `all shaders must use same shading language version`.

Через `time` Hyprland може показати попередження про `debug:damage_tracking`
(мовляв, вимкни для повністю плавної анімації) — це нормально й не критично:
скрипт і так примусово оновлює кадр щоразу, коли підставляє нові значення
гучності, тож ефект видно й без вимкнення damage tracking (яке суттєво
підвищує навантаження на GPU).

## Встановлення

```bash
sudo pacman -S cava        # або: sudo apt install cava
sudo pacman -S mpv         # опційно, якщо хочеш програвати файл прямо зі скрипта

mkdir -p ~/.config/hypr/shaders/audio-reactive
cp *.frag.tpl *.conf hypr-music-shader.sh ~/.config/hypr/shaders/audio-reactive/
chmod +x ~/.config/hypr/shaders/audio-reactive/hypr-music-shader.sh
```

## Використання

```bash
cd ~/.config/hypr/shaders/audio-reactive

# реагувати на будь-який звук у системі (Spotify, браузер, будь-що)
./hypr-music-shader.sh pulse

# запустити пресет і одразу програти файл
./hypr-music-shader.sh wave ~/Music/track.mp3

./hypr-music-shader.sh chromatic
```

Ctrl+C коректно вимикає шейдер і зупиняє cava.

## Пресети
- **pulse** — пульсуюча яскравість/вінʼєтка на баси, теплий відтінок на мідах
- **wave** — хвильове спотворення екрану на трейбл/баси
- **chromatic** — RGB-розсування (хроматична аберація) на трейбл + насиченість на гучність
- **hype** — найагресивніший: zoom-punch і тряска екрану на баси, глітч-смуги на
  трейбл, спалахи яскравості на пікових ударах, хроматична аберація й насиченість
  ростуть із загальним рівнем гучності

## Швидкий запуск через бінд Hyprland
У `hyprland.conf`:

```
bind = $mainMod SHIFT, M, exec, ~/.config/hypr/shaders/audio-reactive/hypr-music-shader.sh wave
```

## Тюнінг
- `SMOOTHING` (env-змінна, 0..1) — різкість реакції: `SMOOTHING=0.6 ./hypr-music-shader.sh pulse`
- `framerate` у `cava.conf` — як часто перезавантажується шейдер. 15 — компроміс
  між плавністю та навантаженням (кожне оновлення — перекомпіляція GLSL).
  Онови в межах 10–25, якщо хочеться чутливіше/легше для GPU.
- Якщо `method = pulse` в `cava.conf` не бачить джерело на чистому PipeWire —
  спробуй `method = pipewire` (якщо твоя збірка cava це підтримує).

## Якщо після Ctrl+C екран виглядає дивно
Скрипт при виході й так ставить `off.frag` (no-op шейдер) замість скидання на
`screen_shader = ''` — це відомий баг Hyprland при повному знятті шейдера.
Якщо все одно щось не так, допомагає:
```bash
hyprctl reload
```

#version 300 es
// preset: hype — агресивний zoom-punch, шейк, глітч-смуги і спалахи на піках
precision highp float;
in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;
uniform float time;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    float bass   = __BASS__;
    float mid    = __MID__;
    float treble = __TREBLE__;
    float level  = (bass + mid + treble) / 3.0;

    vec2 uv = v_texcoord;
    vec2 center = vec2(0.5);

    // "панч" зумом на баси — картинка ніби стискається під удар
    float zoom = 1.0 - bass * 0.06 * (0.6 + 0.4 * sin(time * 10.0));
    uv = center + (uv - center) * zoom;

    // тряска екрану на сильних басах
    float shakeAmt = bass * bass * 0.01;
    uv += vec2(sin(time * 37.0), cos(time * 29.0)) * shakeAmt;

    // горизонтальні глітч-смуги на трейбл (зсув рандомних рядків)
    float stripe = floor(uv.y * 40.0);
    float glitch = (rand(vec2(stripe, floor(time * 12.0))) - 0.5) * treble * 0.03;
    uv.x += glitch;

    // хроматична аберація, що росте із загальним рівнем гучності
    float shift = 0.002 + level * 0.01;
    vec4 col;
    col.r = texture(tex, uv + vec2(shift, 0.0)).r;
    col.g = texture(tex, uv).g;
    col.b = texture(tex, uv - vec2(shift, 0.0)).b;
    col.a = 1.0;

    // спалах яскравості саме на пікових басах (кубічна крива ігнорує тихе бурчання)
    float flash = pow(bass, 3.0) * 0.5;
    col.rgb += vec3(flash);

    // насиченість росте разом із загальним рівнем
    float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));
    col.rgb = mix(vec3(gray), col.rgb, 1.0 + level * 0.8);

    // вінʼєтка стискається на ударі — підсилює відчуття "панчу"
    float dist = distance(v_texcoord, center);
    float vig = smoothstep(0.9, 0.3 - bass * 0.15, dist);
    col.rgb *= mix(0.7, 1.2, vig);

    fragColor = col;
}

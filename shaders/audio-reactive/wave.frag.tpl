#version 300 es
// preset: wave — хвиля/спотворення картинки на трейбл і баси, хроматична підсвітка на мідах
precision highp float;
in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;
uniform float time;

void main() {
    float bass   = __BASS__;
    float mid    = __MID__;
    float treble = __TREBLE__;

    vec2 uv = v_texcoord;

    float wave = sin(uv.y * 40.0 + time * 4.0) * 0.0025 * (0.2 + treble);
    wave += sin(uv.x * 25.0 + time * 2.5) * 0.002 * (0.2 + bass);
    uv.x += wave;

    vec4 pixColor = texture(tex, uv);

    float shift = mid * 0.0035;
    float r = texture(tex, uv + vec2(shift, 0.0)).r;
    float b = texture(tex, uv - vec2(shift, 0.0)).b;
    pixColor.r = mix(pixColor.r, r, mid);
    pixColor.b = mix(pixColor.b, b, mid);

    fragColor = pixColor;
}

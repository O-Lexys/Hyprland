#version 300 es
// preset: chromatic — RGB-розсування на трейбл, насиченість/яскравість на загальний рівень
precision highp float;
in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;
uniform float time;

void main() {
    float bass   = __BASS__;
    float mid    = __MID__;
    float treble = __TREBLE__;

    float level = (bass + mid + treble) / 3.0;
    float shift = treble * 0.006;

    vec2 dir = normalize(v_texcoord - vec2(0.5) + 0.0001) * shift;

    vec4 col;
    col.r = texture(tex, v_texcoord + dir).r;
    col.g = texture(tex, v_texcoord).g;
    col.b = texture(tex, v_texcoord - dir).b;
    col.a = 1.0;

    float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));
    col.rgb = mix(vec3(gray), col.rgb, 1.0 + level * 0.6);
    col.rgb *= 1.0 + bass * 0.12;

    fragColor = col;
}

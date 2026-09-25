#version 300 es
// preset: pulse — пульсуюча яскравість/вінʼєтка на баси, легкий теплий тон на мідах
precision highp float;
in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;
uniform float time;

void main() {
    vec4 pixColor = texture(tex, v_texcoord);

    float bass = __BASS__;
    float mid  = __MID__;

    vec2 center = vec2(0.5, 0.5);
    float dist = distance(v_texcoord, center);

    float breathe = 1.0 + 0.02 * sin(time * 2.0);
    float pulse = (1.0 + bass * 0.35) * breathe;
    float vignette = smoothstep(0.9 * pulse, 0.2, dist);

    vec3 tint = mix(vec3(1.0), vec3(1.05, 1.0, 0.95 + mid * 0.1), mid);

    pixColor.rgb *= mix(0.78, 1.15, vignette);
    pixColor.rgb *= tint;

    fragColor = pixColor;
}

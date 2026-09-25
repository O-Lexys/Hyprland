#version 300 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;

const float brightness = -0.25;  // -1.0 .. 1.0
const float contrast   = 2.00;  // 1.0 = без змін
const float saturation = 0.00;  // 1.0 = без змін

void main() {
    vec4 pixColor = texture(tex, v_texcoord);

    // Яскравість
    pixColor.rgb += brightness;

    // Контраст
    pixColor.rgb = (pixColor.rgb - 0.5) * contrast + 0.5;

    // Насиченість
    float gray = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
    pixColor.rgb = mix(vec3(gray), pixColor.rgb, saturation);

    fragColor = pixColor;
}

#version 460 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex9;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    vec4 colorMain = texture(colortex0, texcoord);
    vec4 colorBloom = texture(colortex9, texcoord);

    float bloomAlpha = colorBloom.a;

    color = colorMain;
    color.rgb = color.rgb  + colorBloom.rgb * 0.2;
}
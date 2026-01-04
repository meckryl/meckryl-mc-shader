#version 460 compatibility

#include "/lib/globals.glsl"
#include "/lib/gaussianBlur.glsl"

uniform sampler2D colortex9;

in vec2 texcoord;

/* RENDERTARGETS: 9 */
layout(location = 0) out vec4 color;

void main() {
    color = blurSig3(texcoord, colortex9, screenSize, false);
}
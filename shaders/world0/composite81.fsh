#version 460 compatibility

#include "/lib/globals.glsl"
#include "/lib/spaceConversions.glsl"
#include "/lib/RTW/warp.glsl"

layout (r32f) uniform image2D rtw_imap;

uniform sampler2D depthtex1;

in vec2 texcoord;

void main() {
    ivec2 texelPos = ivec2(texcoord * screenSize);
    if (texelPos.x != clamp(texelPos.x, 0.0, RTW_IMAP_RES) || texelPos.y != clamp(texelPos.y, 0.0, RTW_IMAP_RES)) discard;

    float currentValue = imageLoad(rtw_imap, texelPos).x;
    
    if (currentValue >= 0.0) {
        imageStore(rtw_imap, texelPos, vec4((length(texelPos/float(RTW_IMAP_RES) - 0.5) < 0.05) ? 3.0 : 0.0));
    }
    else {
        imageStore(rtw_imap, texelPos, vec4(abs(currentValue)));
    }
}
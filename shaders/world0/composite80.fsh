#version 460 compatibility

#include "/lib/globals.glsl"
#include "/lib/spaceConversions.glsl"
#include "/lib/RTW/warp.glsl"

layout (r32f) uniform image2D rtw_imap;

uniform sampler2D depthtex1;

in vec2 texcoord;

void main() {
    float depth = texelFetch(depthtex1, ivec2(texcoord * screenSize), 0).x;
    if (depth >= 1.0) return;
    vec3 pos = vec3(texcoord, depth);
    pos = ndcPosToViewPos(pos * 2.0 - 1.0);
    pos = viewPosToLocalPos(pos);
    float dist = length(pos.xy);
    pos = localPosToSViewPos(pos);
    pos = sViewPosToSNDCPos(pos);


    imageStore(rtw_imap, ivec2((pos.xy * 0.5 + 0.5) * RTW_IMAP_RES), vec4(-1.0 - min(80.0/dist, 18.0)));
}
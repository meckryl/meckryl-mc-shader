#version 460 compatibility

#define BACKWARDS_RESOLUTION ivec2(2560, 1440)
#define COMPUTE

#include "/lib/globals.glsl"
#include "/lib/spaceConversions.glsl"

layout(local_size_x = 256, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(1440, 10, 1);

uniform sampler2D colortex2;
uniform sampler2D depthtex2;

layout (r32ui) uniform uimage2D rtw_imap;

uniform vec3 shadowLightPosition;

void main() {
    uint workGroupID = gl_WorkGroupID.x;
    uint localID = gl_LocalInvocationID.x;

    ivec2 invoMapping = ivec2(localID + 256.0 * gl_WorkGroupID.y, workGroupID);
    vec2 screenPos = vec2(float(invoMapping.x) / viewWidth, float(invoMapping.y) / viewHeight);

    float depth = texelFetch(depthtex2, ivec2(invoMapping), 0).x;
    if (depth < 0.56) {
        depth  = depth * 2.0 - 1.0;
		depth *= 1.0 / MC_HAND_DEPTH;
		depth  = depth * 0.5 + 0.5;
    }
    if (depth >= 1.0) return;
    
    vec3 pos = vec3(screenPos, depth);
    pos = ndcPosToViewPos(pos * 2.0 - 1.0);
    pos = viewPosToLocalPos(pos);
    pos = localPosToSViewPos(pos);
    pos = sViewPosToSNDCPos(pos);

    float val = 20.0;
    //val *= max(1.0 - clamp01(dot(texelFetch(colortex2, ivec2(invoMapping), 0).xyz * 2.0 - 1.0, normalize(viewPosToLocalPos(shadowLightPosition)))), 0.0);

    ivec2 texelPos = ivec2((pos.xy * 0.5 + 0.5) * RTW_IMAP_RES);

    imageAtomicAdd(rtw_imap, texelPos, int(val));
}
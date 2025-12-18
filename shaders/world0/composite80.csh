#version 460 compatibility

#define COMPUTE

#include "/lib/globals.glsl"
#include "/lib/math.glsl"
#include "/lib/spaceConversions.glsl"

layout(local_size_x = RTW_IMAP_RES, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(RTW_IMAP_RES, 1, 1);

layout (r32ui) uniform uimage2D rtw_imap;

#include "/lib/RTW/warp.glsl"

uniform int frameCounter;
uniform sampler2D shadowtex0;

const float SMOOTH_BOUND = 0.995;

vec2 screenToTex(vec3 screenPos) {
    vec3 pos = ndcPosToViewPos(screenPos * 2.0 - 1.0);
    pos = viewPosToLocalPos(pos);
    pos = localPosToSViewPos(pos);
    pos = 4.0 * sViewPosToSNDCPos(pos);
    
    return (pos.xy * 0.5 + 0.5) * RTW_IMAP_RES; 
}

vec2 getPointBehind(out float yFactor) {
    vec3 pos = gbufferModelViewInverse[2].xyz;
    yFactor = abs(pos.y);
    pos.y = 0;
    pos = normalize(pos);
    pos = localPosToSViewPos((5.0 + yFactor * 10.0) * pos);
    pos = sViewPosToSNDCPos(pos);
    
    return (pos.xy * 0.5 + 0.5) * RTW_IMAP_RES; 
}

void main() {
    uint workGroupID = gl_WorkGroupID.x;
    uint localID = gl_LocalInvocationID.x;

    vec2 invoMapping = vec2(localID + 4, workGroupID);
    if (invoMapping.x >= RTW_IMAP_RES) return;

    float dist = length(invoMapping - 0.5 * RTW_IMAP_RES);
    float value = max(min(240.0 - 10.0 * dist, 240.0), 0) * 8.0;
    

    vec2 mappedPos = warpFromTexel(invoMapping);

    value += (mappedPos.x >= -SMOOTH_BOUND && mappedPos.x <= SMOOTH_BOUND && mappedPos.y >= -SMOOTH_BOUND && mappedPos.y <= SMOOTH_BOUND) ? 1.0 : 0.0;


    imageStore(rtw_imap, ivec2(invoMapping), uvec4(value, 0, 0, 1));
}
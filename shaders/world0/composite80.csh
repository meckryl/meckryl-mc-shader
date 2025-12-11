#version 460 compatibility

#define COMPUTE

#include "/lib/globals.glsl"
#include "/lib/math.glsl"
#include "/lib/spaceConversions.glsl"

layout(local_size_x = RTW_IMAP_RES, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(RTW_IMAP_RES, 1, 1);

layout (r32ui) uniform uimage2D rtw_imap;

vec2 screenToTex(vec3 screenPos) {
    vec3 pos = ndcPosToViewPos(screenPos * 2.0 - 1.0);
    pos = viewPosToLocalPos(pos);
    pos = localPosToSViewPos(pos);
    pos = sViewPosToSNDCPos(pos);
    
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

    ivec2 invoMapping = ivec2(localID, workGroupID);

    float yFactor;
    bool inViewWedge = testInWedge(invoMapping, getPointBehind(yFactor), screenToTex(vec3(1.1, 0.5, 1.0)), screenToTex(vec3(-0.1, 0.5, 1.0)));

    int value = 0;
    
    if (inViewWedge || yFactor >= 0.95) {
        value = max(int(min(300.0 - 5.0 * length(invoMapping - RTW_IMAP_RES / 2.0), 300.0)), 1);
    }

    imageStore(rtw_imap, invoMapping, uvec4(value, 0, 0, 1));
}
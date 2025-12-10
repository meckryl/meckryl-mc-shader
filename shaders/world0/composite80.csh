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

vec2 getPointBehind() {
    vec3 pos = vec3(0.5, 0.5, 1.0);
    pos = ndcPosToViewPos(pos * 2.0 - 1.0);
    pos = viewPosToLocalPos(pos);
    pos.y = 0;
    pos = normalize(pos);
    pos = localPosToSViewPos(-5.0 * pos);
    pos = sViewPosToSNDCPos(pos);
    
    return (pos.xy * 0.5 + 0.5) * RTW_IMAP_RES; 
}

void main() {
    uint workGroupID = gl_WorkGroupID.x;
    uint localID = gl_LocalInvocationID.x;

    ivec2 invoMapping = ivec2(localID, workGroupID);

    bool inViewWedge = testInWedge(invoMapping, getPointBehind(), screenToTex(vec3(1.1, 0.5, 1.0)), screenToTex(vec3(-0.1, 0.5, 1.0)));

    int value = 0;
    
    if (inViewWedge) {
        value = max(int(min(300.0 - 5.0 * length(invoMapping - RTW_IMAP_RES / 2.0), 300.0)), 1);
    }
    else if (length(vec2(invoMapping)/float(RTW_IMAP_RES) - 0.5) < 0.01) {
        //value = 100;
    }
    else if (length(vec2(invoMapping)/float(RTW_IMAP_RES) - 0.5) < 0.04) {
        //value = 45;
    }

    imageStore(rtw_imap, invoMapping, uvec4(value, 0, 0, 1));
}
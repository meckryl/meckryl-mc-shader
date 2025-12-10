#version 460 compatibility

#define BACKWARDS_RESOLUTION ivec2(2560, 1440)
#define COMPUTE

#include "/lib/globals.glsl"
#include "/lib/spaceConversions.glsl"

layout(local_size_x = 256, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(1440, 10, 1);

layout (r32f) uniform restrict image2D rtw_imap;

uniform sampler2D depthtex1;

void main() {
    uint workGroupID = gl_WorkGroupID.x;
    uint localID = gl_LocalInvocationID.x;

    vec2 invoMapping = vec2(float(localID + 256.0 * gl_WorkGroupID.y) / 2560.0 , float(workGroupID) / 1440.0);

    float depth = texelFetch(depthtex1, ivec2(invoMapping * screenSize), 0).x;
    if (depth >= 1.0) return;
    
    vec3 pos = vec3(invoMapping, depth);
    pos = ndcPosToViewPos(pos * 2.0 - 1.0);
    pos = viewPosToLocalPos(pos);
    float dist = length(pos.xy);
    pos = localPosToSViewPos(pos);
    pos = sViewPosToSNDCPos(pos);

    float value = 1.0 + min(80.0/dist, 18.0);

    imageStore(rtw_imap, ivec2((pos.xy * 0.5 + 0.5) * RTW_IMAP_RES), vec4(value));
    
}
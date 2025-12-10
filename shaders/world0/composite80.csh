#version 460 compatibility

#include "/lib/globals.glsl"

layout(local_size_x = RTW_IMAP_RES, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(RTW_IMAP_RES, 1, 1);

layout (r32f) uniform image2D rtw_imap;

void main() {
    uint workGroupID = gl_WorkGroupID.x;
    uint localID = gl_LocalInvocationID.x;

    ivec2 invoMapping = ivec2(localID, workGroupID);

    int value = 0;
    if (length(vec2(invoMapping)/float(RTW_IMAP_RES) - 0.5) < 0.05) {
        value = 3;
    }

    imageStore(rtw_imap, invoMapping, vec4(value));
}
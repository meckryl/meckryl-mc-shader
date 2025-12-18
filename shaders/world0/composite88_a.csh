#version 460 compatibility

#define BLUR_RANGE 11

#include "/lib/globals.glsl"

layout(local_size_x = RTW_IMAP_RES - BLUR_RANGE + 1, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(2, 1, 1);

layout (r32ui) uniform uimage2D rtw_imap;

uniform sampler2D depthtex1;

uniform int frameCounter;

void main() {
    uint workGroupID = gl_WorkGroupID.x;
    uint localID = gl_LocalInvocationID.x;

    ivec2 invoMapping = ivec2(workGroupID, localID);

    float sum = 0.0;    
    float current = 0.0;
    for (int i = 0; i < BLUR_RANGE; i++){
        ivec2 currentTexel = invoMapping;
        currentTexel.y += i - int(BLUR_RANGE * 0.5);

        if (currentTexel.y == clamp(currentTexel.y, 0, RTW_IMAP_RES)) {
            float sampleValue = imageLoad(rtw_imap, currentTexel).x;
            sum += sampleValue;
        }
        else {
            sum += 0;
        }
    }

    sum /= 1.0 + BLUR_RANGE * 2.0;

    imageAtomicMax(rtw_imap, invoMapping + ivec2(2, 0), max(int(sum), imageLoad(rtw_imap, invoMapping).x));
}
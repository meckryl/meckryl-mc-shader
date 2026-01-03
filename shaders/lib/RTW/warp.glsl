#include "/lib/spaceConversions.glsl"

const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;
const bool shadowcolor0Nearest = false;

#ifndef COMPUTE
layout (r32ui) uniform uimage2D rtw_imap;
#endif

const float inverse_res = 1.0 / RTW_IMAP_RES;

float lerpSum(float val, int col) {
    int floorVal = int(floor(val));
    return mix(imageLoad(rtw_imap, ivec2(col, floorVal)).x, imageLoad(rtw_imap, ivec2(col, floorVal + 1)).x, fract(val));
}

vec2 mapPos(vec3 fromPos) {
    vec2 resultPos = ivec2(0.0);
    vec2 texelPos = (fromPos.xy * 0.5 + 0.5) * RTW_IMAP_RES;

    resultPos.x = lerpSum(min(texelPos.x, RTW_IMAP_RES - 1), 3);
    resultPos.y = lerpSum(min(texelPos.y, RTW_IMAP_RES - 1), 2);

    resultPos = resultPos * inverse_res * inverse_res * 2.0 - 1.0;

    return resultPos;
}

vec2 warpFromTexel(vec2 texelPos) {
    vec2 resultPos = ivec2(0.0);
    resultPos.x = lerpSum(min(texelPos.x, RTW_IMAP_RES - 1), 3);
    resultPos.y = lerpSum(min(texelPos.y, RTW_IMAP_RES - 1), 2);

    resultPos = resultPos * 2.0 * inverse_res * inverse_res - 1.0;

    return resultPos;
}

float getResolutionFactor(vec2 shadowCoord) {
    vec2 texCoord = shadowCoord * RTW_IMAP_RES;
    float resolutionX;
    float resolutionY;
    float minResolution = shadowMapResolution;
    for (int x = int(floor(texCoord.x) - 1); x < floor(texCoord.x) + 2; x++) {
        for (int y = int(floor(texCoord.y) - 1); y < floor(texCoord.y) + 2; y++) {
            resolutionX = abs(imageLoad(rtw_imap, ivec2(3, floor(texCoord.x) + 1)).x - imageLoad(rtw_imap, ivec2(3, floor(texCoord.x))).x);
            resolutionY = abs(imageLoad(rtw_imap, ivec2(2, floor(texCoord.y) + 1)).x - imageLoad(rtw_imap, ivec2(2, floor(texCoord.y))).x);
            minResolution = min(min(resolutionX, resolutionY), minResolution);
        }
    }
    
    return RTW_IMAP_RES / minResolution;
}
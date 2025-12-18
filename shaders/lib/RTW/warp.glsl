#include "/lib/spaceConversions.glsl"

const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;
const bool shadowcolor0Nearest = false;

#ifndef COMPUTE
layout (r32ui) uniform uimage2D rtw_imap;
#endif

float lerpSum(float val, int col) {
    int floorVal = int(floor(val));
    return mix(imageLoad(rtw_imap, ivec2(col, floorVal)).x, imageLoad(rtw_imap, ivec2(col, floorVal + 1)).x, fract(val));
}

float getImportance(vec3 localPos) {
    vec3 pos = localPosToSViewPos(localPos);
    pos = sViewPosToSNDCPos(pos);
    vec2 texelPos = (pos.xy * 0.5 + 0.5) * RTW_IMAP_RES;
    float sliceX = lerpSum(min(texelPos.x, RTW_IMAP_RES - 1.0), 3);
    float totalX = imageLoad(rtw_imap, ivec2(1, RTW_IMAP_RES - 1.0)).x;
    float sliceY = lerpSum(min(texelPos.y, RTW_IMAP_RES - 1.0), 2);
    float totalY = imageLoad(rtw_imap, ivec2(0, RTW_IMAP_RES - 1.0)).x;
    return max((sliceX/totalX) * (sliceY/totalY) * RTW_IMAP_RES * RTW_IMAP_RES, 0.001);
}

vec2 mapPos(vec3 fromPos) {
    vec2 resultPos = ivec2(0.0);

    vec2 ndcPos = fromPos.xy;

    vec2 texelPos = (ndcPos.xy * 0.5 + 0.5) * RTW_IMAP_RES;

    float partialSumX = lerpSum(min(texelPos.x, RTW_IMAP_RES - 1), 1);
    float fullSumX = imageLoad(rtw_imap, ivec2(1, RTW_IMAP_RES - 1)).x;
    resultPos.x = partialSumX / fullSumX - (texelPos.x + 1) / float(RTW_IMAP_RES);

    float partialSumY = lerpSum(min(texelPos.y, RTW_IMAP_RES - 1), 0);
    float fullSumY = imageLoad(rtw_imap, ivec2(0, RTW_IMAP_RES - 1)).x;
    resultPos.y = partialSumY / fullSumY - (texelPos.y + 1) / float(RTW_IMAP_RES);

    ndcPos += resultPos * 2.0; //The offset calculated above is the offset in screen space. To offset the NDC position, this needs to be doubled.

    return ndcPos;
}

vec2 warpFromTexel(vec2 texelPos) {
    vec2 resultPos = vec2(0.0);
    vec2 ndcPos = (texelPos / float(RTW_IMAP_RES)) * 2.0 - 1.0;

    float partialSumX = imageLoad(rtw_imap, ivec2(1, min(texelPos.x - 1, RTW_IMAP_RES - 1))).x;
    float fullSumX = max(imageLoad(rtw_imap, ivec2(1, RTW_IMAP_RES - 1)).x, 1);
    resultPos.x = partialSumX / fullSumX - (texelPos.x) / float(RTW_IMAP_RES);

    float partialSumY = imageLoad(rtw_imap, ivec2(0, min(texelPos.y - 1, RTW_IMAP_RES - 1))).x;
    float fullSumY = max(imageLoad(rtw_imap, ivec2(0, RTW_IMAP_RES - 1)).x, 1);
    resultPos.y = partialSumY / fullSumY - (texelPos.y) / float(RTW_IMAP_RES);

    ndcPos += resultPos * 2.0; //The offset calculated above is the offset in screen space. To offset the NDC position, this needs to be doubled.

    return ndcPos;
}

float sampleUnwarped(vec2 coord, sampler2D shadowSampler) {
    return texture(shadowSampler, mapPos(vec3(coord, 0.0))).r;
}
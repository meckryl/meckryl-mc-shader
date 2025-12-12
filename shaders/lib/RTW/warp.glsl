#include "/lib/spaceConversions.glsl"

const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;
const bool shadowcolor0Nearest = true;

const float scaleFactor = RTW_IMAP_RES/shadowMapResolution;

layout (r32ui) uniform restrict uimage2D rtw_imap;

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

    float partialSumX = lerpSum(min(texelPos.x, RTW_IMAP_RES - 1.0), 1);
    //float partialSumX = texelPos.x;
    float fullSumX = imageLoad(rtw_imap, ivec2(1, RTW_IMAP_RES - 1.0)).x;
    //float fullSumX = 511;
    resultPos.x = partialSumX / fullSumX - (texelPos.x + 1) / float(RTW_IMAP_RES);

    float partialSumY = lerpSum(min(texelPos.y, RTW_IMAP_RES - 1.0), 0);
    //float partialSumY = texelPos.y;
    float fullSumY = imageLoad(rtw_imap, ivec2(0, RTW_IMAP_RES - 1.0)).x;
    //float fullSumY = 511;
    resultPos.y = partialSumY / fullSumY - (texelPos.y + 1) / float(RTW_IMAP_RES);

    ndcPos += resultPos * 2.0; //The offset calculated above is the offset in screen space. To offset the NDC position, this needs to be doubled.

    return ndcPos;
}
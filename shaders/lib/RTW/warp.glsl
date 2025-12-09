#include "/lib/spaceConversions.glsl"

/*
const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;
const bool shadowcolor0Nearest = true;
*/

const float scaleFactor = RTW_IMAP_RES/shadowMapResolution;

float lerpSum(float val, int row, sampler2D imap) {
    int floorVal = int(floor(val));
    return mix(texelFetch(imap, ivec2(row, floorVal), 0).x, texelFetch(imap, ivec2(row, floorVal + 1), 0).x, fract(val));
}

vec2 mapPos(vec3 fromPos, sampler2D imap) {
    vec2 resultPos = ivec2(0.0);

    vec2 ndcPos = fromPos.xy;

    vec2 texelPos = (ndcPos.xy * 0.5 + 0.5) * RTW_IMAP_RES;

    float partialSumX = lerpSum(min(texelPos.x, RTW_IMAP_RES - 1.0), 1, imap);
    //float partialSumX = texelPos.x;
    float fullSumX = texelFetch(imap, ivec2(1, RTW_IMAP_RES - 1.0), 0).x;
    //float fullSumX = 511;
    resultPos.x = partialSumX / fullSumX - (texelPos.x + 1) / float(RTW_IMAP_RES);

    float partialSumY = lerpSum(min(texelPos.y, RTW_IMAP_RES - 1.0), 0, imap);
    //float partialSumY = texelPos.y;
    float fullSumY = texelFetch(imap, ivec2(0, RTW_IMAP_RES - 1.0), 0).x;
    //float fullSumY = 511;
    resultPos.y = partialSumY / fullSumY - (texelPos.y + 1) / float(RTW_IMAP_RES);

    ndcPos += resultPos * 2.0; //The offset calculated above is the offset in screen space. To offset the NDC position, this needs to be doubled.

    return ndcPos;
}
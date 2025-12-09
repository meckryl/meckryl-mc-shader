#include "/lib/globals.glsl"
#include "/lib/spaceConversions.glsl"

const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;
const bool shadowcolor0Nearest = true;

vec3 distortShadowClipPos(vec3 shadowClipPos){
    float distortionFactor = length(shadowClipPos.xy);
    distortionFactor += 0.03;
    shadowClipPos.xy /= distortionFactor;

    shadowClipPos.z *= 0.5;
    return shadowClipPos;
}
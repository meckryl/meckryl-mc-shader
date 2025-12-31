#include "/lib/globals.glsl"
#include "/lib/math.glsl"
#include "/lib/spaceConversions.glsl"

const vec3 waterColor = vec3(0, 0.5, 1);

vec4 getWaterFogColor(float depthToWater, float depthToSolid) {
    float fogFactor = 1.0 - 1.0 / max(depthToSolid - depthToWater, 1.0);
    return vec4(waterColor, fogFactor);
}
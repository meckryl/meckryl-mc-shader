#include "/lib/globals.glsl"
#include "/lib/spaceConversions.glsl"
#include "/lib/math.glsl"
#include "/lib/sceneLighting.glsl"

uniform sampler2D colortex6;
uniform sampler2D colortex7;

vec3 getLocalNormal(vec2 screenCoord) {
    vec3 blockNormal = normalize(texture(colortex2, screenCoord).xyz * 2.0 - 1.0);
    vec3 blockTangent = normalize(cross(blockNormal, vec3(0, 1, 1)));
    mat3 TBN = mat3(blockTangent, cross(blockNormal, blockTangent), blockNormal);

#ifdef MC_TEXTURE_FORMAT_LAB_PBR
    vec2 incompleteNormal = (texture(colortex7, screenCoord).xy) * 2.0 - 1.0;
    vec3 tangentSpaceNormal = vec3(incompleteNormal.xy, sqrt(1.0 - dot(incompleteNormal.xy, incompleteNormal.yx)));
    
#else
    vec3 tangentSpaceNormal = vec3(0.0, 0.0, 1.0);
#endif
    return TBN * tangentSpaceNormal;
}

float getReflectionFactor(vec2 screenCoord, float smoothness, float reflectance) {
    float roughness = pow2(1.0 - smoothness);

    vec3 screenPos = vec3(screenCoord, texture(depthtex0, screenCoord).x);
    vec3 viewPos = ndcPosToViewPos((screenPos - 0.5) * 2.0);
    vec3 localPos = viewPosToLocalPos(viewPos);

    vec3 viewDirection = -normalize(localPos);
    vec3 surfaceNorm = getLocalNormal(screenCoord);
    vec3 halfDirection = surfaceNorm;

    float NoH = dot(surfaceNorm, halfDirection);
    float NoV = dot(surfaceNorm, viewDirection);
    float HoV = clamp01(dot(halfDirection, viewDirection));
    float NoL = clamp01(NoV);

    float normalDistribution = pow2(roughness);
    normalDistribution /= PI * pow2(pow2(NoH) * (pow2(roughness) - 1) + 1);

    float k = pow2(roughness + 1) * 0.125;
    float geometryFunction = (NoV / (NoV * (1 - k) + k)) * (NoL / (NoL * (1 - k) + k));

    float fresnel = reflectance + (1 - reflectance) * pow(1 - (HoV), 5); //Approximation, should replace to support metalic values

    float reflectionFactor = normalDistribution * fresnel * geometryFunction;
    reflectionFactor /= 4 * NoV * NoL;

    return max(reflectionFactor, 0);
}

vec3 getSurfaceRadiance(vec2 screenCoord, vec3 albedo) {
    vec3 screenPos = vec3(screenCoord, texture(depthtex0, screenCoord).x);
    vec3 viewPos = ndcPosToViewPos((screenPos - 0.5) * 2.0);
    vec3 localPos = viewPosToLocalPos(viewPos);

    vec3 viewDirection = -normalize(localPos);
    vec3 halfDirection = normalize(viewDirection + getMainLightDirection());
    vec3 surfaceNorm = getLocalNormal(screenCoord);

    vec3 specular = texture(colortex6, screenCoord).xyz;
    float roughness = pow2(1.0 - specular.x);
    float reflectance = specular.y;

    float NoH = dot(surfaceNorm, halfDirection);
    float NoV = dot(surfaceNorm, viewDirection);
    float HoV = dot(halfDirection, viewDirection);
    float NoL = clamp01(dot(surfaceNorm, getMainLightDirection()));

    float normalDistribution = pow2(roughness);
    normalDistribution /= PI * pow2(pow2(NoH) * (pow2(roughness) - 1) + 1);

    float k = pow2(roughness + 1) * 0.125;
    float geometryFunction = (NoV / (NoV * (1 - k) + k)) * (NoL / (NoL * (1 - k) + k));

    float fresnel = reflectance + (1 - reflectance) * pow(1 - (HoV), 5); //Approximation, should replace to support metalic values
    
    float diffuseFactor = (1 - fresnel);


    vec3 blockNormal = normalize(texture(colortex2, screenCoord).xyz * 2.0 - 1.0);
    vec4 shadowClipPos = screenPosToShadowClipPos(screenPos, surfaceNorm);
	vec3 directLight = getSoftShadow(shadowClipPos, screenCoord, length(localPos.xz));

    vec4 sceneLighting = getLightVector(screenPos);
    vec3 mainlight = sceneLighting.x * getMainColor() * directLight * NoL;
    vec3 diffuse = sceneLighting.y * skylightColor + sceneLighting.z * blocklightColor + sceneLighting.w * ambientColor + mainlight * diffuseFactor;
    diffuse *= albedo;

    float reflectionFactor = normalDistribution * fresnel * geometryFunction;
    reflectionFactor /= 4 * NoV * NoL;

    vec3 reflected = mainlight * reflectionFactor;
    reflected = max(reflected, 0.0);

    return diffuse + reflected;
}
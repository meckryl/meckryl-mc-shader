#version 460 compatibility

#include "/program/blockFacePBR.glsl"
#include "/lib/lighting/screenReflections.glsl"
#include "/lib/atmosphere/atmosphere.glsl"

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

uniform sampler2D colortex0; //Scene

void main() {
    color = texture(colortex0, texcoord);
    float depth = texture(depthtex0, texcoord).x;
    if (depth == 1.0) return;

    vec3 screenPos = vec3(texcoord, depth);
    vec3 surfaceNorm = normalize(texture(colortex2, texcoord).xyz * 2.0 - 1.0);

    vec3 ray;
    bool hitSky = false;
    float fresnel;
    float reflectionFactor = getReflectionFactor(texcoord, texture(colortex6, texcoord).x, texture(colortex6, texcoord).y, fresnel);
    vec4 reflectedColor = texture(colortex6, texcoord).y >= 0.2 ? getReflectedColor(screenPos, surfaceNorm, colortex0, depthtex0, colortex2, ray, hitSky) : vec4(0.0);
    /*if (hitSky) {
        reflectedColor = vec4(getSkyColor(ray), reflectedColor.a);
        reflectedColor.rgb = vec3(1.0) - exp(-1.0 * reflectedColor.rgb * 11);
    }*/
    
    if (reflectedColor.r < 0) {
        reflectedColor = vec4(getSkyColor(ray), clamp01(reflectedColor.a + 0.5));
        reflectedColor.rgb = vec3(1.0) - exp(-1.0 * reflectedColor.rgb * 11);
    }
    
    float alpha = clamp01(reflectedColor.a * reflectionFactor * fresnel);
    color.rgb = color.rgb * (1.0 - alpha) + reflectedColor.rgb * alpha;
}
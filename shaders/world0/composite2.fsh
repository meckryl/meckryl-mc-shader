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

    vec3 screenPos = vec3(texcoord, texture(depthtex0, texcoord).x);
    vec3 surfaceNorm = normalize(texture(colortex2, texcoord).xyz * 2.0 - 1.0);

    vec2 hitPos;
    bool hitSky = false;
    float reflectionFactor = getReflectionFactor(texcoord, texture(colortex6, texcoord).x, texture(colortex6, texcoord).y);
    vec4 reflectedColor = reflectionFactor >= 0.3 ? getReflectedColor(screenPos, surfaceNorm, colortex0, depthtex0, colortex2, hitPos, hitSky) : vec4(-1.0);
    if (hitSky) {
        //reflectedColor = vec4(vec3(1.0) - exp(-1.0 * getSkyColor(texcoord.xy) * 7), reflectedColor.a);
        reflectedColor = vec4(getSkyColor(texcoord.xy), reflectedColor.a);
    }
    if (reflectedColor.r < 0) {
        return;
    }

    float alpha = reflectedColor.a * reflectionFactor;
    color.rgb += reflectedColor.rgb * alpha;
}
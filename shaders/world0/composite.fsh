#version 460 compatibility

#include "/lib/spaceConversions.glsl"

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

uniform sampler2D colortex0; //Opaque scene
uniform sampler2D colortex8; //Translucent scene
uniform sampler2D depthtex1;

uniform bool isEyeInWater;

void main() {
    vec4 colorOpaque = texture(colortex0, texcoord);
    vec4 colorTranslucent = texture(colortex8, texcoord);
    float alpha = colorTranslucent.a;
    color.rgb = colorOpaque.rgb * (1 - alpha) + colorTranslucent.rgb * alpha;
    color.a = 1.0;

    if (isEyeInWater) {
        float translucentDepth = texelFetch(depthtex0, ivec2(gl_FragCoord.xy), 0).x * 2.0 - 1.0;
        translucentDepth = -ndcPosToViewPos(vec3(0, 0, translucentDepth)).z;
        const vec3 waterFogColor = vec3(0.0, 0.1, 0.15);
        float fogStrength = clamp01(translucentDepth * 0.05);
        color.rgb = mix(color.rgb, waterFogColor, fogStrength);
    }
}
#version 420 compatibility

#include "/lib/globals.glsl"
#include "/program/tonemap.fsh"

uniform sampler2D colortex0;
uniform sampler2D colortex3;
uniform sampler2D shadowtex0;
uniform sampler3D rayleigh_ss_LUT;

in vec2 texcoord;
uniform bool is_sneaking;

const float exposure = 2.0;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	vec4 sampledColor = vec4(texture(colortex0, texcoord));


#ifdef DEBUG
    if (!is_sneaking) {
        sampledColor *= exposure;
    }
    else {
        sampledColor *= exposure;
    }
#else
    sampledColor *= exposure;
#endif

    sampledColor.rgb = lottesTonemap(sampledColor.rgb);
    //sampledColor.rgb = ACESFitted(sampledColor.rgb);
    //sampledColor.rgb = ACESApproximate(sampledColor.rgb);

    
    sampledColor.rgb = pow(sampledColor.rgb, vec3(1.0 / 2.2)); // Gamma correction

    color = sampledColor;
}
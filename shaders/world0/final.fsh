#version 420 compatibility

#include "/lib/globals.glsl"
#include "/program/tonemap.fsh"

uniform sampler2D colortex0;
uniform sampler2D colortex3;
uniform sampler2D shadowtex0;
uniform sampler3D rayleigh_ss_LUT;

in vec2 texcoord;
uniform bool is_sneaking;

const float exposure = 3.0;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	vec4 sampledColor = vec4(texture(colortex0, texcoord));

    sampledColor.rgb = ACESFitted(sampledColor.rgb);
    //sampledColor.rgb = ACESApproximate(sampledColor.rgb);

#ifdef DEBUG
    if (!is_sneaking) {
        sampledColor.rgb = vec3(1.0) - exp(-1.0 * sampledColor.rgb * exposure);
    }
#else
    sampledColor.rgb = vec3(1.0) - exp(-1.0 * sampledColor.rgb * exposure);
#endif
    
    sampledColor.rgb = pow(sampledColor.rgb, vec3(1.0 / 2.2)); // Gamma correction

    color = sampledColor;
}
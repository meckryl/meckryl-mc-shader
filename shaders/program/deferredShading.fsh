#include "/program/blockFacePBR.glsl"
#include "/lib/atmosphere/atmosphere.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

uniform sampler2D colortex0;
uniform sampler2D colortex3;
uniform sampler2D colortex5;

in vec2 texcoord;

void main() {
#ifdef GENERATE_LUTS
    generate_LUTs(texcoord);
    float depth = texture(depthtex0, texcoord).x;
	if (depth == 1.0) {
	    color = vec4(0.0);
		return;
	}
#else
    float depth = texture(depthtex0, texcoord).x;
	if (depth == 1.0) {
	    color.rgb = pow(color.rgb, vec3(2.2)); // Inverse gamma correction
        color.rgb = vec3(1.0) - exp(-1.0 * getSkyColor(texcoord.xy) * 13);

        vec3 sunAndMoon = texture(colortex5, texcoord).rgb;
        if (sunAndMoon != vec3(0.0)) {
            vec3 directRadiance = getSunRadiance(texcoord.xy);
            if (directRadiance != vec3(0.0)) {
                color.rgb += sunAndMoon + directRadiance;
            }
        }
        color.a = 1.0;
		return;
	}
#endif

    vec4 albedo = texture(colortex0, texcoord);
	albedo.rgb = pow(albedo.rgb, vec3(2.2)); // Inverse gamma correction
    float ssao = texture(colortex3, texcoord).x;

	color = albedo;
	color.rgb = getSurfaceRadiance(texcoord, albedo.xyz);
    color.rgb *= ssao;
}
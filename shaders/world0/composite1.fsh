#version 460 compatibility

#include "/lib/globals.glsl"

#include "/lib/noise.glsl"
#include "/lib/spaceConversions.glsl"
#include "/lib/atmosphere/atmosphere.glsl"

#define FOG_DENSITY 5.0
#define FOG_START 15.0

uniform sampler2D colortex0;

uniform float far;
uniform vec3 fogColor;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);

	float depth = texture(depthtex0, texcoord).x;
	if (depth == 1.0) {
		return;
	}

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
    vec3 localPos = viewPosToLocalPos(viewPos);
    localPos /= 2;
    localPos.y = 0;

	float dist = max(0.0, (length(viewPos) - FOG_START)) / (far*0.65 - FOG_START);

    vec3 sun_angle = viewPosToLocalPos(normalize(sunPosition));
    sun_angle = normalize(sun_angle);
    vec3 camPos = vec3(0.0, height, 0.0);
    vec3 transmittance;
    vec3 inScatter = GetSkyRadianceToPoint(get_atmosphere(), transmittance_LUT, scattering_LUT, optional_mie_scattering_LUT, camPos, localPos + camPos, 0.0, sun_angle, transmittance);

	float fogFactor = exp(-FOG_DENSITY * (1.0 - dist));

	color.rgb = mix(color.rgb, color.rgb + inScatter, clamp(fogFactor-0.0065, 0.0, 1.0)); //I have literally no idea where this number 0.0065 came from I coded this a few weeks ago

}
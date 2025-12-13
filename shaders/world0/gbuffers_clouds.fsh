#version 460 compatibility

#include "/lib/globals.glsl"

uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 8 */
layout(location = 0) out vec4 color;

void main() {
	if (whiteWorld) {
		color = vec4(vec3(1.0), texture(gtexture, texcoord).w) * glcolor.a;
	}
	else {
		color = texture(gtexture, texcoord) * glcolor * glcolor.a;
	}
	if (color.a <= alphaTestRef) {
		discard;
	}
	color.rgb = pow(color.rgb, vec3(2.2)); // Inverse gamma correction
}
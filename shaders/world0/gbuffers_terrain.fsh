#version 460 compatibility

#include "/lib/globals.glsl"

uniform sampler2D gtexture;
uniform sampler2D specular;
uniform sampler2D normals;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;
flat in uint blockID;

/* RENDERTARGETS: 0,1,2,6,7 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;
layout(location = 3) out vec4 labpbrSpeculars;
layout(location = 4) out vec4 labpbrNormals;

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

	lightmapData = vec4(lmcoord, 0.0, 1.0);
	encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);
    
    labpbrSpeculars = texture(specular, texcoord);
    labpbrNormals = texture(normals, texcoord);

#ifndef MC_TEXTURE_FORMAT_LAB_PBR
    if (blockID == uint(2)) {
        labpbrSpeculars.z = 1.0;
    }
#endif
}
#version 460 compatibility

#include "/lib/materials/materials.glsl"

out vec2 texcoord;
out vec4 glcolor;


vec2 correctedLightmap(vec2 rawLightmap) {
    return (rawLightmap - 8) * (1.0/240.0);
}

void main() {
    gl_Position = ftransform();
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	glcolor = gl_Color;
}
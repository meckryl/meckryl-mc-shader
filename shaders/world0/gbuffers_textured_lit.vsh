#version 460 compatibility

out vec2 lmcoord;

out vec2 texcoord;
out vec4 glcolor; 
out vec3 normal;

uniform mat4 gbufferModelViewInverse;

vec2 correctedLightmap(vec2 rawLightmap) {
    return (rawLightmap - 8) * (1.0/240.0);
}

void main() {
	gl_Position = ftransform();

	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	lmcoord = correctedLightmap(gl_MultiTexCoord1.xy);

	glcolor = gl_Color;

	normal = gl_NormalMatrix * gl_Normal;
	normal = mat3(gbufferModelViewInverse) * normal;
}
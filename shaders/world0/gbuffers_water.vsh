#version 460 compatibility

#include "/lib/materials/materials.glsl"

out vec2 lmcoord;

out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
out float depth;
flat out uint blockID;


vec2 correctedLightmap(vec2 rawLightmap) {
    return (rawLightmap - 8) * (1.0/240.0);
}

void main() {
    gl_Position = ftransform();

    handleMaterialProperties();

    blockID = get_material_id();
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	lmcoord = correctedLightmap(gl_MultiTexCoord1.xy);
    normal = gl_NormalMatrix * normalize(gl_Normal); //View space
	normal = mat3(gbufferModelViewInverse) * normal; //Local space
    depth = gl_Position.z / gl_Position.w;

	glcolor = gl_Color;
}
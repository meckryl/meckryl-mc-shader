#version 460 compatibility

#define SHADOW_PASS

#include "/lib/globals.glsl"
#ifdef RTW_ENABLED
#include "/lib/RTW/warp.glsl"
#else
#include "/lib/distort.glsl"
#endif
#include "/lib/materials/materials.glsl"


#ifdef RTW_ENABLED
uniform sampler2D rtw_imap_smpl;
#endif

out vec2 texcoord;
out vec4 glcolor;

flat out uint blockID;

void main() {
    gl_Position = ftransform();

    handleMaterialProperties();

#ifdef RTW_ENABLED
    gl_Position.xy = mapPos(gl_Position.xyz, rtw_imap_smpl);
    gl_Position.z *= 0.5;
#else
    gl_Position.xyz = distortShadowClipPos(gl_Position.xyz);
#endif
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;

    blockID = get_material_id();
}
#version 460 compatibility

#include "/lib/globals.glsl"

uniform sampler2D gtexture;

uniform float alphaTestRef;

in geomData {
    vec2 texcoord;
    vec4 glcolor;
    flat uint blockID;
#ifdef SUBPIXEL_Y
    noperspective float trueY;
#endif
};

#ifdef SUBPIXEL_Y
/* RENDERTARGETS: 0,1 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 subPixelY;
#else
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;
#endif

void main() {
	color = texture(gtexture, texcoord) * glcolor;

	if (color.a < alphaTestRef || blockID == uint(3)) {
		discard;
	}

#ifdef SUBPIXEL_Y
    subPixelY = vec4(trueY * 0.5 + 0.5) * shadowMapResolution;
#endif
}
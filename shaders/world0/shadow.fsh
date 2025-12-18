#version 460 compatibility

#include "/lib/globals.glsl"

uniform sampler2D gtexture;

uniform float alphaTestRef;

in geomData {
    vec2 texcoord;
    vec4 glcolor;
    flat uint blockID;
    noperspective float trueY;
};

/* RENDERTARGETS: 0,1 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 subPixelY;

void main() {
	color = texture(gtexture, texcoord) * glcolor;

	if (color.a < alphaTestRef) {
		discard;
	}

    if (blockID == uint(3)) {
        discard;
    }

    subPixelY = vec4(trueY * 0.5 + 0.5) * shadowMapResolution;
}
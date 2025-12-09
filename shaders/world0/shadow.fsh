#version 460 compatibility

uniform sampler2D gtexture;

uniform float alphaTestRef;

in vec2 texcoord;
in vec4 glcolor;

flat in uint blockID;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(gtexture, texcoord) * glcolor;

	if (color.a < alphaTestRef) {
		discard;
	}

    if (blockID == uint(3)) {
        discard;
    }
}
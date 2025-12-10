#ifdef DEBUG

uniform sampler2D colortex0;
uniform sampler2D colortex15;

#include "/lib/globals.glsl"

uniform sampler2D rtw_imap_smpl;

in vec2 texcoord;

uniform bool is_sneaking;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    if (is_sneaking) {
        ivec2 texelPos = ivec2(texcoord * RTW_IMAP_RES);
        //texelPos.x += 2;
        color = texelFetch(rtw_imap_smpl, texelPos, 0);
        //color = texture(colortex15, texcoord);
    }
    else {
        color = texture(colortex0, texcoord);
    }
}

#else

void main() 

in vec2 texcoord;

uniform sampler2D colortex0;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;
{
    color = texture(colortex0, texcoord);
}

#endif
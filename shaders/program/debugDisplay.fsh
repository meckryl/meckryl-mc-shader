#define DEBUG

#ifdef DEBUG

uniform sampler2D colortex0;
uniform sampler2D shadowtex0;

#include "/lib/globals.glsl"

layout (r32ui) uniform restrict uimage2D rtw_imap;
uniform sampler2D rtw_imap_smpl;

in vec2 texcoord;

uniform bool is_sneaking;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    if (is_sneaking) {
        ivec2 texelPos = ivec2(texcoord * RTW_IMAP_RES);
        //texelPos.x += 2;
        color = imageLoad(rtw_imap, texelPos);
        //color.rgb = texture(rtw_imap_smpl, texcoord).rgb * 255.0;
        //color = texture(shadowtex0, texcoord) * 2.0 - 1.0;
    }
    else {
        color = texture(colortex0, texcoord);
    }
}

#else

in vec2 texcoord;

uniform sampler2D colortex0;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    color = texture(colortex0, texcoord);
}

#endif
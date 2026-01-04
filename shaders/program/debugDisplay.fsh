#include "/lib/globals.glsl"

#ifdef DEBUG

uniform sampler2D colortex0;
uniform sampler2D colortex9;
uniform sampler2D shadowtex0;
uniform sampler2D shadowcolor0;

uniform bool sameViewPos;

layout (r32ui) uniform restrict uimage2D rtw_imap;
uniform sampler2D rtw_imap_smpl;

in vec2 texcoord;

uniform bool is_sneaking;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void displayIMap() {
    ivec2 texelPos = ivec2(texcoord * RTW_IMAP_RES);
    if (!sameViewPos) {
        color.rgb = imageLoad(rtw_imap, texelPos).rgb / 100.0;
    }
    else {
        color.rgb = imageLoad(rtw_imap, texelPos).grb / 100.0;
    }
    color.a = 1.0;
}

void displayShadowTex() {
    ivec2 texelPos = ivec2(texcoord * screenSize * (2048.0 / viewHeight));
    if (texelPos.x >= 2048.0) {
        color = texture(colortex0, texcoord);
    }
    else {
        float shadow = texelFetch(shadowtex0, texelPos, 0).r;
        color.rgb = vec3(pow(shadow, 3.0));
        color.a = 1.0;
    }
}

void main() {
    if (is_sneaking) {
        //displayIMap();
        //displayShadowTex();
        //color.rgb = pow(texture(shadowcolor0, texcoord).rgb, vec3(2.2));
        color.rgb = texture(colortex9, texcoord).rgb * texture(colortex9, texcoord).a;
        color.a = 1.0;
        
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
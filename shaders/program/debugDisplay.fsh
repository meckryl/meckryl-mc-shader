#include "/lib/globals.glsl"

#ifdef DEBUG

uniform sampler2D colortex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowcolor1;



layout (r32ui) uniform restrict uimage2D rtw_imap;
uniform sampler2D rtw_imap_smpl;

in vec2 texcoord;

uniform bool is_sneaking;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void displayIMap() {
    ivec2 texelPos = ivec2(texcoord * RTW_IMAP_RES);
    color.rgb = imageLoad(rtw_imap, texelPos).rgb;
    color.a = 1.0;
}

void displayShadowTex() {
    float shadow = texture(shadowtex0, texcoord).r;
    color.rgb = vec3(pow(shadow, 3.0));
    color.a = 1.0;
}

void main() {
    if (is_sneaking) {
        displayIMap();
        //displayShadowTex();
        //color.rgb = texture(shadowcolor1, texcoord).rgb * 0.5 / shadowMapResolution;
        
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
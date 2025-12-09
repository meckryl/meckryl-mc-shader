#version 460 compatibility

uniform sampler2D gtexture;

uniform int renderStage;

in vec2 texcoord;

/* RENDERTARGETS: 5 */
layout(location = 0) out vec4 color;

void main() {
    vec2 offset;
    if (renderStage == MC_RENDER_STAGE_SUN){
        offset = texcoord * 2.0 - 1.0;
    }
    else {
        offset = fract(vec2(4.0, 2.0) * texcoord);
        offset = offset * 2.0 - 1.0;
    }
    if (max(abs(offset.x), abs(offset.y)) > 0.25) discard;
    vec4 sampledColor = texture(gtexture, texcoord);
    color = sampledColor;
}
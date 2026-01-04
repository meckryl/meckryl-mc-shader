#version 460 compatibility

uniform sampler2D colortex0;

in vec2 texcoord;

/* RENDERTARGETS: 9 */
layout(location = 0) out vec4 bloom;

const float bloom_cutoff = 1.2;

void main() {
    vec4 sampledColor = texture(colortex0, texcoord);
    
    if (length(sampledColor.rgb) < bloom_cutoff){
        bloom = vec4(0.0, 0.0, 0.0, 1.0);
    }
    else {
        bloom = sampledColor;
    }
}
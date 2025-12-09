#version 460 compatibility

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

uniform sampler2D colortex0; //Opaque scene
uniform sampler2D colortex8; //Translucent scene

void main() {
    vec4 colorOpaque = texture(colortex0, texcoord);
    vec4 colorTranslucent = texture(colortex8, texcoord);
    float alpha = colorTranslucent.a;
    color.rgb = colorOpaque.rgb * (1 - alpha) + colorTranslucent.rgb * alpha;
    color.a = 1.0;
}
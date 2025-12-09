#version 460 compatibility

#include "/lib/globals.glsl"

in vec2 texcoord;

layout (r32f) uniform image2D rtw_imap;

void main() {
    ivec2 texelPos = ivec2(texcoord * screenSize);
    if (texelPos.x != clamp(texelPos.x, 0.0, 1.0) || texelPos.y != clamp(texelPos.y, 1.0, RTW_IMAP_RES - 2.0)) discard;

    const float blur_radius = 2.0;

    float sum = 0.0;
    for (int i = 0; i < 1.0 + blur_radius * 2.0; i++){
        ivec2 currentTexel = texelPos;
        currentTexel.y += i - int(blur_radius);

        sum += imageLoad(rtw_imap, currentTexel).x;
    }

    sum /= 1.0 + blur_radius * 2.0;

    imageStore(rtw_imap, texelPos + ivec2(2, 0), vec4(sum));
}
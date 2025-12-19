#version 460 compatibility

#include "/lib/spaceConversions.glsl"

uniform vec3 sunPosition;
uniform vec3 moonPosition;

out vec2 texcoord;
out float isSun;

void main() {
    vec4 clipPos = ftransform();
    
    const float scale = 0.5;

    vec3 viewPos = clipPosToViewPos(clipPos); 
    float deltaDistance = distance(viewPos, moonPosition) - distance(viewPos, sunPosition);
    isSun = deltaDistance;
    vec3 center = (isSun >= 0.0) ? sunPosition : moonPosition;
    center = viewPosToLocalPos(center);

    vec3 offset = viewPosToLocalPos(viewPos) - center;
    offset *= scale;
    vec3 scaledViewPos = localPosToViewPos(center + offset);

    vec4 scaledClipPos = viewPosToClipPos(scaledViewPos);

    gl_Position = scaledClipPos;
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
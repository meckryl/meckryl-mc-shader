#include "/lib/noise.glsl"

attribute vec2 mc_midTexCoord;
uniform float frameTimeCounter;

#ifndef SHADOW_PASS
vec3 modelPosToWorldPos(vec3 modelPos) {
    vec3 position = modelPos;
    position = modelPosToViewPos(position);
    position = viewPosToLocalPos(position);
    position = localPosToWorldPos(position);
    return position;
}

vec4 worldPosToClipPos(vec3 worldPos) {
    vec3 position = worldPos;
    position = worldPosToLocalPos(position);
    position = localPosToViewPos(position);
    return viewPosToClipPos(position);
}
#else
vec3 modelPosToWorldPos(vec3 modelPos) {
    vec3 position = modelPos;
    position = modelPosToViewPos(position);
    position = sViewPosToLocalPos(position);
    position = localPosToWorldPos(position);
    return position;
}

vec4 worldPosToClipPos(vec3 worldPos) {
    vec3 position = worldPos;
    position = worldPosToLocalPos(position);
    position = localPosToSViewPos(position);
    return gl_ProjectionMatrix * vec4(position, 1.0);
}
#endif

vec3 wiggleBlock(vec3 worldPos, float amplitude, float frequency, float speed) {
    float offset = amplitude * sin(worldPos.y * frequency + frameTimeCounter * speed);
    vec3 wiggleOffset = vec3(offset, 0.0, -1.0 * offset);
    return wiggleOffset;
}

vec3 waveBlock(vec3 worldPos, bool isFixed) {
    if (isFixed) {
        return vec3(0.0);
    }

    float windAngle = radians(30.0);
    vec2 wind = vec2(cos(windAngle), sin(windAngle));
    vec3 windDisplacement = vec3(wind, 0.0).xzy;

    float timeFactor = frameTimeCounter * 0.5; // Wind blows roughly 2 blocks per second

    float windRandCycle = samplePN(worldPos.xz/8.0 + wind * timeFactor, timeFactor * 0.0);
    windRandCycle += 0.2; // Blocks sway back and forth, but have a preffered direction

    windDisplacement *= windRandCycle;

    vec3 waveOffset = vec3(0.0);
    waveOffset += windDisplacement * 0.5;
    return waveOffset;
}

bool isTopVertex() {
    return gl_MultiTexCoord0.y < mc_midTexCoord.y;
}

vec3 waterWave(vec3 worldPos) {
    float waveHeight = 0.08 * sin(frameTimeCounter);
    return vec3(0.0, waveHeight - 0.1, 0.0);
}

void doWave(uint material) {
    vec3 offset = vec3(0.0);
    vec3 worldPos = modelPosToWorldPos(gl_Vertex.xyz);

    switch (material) {
        case uint(1): //Leaves
            offset += waveBlock(worldPos, false) * 0.5;
            offset += wiggleBlock(worldPos, blockWaveAmp, blockWaveFreq, blockWaveSpeed * 1.5) * 0.5;
            break;
        case uint(2): //Short plants
            offset += waveBlock(worldPos, !isTopVertex());
            break;
        case uint(3): //Water
            offset += waterWave(worldPos);
            break;
        default:
            return;
    }

    worldPos += offset;
    gl_Position = worldPosToClipPos(worldPos);
}
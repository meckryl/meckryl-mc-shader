#include "/settings.glsl"
#include "/lib/bufferSettings.glsl"

#ifndef GLOBALS_INCLUDED
#define GLOBALS_INCLUDED

#include "/lib/math.glsl"

uniform float viewWidth;
uniform float viewHeight;

const float PI = 3.14159265358979323846;
const float TAU = PI * 2;
const float GoldenAngle = PI * (3.0 - sqrt(5.0));

//const bool shadowHardwareFiltering = true;

const vec3 ambientColor = vec3(AMBIENT_R, AMBIENT_G, AMBIENT_B);
const vec3 skylightColor = vec3(SKY_R, SKY_G, SKY_B);
const vec3 blocklightColor = vec3(BLOCK_R, BLOCK_G, BLOCK_B);
const vec3 sunlightColor = vec3(SUN_R, SUN_G, SUN_B);
const vec3 moonlightColor = vec3(MOON_R, MOON_G, MOON_B);

const float ambientStrength = AMBIENT_I;
const float skylightStrength = SKY_I;
const float blocklightStrength = BLOCK_I;
const float sunlightStrength = SUN_I;
const float moonlightStrength = MOON_I;

const float blockWaveAmp = 0.03;
const float blockWaveFreq = 1.0;
const float blockWaveSpeed = 1.0;

const float shadowDistance = 206.0;
const int shadowMapResolution = 2048;
const float shadowIntervalSize = 1.0;
const bool shadowHardwareFiltering = false;

#ifdef VANILLA_AO
    const float ambientOcclusionLevel = 0.7;
#else
    const float ambientOcclusionLevel = 0.0;
#endif

#ifdef WHITE_WORLD
	const bool whiteWorld = true;
#else
	const bool whiteWorld = false;
#endif

float clamp01(float n) {
    return clamp(n, 0.0, 1.0);
}

#define screenSize vec2(viewWidth, viewHeight)

#endif
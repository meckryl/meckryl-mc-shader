#version 460 compatibility

#include "/lib/globals.glsl"
#include "/lib/noise.glsl"
#include "/lib/spaceConversions.glsl"

#define SSAO_SAMPLES 16.0
#define SSAO_RADIUS 2.0
#define SSAO_STRENGTH 1.5

uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D colortex3;


uniform int frameCounter;

in vec2 texcoord;

/* RENDERTARGETS: 0,3 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 ssao;


float lerp(float a, float b, float f) {
    return a + f * (b - a);
}

vec3 getKerenelSample(uint i, vec2 seed) {
    vec3 ksample = sampleWNTexel(ivec2(seed * screenSize + vec2(1.0-i, 1.0-i))).xyz;

    // Thank you to @Builderb0y for this method of finding a random unit vector
    float x = ksample.x * 2.0 - 1.0;
    float y = ksample.y * TAU;
    float r = sqrt(1.0 - x * x);
    ksample = vec3(cos(y) * r, sin(y) * r, x);
    
    float scale = float(i) / SSAO_SAMPLES;
    scale = lerp(0.1, 1.0, scale*scale);
    ksample *= scale;
    ksample.z = abs(ksample.z);

    return ksample;
}

float sampleSSAO(vec3 fragViewPos, vec3 fragViewNormal) {
    vec3 noise = vec3(sampleWNTexel(ivec2(texcoord * screenSize*(frameCounter % 200 + 1.0))).xy * 2.0 - 1.0, 0.0);

	vec3 tangent = normalize(noise - fragViewNormal * dot(noise, fragViewNormal));
    vec3 bitangent = cross(fragViewNormal, tangent);
    mat3 TBN = mat3(tangent, bitangent, fragViewNormal);

    float occlusion = 0.0;
    for (int i = 0; i < SSAO_SAMPLES; i++) {
        vec3 kernelSample = getKerenelSample(uint(i), fragViewPos.xy*(frameCounter % 200 + 1.0));
        vec3 sampleViewPos = TBN * kernelSample; //View space
        sampleViewPos = fragViewPos + sampleViewPos * SSAO_RADIUS;

        vec4 sampleClipPos = viewPosToClipPos(sampleViewPos);
        vec3 sampleScreenPos = sampleClipPos.xyz / sampleClipPos.w;
        sampleScreenPos = sampleScreenPos * 0.5 + 0.5; //Screen space

        float sampleDepth = texture(depthtex0, sampleScreenPos.xy).x;
        if (sampleDepth < 0.56) continue;
        sampleDepth = sampleDepth * 2.0 - 1.0;
        sampleDepth = gbufferProjectionInverse[3].z / (gbufferProjectionInverse[2].w * sampleDepth + gbufferProjectionInverse[3].w);

        float rangeCheck = smoothstep(0.0, 1.0, SSAO_RADIUS / abs(sampleViewPos.z - sampleDepth));

        occlusion += step(sampleViewPos.z, sampleDepth) * rangeCheck;
    }
    occlusion = (occlusion / (SSAO_SAMPLES));
    return pow(occlusion, 1.0);
}

void main() {
    //texcoord is screen space
    color = texture(colortex0, texcoord);
    ssao = texture(colortex3, texcoord);

    float depth = texture(depthtex0, texcoord).x;
	if (depth == 1.0) {
        ssao.w = 1.0;
        ssao.z = 0.0;
        ssao.y = 1.0;
		return;
	}
    #ifdef SSAO
        vec3 fragPos = vec3(texcoord, depth); //Screen space
        fragPos = fragPos * 2.0 - 1.0; //NDC space
        fragPos = ndcPosToViewPos(fragPos); //View space

        vec3 encodedNormal = texture(colortex2, texcoord).xyz;
        vec3 normal = localPosToViewPos(encodedNormal * 2.0 - 1.0);

        float occlusion = lerp(0.0, 1.0, pow(1.0 - sampleSSAO(fragPos, normal), SSAO_STRENGTH));
    #else
        float occlusion = 1.0;
    #endif

    ssao.w = occlusion;
}
// Handle lighting from sources in the sky

#include "/lib/globals.glsl"
#ifdef RTW_ENABLED
#include "/lib/RTW/warp.glsl"
#else
#include "/lib/distort.glsl"
#endif
#include "/lib/noise.glsl"

uniform sampler2D colortex1;
uniform sampler2D colortex2;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

#ifdef RTW_ENABLED
uniform sampler2D rtw_imap_smpl;
#endif

uniform vec3 shadowLightPosition;

uniform int worldTime;

uniform float far;

vec3 fragCoord;

vec3 getMainLightDirection() {
    vec3 lightVector = normalize(shadowLightPosition);
	return normalize(mat3(gbufferModelViewInverse) * lightVector);
}

vec4 screenPosToShadowClipPos(vec3 screenPos, vec3 normal) {
    float depth = screenPos.z;
    if (depth < 0.56) {
        depth  = depth * 2.0 - 1.0;
		depth *= 1.0 / MC_HAND_DEPTH;
		depth  = depth * 0.5 + 0.5;
    }
    screenPos.z = depth;
	vec3 bias = 0.5 * normal;
    float biasWeight = clamp01(dot(normal, -getMainLightDirection()));

	vec3 NDCPos = screenPos * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

    bias *= vec3(max((1.0 - biasWeight) * length(feetPlayerPos.xz) * 0.01, 0.15)) * 1.0;
    feetPlayerPos += bias;

	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);

	return shadowClipPos;
}

vec2 getVogelPoint(int sampleIndex, int samplesCount, float radius) {
	float r = sqrt(float(sampleIndex) + 0.5) / sqrt(float(samplesCount));
	float theta = float(sampleIndex) * GoldenAngle;
	return r * vec2(cos(theta), sin(theta)) * radius;
}

float getSunFactor() {
	if (worldTime < 12000) {
		// Daytime
		return 1.0;
	}
	else if (worldTime > 13500 && worldTime < 22500) {
		return 0.0;
	}
	else if (worldTime <= 13500) {
		float timeFactor = (worldTime - 12000.0)/1500.0;
		return mix(1.0, 0.0, timeFactor);
	}
	else {
		float timeFactor = (worldTime - 22500.0)/1500.0;
		return mix(0.0, 1.0, timeFactor);
	}
}

vec3 getMainColor() {
	return mix(moonlightColor, sunlightColor, getSunFactor());
}

float getMainStrength() {
	return mix(moonlightStrength, sunlightStrength, getSunFactor());
}

float getSkyStrength() {
	return mix(0.1, skylightStrength, getSunFactor());
}

vec3 getShadowNormal(vec3 shadowScreenPos) {
	vec3 shadowEncodedNormal = texture(shadowcolor1, shadowScreenPos.xy).xyz;
	vec3 shadowNormal = normalize((shadowEncodedNormal - 0.5) * 2.0);
	return shadowNormal;
}

vec3 getMainLight(vec3 shadowScreenPos) {
    float shadow0 = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r);
	if(shadow0 == 1.0){
		return vec3(1.0);
	}

    float shadow1 = step(shadowScreenPos.z, texture(shadowtex1, shadowScreenPos.xy).r);
	if(shadow1 == 0.0){
		return vec3(0.0);
	}

	vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);
	return shadowColor.rgb * (1.0 - shadowColor.a);

}

vec3 getSoftShadow(vec4 shadowClipPos, vec2 texcoord, float dist) {
	ivec2 screenCoord = ivec2(texcoord * screenSize);
	float noise = sampleWNTexel(screenCoord).r;

    float theta = noise * radians(360.0); // random angle using noise value
    float cosTheta = cos(theta);
    float sinTheta = sin(theta);

    mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta);

	vec3 shadowAccum = vec3(0.0);

    //vec3 tangent = normalize(cross(normal, vec3(0, 1, 1)));
    //mat3 TBN = mat3(tangent, cross(normal, tangent), normal);

	for(int i = 0; i < SHADOW_SAMPLES; i++) {
		//vec3 sampleOffset = vec3(getVogelPoint(i, SHADOW_SAMPLES, SHADOW_RADIUS * clamp(dist/4.0, 1.0, 25.0)) * rotation, 0.0);
        //sampleOffset = TBN * sampleOffset;
        vec2 sampleOffset = getVogelPoint(i, SHADOW_SAMPLES, SHADOW_RADIUS) * rotation;
		sampleOffset /= shadowMapResolution;
		vec4 offsetShadowClipPos = shadowClipPos + vec4(sampleOffset, 0.0, 0.0);
#ifdef RTW_ENABLED
        offsetShadowClipPos.xy = mapPos(offsetShadowClipPos.xyz, rtw_imap_smpl);
        offsetShadowClipPos.z *= 0.5;
#else
        offsetShadowClipPos.xyz = distortShadowClipPos(offsetShadowClipPos.xyz);
#endif
		vec3 shadowNDCPos = offsetShadowClipPos.xyz / offsetShadowClipPos.w;
		vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;
		shadowAccum += getMainLight(shadowScreenPos);
	}

	return shadowAccum / SHADOW_SAMPLES;
}

vec4 getLightVector(vec3 screenPos) {
	fragCoord = screenPos.xyz;
	vec2 texcoord = fragCoord.xy;

	vec2 lightmap = texture(colortex1, texcoord).xy;
	vec3 encodedNormal = texture(colortex2, texcoord).xyz;

	vec3 normal = normalize((encodedNormal - 0.5) * 2.0);

    float ambient = ambientStrength;
	float skylight = lightmap.y * getSkyStrength();
	float blocklight = lightmap.x * blocklightStrength;

	float mainlight = getMainStrength();

	return vec4(mainlight, skylight, blocklight, ambient);
}
#include "/lib/globals.glsl"

#ifndef CONVERSIONS_INCLUDED
#define CONVERSIONS_INCLUDED
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;

uniform sampler2D depthtex0;
uniform vec3 cameraPosition;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
	vec4 homogenousPosition = projectionMatrix * vec4(position, 1.0);
	return homogenousPosition.xyz / homogenousPosition.w;
}

vec3 modelPosToViewPos(vec3 modelPos) {
    return (gl_ModelViewMatrix * vec4(modelPos, 1.0)).xyz;
}

vec3 clipPosToViewPos(vec4 clipPos) {
    return (gbufferProjectionInverse * clipPos).xyz;
}

vec4 viewPosToClipPos(vec3 viewPos) {
    return (gbufferProjection * vec4(viewPos, 1.0));
}

vec3 sClipPosToSViewPos(vec4 shadowClipPos) {
    return (gbufferProjectionInverse * shadowClipPos).xyz;
}

vec4 sViewPosToSClipPos(vec3 shadowViewPos) {
    return (gbufferProjection * vec4(shadowViewPos, 1.0));
}

vec3 viewPosToLocalPos(vec3 viewPos) {
    return (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
}

vec3 localPosToViewPos(vec3 localPos) {
    return (gbufferModelView * vec4(localPos, 1.0)).xyz;
}

vec3 sViewPosToLocalPos(vec3 viewPos) {
    return (shadowModelViewInverse * vec4(viewPos, 1.0)).xyz;
}

vec3 localPosToSViewPos(vec3 localPos) {
    return (shadowModelView * vec4(localPos, 1.0)).xyz;
}

vec3 localPosToWorldPos(vec3 localPos) {
    return localPos + cameraPosition;
}

vec3 worldPosToLocalPos(vec3 worldPos) {
    return worldPos - cameraPosition;
}

vec3 ndcPosToViewPos(vec3 ndcPos) {
    return projectAndDivide(gbufferProjectionInverse, ndcPos);
}

vec3 viewPosToNDCPos(vec3 viewPos) {
    return projectAndDivide(gbufferProjection, viewPos);
}

vec3 sViewPosToSNDCPos(vec3 viewPos) {
    return projectAndDivide(shadowProjection, viewPos);
}

vec3 sNDCPosToSViewPos(vec3 ndcPos) {
    return projectAndDivide(shadowProjectionInverse, ndcPos);
}

#endif
#version 460 compatibility

#include "/lib/globals.glsl"
#include "/lib/spaceConversions.glsl"

uniform sampler2D colortex3; //AO Information for the current frame
uniform sampler2D colortex4; //Stores the last frame depth

uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;

uniform int frameCounter;
uniform vec3 previousCameraPosition;

in vec2 texcoord;

/* RENDERTARGETS: 3,4*/
layout(location = 0) out vec4 ao;
layout(location = 1) out float depthRecord;



vec3 screenPosToViewPos(vec3 screenPos) {
    vec3 result = screenPos * 2.0 - 1.0;
    result = ndcPosToViewPos(result);
    return result;
}

vec3 viewPosToScreenPos(vec3 viewPos) {
    vec3 result = projectAndDivide(gbufferPreviousProjection, viewPos);
    result = result * 0.5 + 0.5;
    return result;
}


/*AO Data: 
x: The result of the previous temporalBlur call at this location in screen space
y: The depth of this location in screen space
z: The number of pixels that have been averaged into this location
w: The result of the most recent SSAO sample
*/ 
vec4 temporalBlur() {
    vec4 aoData = texture(colortex3, texcoord);
    float depth = texture(depthtex0, texcoord).x;

    if (frameCounter <= 1.0) {
        return vec4(aoData.w, depth, 0.0, aoData.w);
    }

    vec3 camPosDelta = cameraPosition - previousCameraPosition;

    vec3 viewPos = screenPosToViewPos(vec3(texcoord, depth));
    vec3 localPos = viewPosToLocalPos(viewPos);
    vec3 prevViewPos = (gbufferPreviousModelView * vec4(localPos + camPosDelta, 1.0)).xyz;

    vec3 prevScreenPos = viewPosToScreenPos(prevViewPos);

    if (clamp(prevScreenPos.xy, 0.0, 1.0) != prevScreenPos.xy) {
        return vec4(aoData.w, depth, 0.0, aoData.w);
    }

    vec4 prevAOData = texture(colortex3, prevScreenPos.xy);
    float prevDepth = texture(colortex4, prevScreenPos.xy).x;
    float prevAge = prevAOData.z * 255.0;

    vec3 temporalPos = screenPosToViewPos(vec3(prevScreenPos.xy, prevDepth));

    float delta = distance(prevViewPos, temporalPos) * 20.0;

    float aoWeight = prevAge;
    float averagedAO = aoData.w;
    float distanceRejection = 1.0 - delta / (delta + 1.0);
    float contributions = 1.0;
    averagedAO += prevAOData.x * aoWeight * distanceRejection;
    contributions += aoWeight * distanceRejection;
    
    float blurredAO = averagedAO / contributions;
    
    return vec4(blurredAO, depth, min(contributions, 10)/255.0, distanceRejection);
}

void main() {
    ao = temporalBlur();
    depthRecord = texture(depthtex0, texcoord).x;
}
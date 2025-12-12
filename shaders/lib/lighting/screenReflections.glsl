#include "/lib/spaceConversions.glsl"

bool fragOnScreen(vec2 fragPos) {
    return (fragPos.x >= 0 && fragPos.y >= 0) && (fragPos.x < viewWidth && fragPos.y < viewHeight);
}

float interpolateZ(float zStart, float zEnd, float s) {
    float inverse = (1.0/zStart) + s * (1.0/zEnd - 1.0/zStart);
    return 1.0/inverse;
}

vec4 getReflectedColor(vec3 screenPos, vec3 surfaceNorm, sampler2D screenSampler, sampler2D depthSampler, sampler2D normalSampler, out vec2 hitPos, out bool hitSky) {
    vec3 viewPos = ndcPosToViewPos(screenPos * 2.0 - 1.0);
    float localDist = -viewPos.z;

    hitPos = vec2(-1, -1);

    bool hit0 = false;
    bool hit1 = false;
    bool screenEdge = false;
    hitSky = false;

    const float maximumDepth = 100;
    const float resolution = 0.2;
    const int scanSteps = 10;
    const int refinementSteps = 15;
    const float bias = 0.3;

    if (localDist >= (500.0)) return vec4(-1);

    vec3 vsurfaceNorm = localPosToViewPos(surfaceNorm);

    vec3 incidence = normalize(viewPos);
    vec3 ray = normalize(reflect(incidence, normalize(vsurfaceNorm)));

    ray *= maximumDepth;
    vec3 endPos = ray + viewPos;
    float endDist = -endPos.z;

    vec3 startFrag = screenPos * vec3(screenSize, 1.0);
    vec3 endFrag = viewPosToNDCPos(endPos);
    endFrag = ((endFrag * 0.5) + 0.5) * vec3(screenSize, 1.0);

    vec2 deltas = endFrag.xy - startFrag.xy;
    bool useX = abs(deltas.x) > abs(deltas.y);
    float delta = ((useX) ? abs(deltas.x) : abs(deltas.y)) * resolution;
    vec2 increment = deltas / max(delta, 0.1);

    if (length(increment) < 1.0) increment *= 2.0;
    if (length(increment) < 1.0) return vec4(-1);

    vec2 lastHit = vec2(-1, -1);
    float lastMiss = 0;
    float s = 0;

    vec2 currentFrag = startFrag.xy;
    float sampleDepth;
    float terrainDepth;
    float deltaDepth;

    for (int i = 1; i <= int(delta); ++i) {
        currentFrag += increment;

        //s = pow2(i / float(scanSteps));
        //s = i / float(scanSteps);

        
        if (!fragOnScreen(currentFrag)){
            screenEdge = true;
            break;
        }
        s = useX ? (currentFrag.x - startFrag.x) / deltas.x : (currentFrag.y - startFrag.y) / deltas.y;

        sampleDepth = (localDist * endDist) / mix(endDist, localDist, s);
        terrainDepth = texelFetch(depthSampler, ivec2(currentFrag), 0).x;
        terrainDepth = -(ndcPosToViewPos(vec3(currentFrag/screenSize, terrainDepth) * 2.0 - 1.0).z);
        vec3 terrainNorm = texelFetch(normalSampler, ivec2(currentFrag), 0).xyz * 2.0 - 1.0;

        deltaDepth = sampleDepth - terrainDepth;

        if (deltaDepth > 0 && deltaDepth < bias * max((sampleDepth - localDist), 3.0) * (1.0 - clamp01(dot(surfaceNorm, terrainNorm)))) {
            hit0 = true;
            break;
        }

        lastMiss = s;
    }
    if (!hit0 && !screenEdge) {
        hitPos = currentFrag / screenSize;
        lastHit = currentFrag;
        hitSky = true;
    }
    else if (screenEdge){
        return vec4(-1.0);
    }

    if (hit0) {
    
        s = (s + lastMiss) / 2.0;


        for (int i = 0; i < refinementSteps; ++i) {
            currentFrag = mix(startFrag.xy, endFrag.xy, s);

            //sampleDepth = interpolateZ(localDist, endDist, s);
            sampleDepth = (localDist * endDist) / mix(endDist, localDist, s);
            terrainDepth = texelFetch(depthSampler, ivec2(currentFrag), 0).x;
            terrainDepth = -ndcPosToViewPos(vec3(currentFrag/screenSize, terrainDepth) * 2.0 - 1.0).z;
            vec3 terrainNorm = texelFetch(normalSampler, ivec2(currentFrag), 0).xyz * 2.0 - 1.0;

            deltaDepth = sampleDepth - terrainDepth;

            if (deltaDepth > 0 && deltaDepth < bias * max((sampleDepth - localDist), 1.0) * (1.0 - clamp01(dot(surfaceNorm, terrainNorm)))) {
                hit1 = true;
                lastHit = currentFrag;
                s = (s + lastMiss) / 2.0;
                //break;
            }
            else {
                float temp = s;
                s = (3.0 * s - lastMiss) / 2.0;
                lastMiss = temp;
            }
        }
    }
    currentFrag = lastHit;

    float edgeProximityX = clamp01(1.0 - abs(currentFrag.x/viewWidth - 0.5) * 2.0);
    float edgeProximityY = clamp01(1.0 - abs(currentFrag.y/viewHeight - 0.5) * 2.0);
    float edgeProximity = clamp01(min(edgeProximityX, edgeProximityY) * 2.0);

    float visibility = edgeProximity;

    if (hitSky || !hit1) return vec4(-1, -1, -1, visibility);
    return vec4(texelFetch(screenSampler, ivec2(currentFrag), 0).rgb, visibility);
}
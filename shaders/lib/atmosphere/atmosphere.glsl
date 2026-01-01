#include "/lib/math.glsl"

#ifndef ATMOSPHERE_INCLUDED
#define ATMOSPHERE_INCLUDED

uniform vec3 sunPosition;
uniform int frameCounter;

#ifdef GENERATE_LUTS

#include "/lib/atmosphere/generate_LUT.glsl"

#else

#include "/lib/atmosphere/brunetonMappingFunctions.glsl"
uniform sampler2D transmittance_LUT;
uniform sampler3D scattering_LUT;
uniform sampler3D optional_mie_scattering_LUT;
uniform sampler2D irradiance_LUT;

#endif

// Physically based skybox based on: https://ebruneton.github.io/precomputed_atmospheric_scattering/

#ifndef GENERATE_LUTS
const float height = 6361;

vec3 getSkyColor(vec2 screenCoord) {
    float depth = 1.0;
    vec3 screen_pos = vec3(screenCoord, depth);
    vec3 view_pos = ndcPosToViewPos(screen_pos * 2.0 - 1.0);
    vec3 local_pos = normalize(viewPosToLocalPos(view_pos));
    vec3 sun_angle = viewPosToLocalPos(normalize(sunPosition));
    sun_angle = normalize(sun_angle);

    vec3 camPosition = vec3(0.0, height, 0.0);

    AtmosphereParameters atmosphere = get_atmosphere();
    vec3 transmittance;
    vec3 sky = GetSkyRadiance(atmosphere, transmittance_LUT, scattering_LUT, optional_mie_scattering_LUT, camPosition, local_pos, 0.0, sun_angle, transmittance);

    float PoV = dot(camPosition, local_pos);
    float mu = PoV / height;

    vec3 groundRadiance = vec3(0.0);
    if (RayIntersectsGround(atmosphere, height, mu)){
        float distanceToGround = 1.0 / local_pos.y;
        vec3 point = camPosition - local_pos * distanceToGround;
        vec3 normal = vec3(0.0, 1.0, 0.0);

        vec3 skyIrradiance;
        vec3 sunIrradiance = GetSunAndSkyIrradiance(atmosphere, transmittance_LUT, irradiance_LUT, point, normal, sun_angle, skyIrradiance);
        groundRadiance = vec3(0.1) * (1.0/PI) * (sunIrradiance + skyIrradiance);

        vec3 transmittance;
        vec3 inScatter = GetSkyRadianceToPoint(atmosphere, transmittance_LUT, scattering_LUT, optional_mie_scattering_LUT, camPosition, point, 0.0, sun_angle, transmittance);
        groundRadiance = groundRadiance * transmittance + inScatter;
    }

    //vec3 sky = vec3(0.0);
    return sky + groundRadiance;
}

vec3 getSkyColor(vec3 viewRay) {
    vec3 local_pos = normalize(viewPosToLocalPos(viewRay));
    vec3 sun_angle = viewPosToLocalPos(normalize(sunPosition));
    sun_angle = normalize(sun_angle);

    vec3 camPosition = vec3(0.0, height, 0.0);

    AtmosphereParameters atmosphere = get_atmosphere();
    vec3 transmittance;
    vec3 sky = GetSkyRadiance(atmosphere, transmittance_LUT, scattering_LUT, optional_mie_scattering_LUT, camPosition, local_pos, 0.0, sun_angle, transmittance);

    float PoV = dot(camPosition, local_pos);
    float mu = PoV / height;

    vec3 groundRadiance = vec3(0.0);
    if (RayIntersectsGround(atmosphere, height, mu)){
        float distanceToGround = 1.0 / local_pos.y;
        vec3 point = camPosition - local_pos * distanceToGround;
        vec3 normal = vec3(0.0, 1.0, 0.0);

        vec3 skyIrradiance;
        vec3 sunIrradiance = GetSunAndSkyIrradiance(atmosphere, transmittance_LUT, irradiance_LUT, point, normal, sun_angle, skyIrradiance);
        groundRadiance = vec3(0.1) * (1.0/PI) * (sunIrradiance + skyIrradiance);

        vec3 transmittance;
        vec3 inScatter = GetSkyRadianceToPoint(atmosphere, transmittance_LUT, scattering_LUT, optional_mie_scattering_LUT, camPosition, point, 0.0, sun_angle, transmittance);
        groundRadiance = groundRadiance * transmittance + inScatter;
    }

    return sky + groundRadiance;
}

vec3 getSunRadiance(vec2 screenCoord) {
    float depth = 1.0;
    vec3 screen_pos = vec3(screenCoord, depth);
    vec3 view_pos = ndcPosToViewPos(screen_pos * 2.0 - 1.0);
    vec3 viewDirection = normalize(viewPosToLocalPos(view_pos));

    float height = height;
    vec3 camPos = vec3(0.0, height, 0.0);

    float rmu = dot(camPos, viewDirection);
    float mu = rmu / height;

    AtmosphereParameters atmosphere = get_atmosphere();
    //return atmosphere.solar_irradiance;

    if (RayIntersectsGround(atmosphere, height, mu)) return vec3(0.0);

    vec3 transmittance = GetTransmittanceToTopAtmosphereBoundary(atmosphere, transmittance_LUT, height, mu);
    
    return transmittance * atmosphere.solar_irradiance * 1e2;
}

vec3 getSunRadiance(vec3 viewDirection) {
    float height = height;
    vec3 camPos = vec3(0.0, height, 0.0);
    float rmu = dot(camPos, viewDirection);
    float mu = rmu / height;

    AtmosphereParameters atmosphere = get_atmosphere();

    if (RayIntersectsGround(atmosphere, height, mu)) return vec3(0.0);

    vec3 transmittance = GetTransmittanceToTopAtmosphereBoundary(atmosphere, transmittance_LUT, height, mu);
    
    return transmittance * atmosphere.solar_irradiance;
}
#endif

#endif

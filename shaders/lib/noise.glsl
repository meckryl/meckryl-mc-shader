uniform sampler2D noisetex;

vec4 sampleWNTexel(ivec2 coord) {
	return texelFetch(noisetex, coord % 64, 0);
}

vec4 sampleWN(vec2 coord) {
    return texture(noisetex, coord);
}

//Pseudo 3d perlin noise by Luke Rissacher: https://www.shadertoy.com/view/MtcGRl
vec2 gradient(ivec2 intPos, float t) {
    float rand = texture(noisetex, intPos / 64.0).x;
    float angle = TAU * rand + 4.0 * t * rand;
    return vec2(cos(angle), sin(angle));
}

float mixGradient(vec2 pos, ivec2 a, ivec2 b, float t, float blend) {
    ivec2 i = ivec2(floor(pos.xy));
    vec2 f = fract(pos);
    vec2 gradientA = gradient(i + a, t);
    vec2 gradientB = gradient(i + b, t);
    return mix(dot(gradientA, f - a), dot(gradientB, f - b), blend);
}

float samplePN(vec2 pos, float t) {
    vec2 f = fract(pos);
    vec2 blend = f * f * (3.0 - 2.0 * f);

    float mixture_A = mixGradient(pos, ivec2(0, 0), ivec2(1, 0), t, blend.x);
    float mixture_B = mixGradient(pos, ivec2(0, 1), ivec2(1, 1), t, blend.x);

    float noiseVal = mix(mixture_A, mixture_B, blend.y);

    return noiseVal / 0.7;
}
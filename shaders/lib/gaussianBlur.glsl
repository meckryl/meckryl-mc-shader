#include "/lib/math.glsl"

float weights_3[9] = float[] (0.1329807601338109,
    0.12579440923099774,
    0.10648266850745075,
    0.0806569081730478,
    0.05467002489199788,
    0.03315904626424957,
    0.017996988837729353,
    0.008740629697903166,
    0.003798662007932481);


vec4 blurSig3 (vec2 texCoord, sampler2D texSampler, vec2 samplerResolution, bool vertical) {
    ivec2 offset = (vertical) ? ivec2(0, 1) : ivec2(1, 0);
    ivec2 texel = ivec2(texCoord * samplerResolution);
    vec4 original = texelFetch(texSampler, texel, 0);
    vec4 result = original * weights_3[0];

    for (int i = 1; i <= 8; i++) {
        result += texelFetch(texSampler, texel + offset * i, 0) * weights_3[i];
        result += texelFetch(texSampler, texel - offset * i, 0) * weights_3[i];
    }

    //result *= 1.0 / 0.9955794353564287;

    return result;
}
//Approximation of ACES by Krzysztof Narkowicz: https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/

vec3 ACESApproximate(vec3 color) {
    color *= 0.6;
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp((color * (a * color + b)) / (color * (c * color + d) + e), 0.0, 1.0);
}

const mat3 ACESInputMat =
{
    {0.59719, 0.35458, 0.04823},
    {0.07600, 0.90834, 0.01566},
    {0.02840, 0.13383, 0.83777}
};

const mat3 ACESOutputMat =
{
    { 1.60475, -0.53108, -0.07367},
    {-0.10208,  1.10813, -0.00605},
    {-0.00327, -0.07276,  1.07602}
};

vec3 mul(mat3 m, vec3 v) {;
    float x = m[0][0] * v[0] + m[0][1] * v[1] + m[0][2] * v[2];
    float y = m[1][0] * v[0] + m[1][1] * v[1] + m[1][2] * v[2];
    float z = m[2][0] * v[0] + m[2][1] * v[1] + m[2][2] * v[2];
    return vec3(x, y, z);
}

vec3 RRTAndODTFit(vec3 v)
{
    vec3 a = v * (v + 0.0245786f) - 0.000090537f;
    vec3 b = v * (0.983729f * v + 0.4329510f) + 0.238081f;
    return a / b;
}

vec3 ACESFitted(vec3 color)
{
    color = mul(ACESInputMat, color);

    color = RRTAndODTFit(color);

    color = mul(ACESOutputMat, color);

    color = clamp(color, 0.0, 1.0);

    return color;
}

vec3 lottesTonemap(vec3 color) {
    const float contrast = 1.5;
    const float shoulder = 1.0;
    const float b = 1.0;
    const float c = 0.5;
    vec3 z = pow(color, vec3(contrast));
    vec3 result = z / (pow(z, vec3(shoulder)) * b + c);
    return clamp(result, 0.0, 1.0);
}
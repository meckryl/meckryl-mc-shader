#ifndef MATH_INCLUDED
#define MATH_INCLUDED

float pow2(float n){
    return n * n;
}

float satDot(vec3 v1, vec3 v2) {
    return clamp(dot(v1, v2), 0, 1);
}

#endif
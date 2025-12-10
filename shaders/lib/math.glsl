#ifndef MATH_INCLUDED
#define MATH_INCLUDED

float pow2(float n){
    return n * n;
}

float satDot(vec3 v1, vec3 v2) {
    return clamp(dot(v1, v2), 0, 1);
}

bool testInTriangle(vec2 p, vec2 p1, vec2 p2, vec2 p3) {
    float denom = (p2.y - p3.y) * (p1.x - p3.x) + (p3.x - p2.x) * (p1.y - p3.y);
    float a = ((p2.y - p3.y) * (p.x - p3.x) + (p3.x - p2.x) * (p.y - p3.y)) / denom;
    float b = ((p3.y - p1.y) * (p.x - p3.x) + (p1.x - p3.x) * (p.y - p3.y)) / denom;
    float c = 1 - a - b;

    return 0 <= a && a <= 1 && 0 <= b && b <= 1 && 0 <= c && c <= 1;
}

bool testInWedge(vec2 p, vec2 p1, vec2 p2, vec2 p3) {
    vec2 w1 = vec2(p1.y - p2.y, p2.x - p1.x);
    vec2 w2 = vec2(p1.y - p3.y, p3.x - p1.x);

    return dot(p - p1, w1) > 0 && dot(p - p1, w2) < 0;
}

#endif
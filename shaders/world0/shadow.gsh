#version 330 core

#include "/lib/globals.glsl"

layout (triangles) in;
layout (triangle_strip, max_vertices = 3) out;

/*in gl_Vertex
{
    vec4  gl_Position;
    float gl_PointSize;
    float gl_ClipDistance[];
} gl_in[];*/

in vertexData {
    vec2 texcoord;
    vec4 glcolor;
    flat uint blockID;
} vIn[];

out geomData {
    vec2 texcoord;
    vec4 glcolor;
    flat uint blockID;
    noperspective float trueY;
};

void main() {
    float minY = min(min(gl_in[0].gl_Position.y, gl_in[1].gl_Position.y), gl_in[2].gl_Position.y);
    float maxY = max(max(gl_in[0].gl_Position.y, gl_in[1].gl_Position.y), gl_in[2].gl_Position.y);

    int minI = -1;
    int maxI = -1;
    for (int i = 0; i < 3; i++){
        minI = (gl_in[i].gl_Position.y == minY) ? i : minI;
        maxI = (gl_in[i].gl_Position.y == maxY) ? i : maxI;
    }

    int medI = 3 - (minI + maxI); // Gives the index of the point that's neither the largest nor smallest
    float minBottomX = min(gl_in[minI].gl_Position.x, gl_in[medI].gl_Position.x);
    float maxBottomX = max(gl_in[minI].gl_Position.x, gl_in[medI].gl_Position.x);
    int triangleType = (gl_in[maxI].gl_Position.x == clamp(gl_in[maxI].gl_Position.x, minBottomX, maxBottomX)) ? 0 : 1;
    //int triangleType = 0;

    for (int i = 0; i < 3; i++){
        gl_Position = gl_in[i].gl_Position;
        texcoord = vIn[i].texcoord;
        glcolor = vIn[i].glcolor;
        blockID = vIn[i].blockID;

        switch (triangleType) {
            case 0:
                if (i == minI || i == medI) {
                    trueY = gl_in[i].gl_Position.y;
                }
                else {
                    float scale = abs((gl_in[i].gl_Position.x - gl_in[minI].gl_Position.x) / (gl_in[medI].gl_Position.x - gl_in[minI].gl_Position.x));
                    trueY = mix(gl_in[minI].gl_Position.y, gl_in[medI].gl_Position.y, scale);
                }
                break;
            case 1:
                trueY = gl_in[i].gl_Position.y - 0.00055; //Source: I made it up :3
                //I'm pretty sure this constant works because something something 1/shadowMapRes but it's slightly bigger of an offset than that and I have no clue why that's better
                //I just put this in here to debug and it ended up fixing the thing I was debugging
                break;
            default:
                break;
        }

        EmitVertex();
    }
    
    EndPrimitive();
}
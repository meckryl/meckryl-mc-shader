#version 460 compatibility

#include "/lib/globals.glsl"
#include "/lib/spaceConversions.glsl"
#include "/lib/fog/waterFog.glsl"

uniform sampler2D gtexture;
uniform sampler2D specular;
uniform sampler2D normals;
uniform sampler2D depthtex1;

uniform float alphaTestRef = 0.1;

uniform bool isEyeInWater;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;
in float depth;
flat in uint blockID;

/* RENDERTARGETS: 8,1,2,6,7,0 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;
layout(location = 3) out vec4 labpbrSpeculars;
layout(location = 4) out vec4 labpbrNormals;
layout(location = 5) out vec4 solidTerrainColor;

void main() {
	if (whiteWorld) {
		color = vec4(vec3(1.0), texture(gtexture, texcoord).w) * glcolor.a;
	}
	else {
		color = texture(gtexture, texcoord) * glcolor * glcolor.a;
	}
	if (color.a <= alphaTestRef) {
		discard;
	}
	color.rgb = pow(color.rgb, vec3(2.2)); // Inverse gamma correction


	lightmapData = vec4(lmcoord, 1.0, 1.0);
    encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);
    
    labpbrSpeculars = texture(specular, texcoord);
    labpbrNormals = texture(normals, texcoord);

    
    if (blockID == uint(3)) {
        labpbrSpeculars = vec4(1.0, 0.8, 0.0, 1.0);
        
        float solidDepth = texelFetch(depthtex1, ivec2(gl_FragCoord.xy), 0).x * 2.0 - 1.0;
        if (!isEyeInWater) {
            float viewDepth = -ndcPosToViewPos(vec3(0, 0, depth)).z;
            solidDepth = -ndcPosToViewPos(vec3(0, 0, solidDepth)).z;
            solidTerrainColor = vec4(glcolor.rgb * glcolor.rgb, clamp01((solidDepth - viewDepth) * 0.05));
            return;
        }
    }
    solidTerrainColor = vec4(0.0);
    
}
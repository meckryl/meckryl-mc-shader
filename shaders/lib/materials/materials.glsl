#include "/lib/spaceConversions.glsl"
#include "/lib/materials/behaviors/waving.glsl"

in vec2 mc_Entity;

uint get_material_id() {
	return uint(max(0.0, mc_Entity.x - 10000.0));
}

void handleMaterialProperties() {
    uint materialID = get_material_id();
    doWave(materialID);


}
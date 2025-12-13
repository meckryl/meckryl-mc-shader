#extension GL_KHR_shader_subgroup_basic : enable
#extension GL_KHR_shader_subgroup_arithmetic : enable

layout(local_size_x = RTW_IMAP_RES, local_size_y = 1, local_size_z = 1) in; //Each work group will be summing up at most RTW_IMAP_RES items
const ivec3 workGroups = ivec3(RTW_IMAP_RES, 2, 1); //The number of work groups is twice the number of rows, i.e. one work group per row and another per column.
shared float groupData[int(RTW_IMAP_RES)]; //Assumes we have at least a subgroup size of 8

layout (r32ui) uniform restrict uimage2D rtw_imap;
//uniform sampler2D rtw_imap_smpl;

void main() {
    //Read in the IDs of this invocation to get a unique mapping to the importance map
    uint workGroupID = gl_WorkGroupID.x;
    uint localID = gl_LocalInvocationID.x;
    uint subgroupID = gl_SubgroupID;
    uint subgroupInvoID = gl_SubgroupInvocationID;

    uint isColumn = gl_WorkGroupID.y;

    ivec2 invoMapping = ivec2(0);
    invoMapping.x = int(isColumn) + 2;
    invoMapping.y = int(workGroupID) - int(localID);

    //Sum up all mapped values in the current subgroup, and store to the groupData shared array

    /*
    I don't know why this exact setup is needed to prevent tiny amounts of flickering. 
    Something apparently goes wrong if the same variable is used both here and inside of the loop during reduction.
    I only figured this out by looking at: https://github.com/Luna5ama/Alpha-Piscium/blob/main/shaders/techniques/rtwsm/IMapCollapse.comp.glsl
    */

    {
        float ival = 0.0;
        if (invoMapping.x < RTW_IMAP_RES && invoMapping.y >= 0) {
            ival = imageLoad(rtw_imap, invoMapping).x;
        }
        groupData[localID] = 0.0;

        float groupResult = subgroupAdd(ival);
        if (subgroupInvoID == 0) {
            groupData[subgroupID] = groupResult;
        }
    }
    
    barrier(); //Ensure that all invocations obtain a value before continuing

    //Perform the reduction algorithm:
    uint neededSubgroups = gl_NumSubgroups;

    while (neededSubgroups > 0) {
        float ival;
        float groupResult;
        if(subgroupID < neededSubgroups && localID < int(RTW_IMAP_RES)) {
            ival = groupData[localID];
        }
        else {
            ival = 0;
        }
        groupResult = subgroupAdd(ival);
        if (subgroupInvoID == 0) {
            groupData[subgroupID] = groupResult;
        }

        
        neededSubgroups /= gl_SubgroupSize;
        barrier();
    }

    barrier();

    if (localID == 0) {
        imageStore(rtw_imap, ivec2(isColumn, workGroupID), uvec4(int(groupData[0]), 0, 0, 1));
    }
}
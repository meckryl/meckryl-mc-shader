layout(local_size_x = RTW_IMAP_RES, local_size_y = 1, local_size_z = 1) in; //Each work group contains invocations across a single row or column of the importance map
const ivec3 workGroups = ivec3(2, 1, 1); //The number of work groups is twice the number of rows, i.e. one work group per row and another per column.

layout (r32ui) uniform restrict uimage2D rtw_imap;

void main() {
    uint workGroupID = gl_WorkGroupID.x;
    uint localID = gl_LocalInvocationID.x;
    
    float partialSum  = imageLoad(rtw_imap, ivec2(workGroupID, localID)).x;
    float fullSum = imageLoad(rtw_imap, ivec2(workGroupID, RTW_IMAP_RES - 1)).x;

    float result = (partialSum / fullSum) * RTW_IMAP_RES - 1;

    imageStore(rtw_imap, ivec2(workGroupID + 2, localID), uvec4(result * RTW_IMAP_RES, 0, 0, 1));
}
//
// Example shader - ped_morph.fx
//


//---------------------------------------------------------------------
// Ped morph settings
//---------------------------------------------------------------------
float3 sMorphSize = float3(0,0,0);
float sRazval = 10;
float sWidth = 0.2;
float sRotationX = 0;
float sRotationZ = 0;
float3 sAxis = float3(0, 0, 0);


//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
#include "mta-helper.fx"


//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VSInput
{
    float3 Position : POSITION0;
    float3 Normal : NORMAL0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

float4 quat_from_axis_angle(float3 axis, float angle)
{ 
  float4 qr;
  float half_angle = (angle * 0.5) * 3.14159 / 180.0;
  qr.x = axis.x * sin(half_angle);
  qr.y = axis.y * sin(half_angle);
  qr.z = axis.z * sin(half_angle);
  qr.w = cos(half_angle);
  return qr;
}
 
float4 quat_conj(float4 q)
{ 
  return float4(-q.x, -q.y, -q.z, q.w); 
}
  
float4 quat_mult(float4 q1, float4 q2)
{ 
  float4 qr;
  qr.x = (q1.w * q2.x) + (q1.x * q2.w) + (q1.y * q2.z) - (q1.z * q2.y);
  qr.y = (q1.w * q2.y) - (q1.x * q2.z) + (q1.y * q2.w) + (q1.z * q2.x);
  qr.z = (q1.w * q2.z) + (q1.x * q2.y) - (q1.y * q2.x) + (q1.z * q2.w);
  qr.w = (q1.w * q2.w) - (q1.x * q2.x) - (q1.y * q2.y) - (q1.z * q2.z);
  return qr;
}
 
float3 rotate_vertex_position(float3 position, float3 axis, float angle)
{ 
  float4 qr = quat_from_axis_angle(axis, angle);
  float4 qr_conj = quat_conj(qr);
  float4 q_pos = float4(position.x, position.y, position.z, 0);
  
  float4 q_tmp = quat_mult(qr, q_pos);
  qr = quat_mult(q_tmp, qr_conj);
  
  return float3(qr.x, qr.y, qr.z);
}

//------------------------------------------------------------------------------------------
// VertexShaderFunction
//  1. Read from VS structure
//  2. Process
//  3. Write to PS structure
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;    
    //float3 worldNormal = mul(VS.Normal, (float3x3)gWorld);
    VS.Position += VS.Normal * float3(sWidth, 0, 0);

    VS.Position = rotate_vertex_position(VS.Position, float3(1, 0, 0), float3(sRotationX, 0, 0));
    VS.Position = rotate_vertex_position(VS.Position, float3(0, 1, 0), float3(sRazval, 0, 0));
    VS.Position = rotate_vertex_position(VS.Position, float3(0, 0, 1), float3(sRotationZ, 0, 0));
    // Calculate screen pos of vertex
    PS.Position = MTACalcScreenPosition ( VS.Position );

    // Pass through tex coords
    PS.TexCoord = VS.TexCoord;
    
    VS.Normal = rotate_vertex_position(VS.Normal, float3(1, 0, 0), float3(sRotationX, 0, 0));
    VS.Normal = rotate_vertex_position(VS.Normal, float3(0, 1, 0), float3(sRazval, 0, 0));
    VS.Normal = rotate_vertex_position(VS.Normal, float3(0, 0, 1), float3(sRotationZ, 0, 0));
    float3 worldNormal = mul(VS.Normal, (float3x3)gWorld);
    // Calc GTA lighting for peds
    PS.Diffuse = MTACalcGTAVehicleDiffuse(worldNormal, VS.Diffuse );

    return PS;
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique tec0
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
    }
}

// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
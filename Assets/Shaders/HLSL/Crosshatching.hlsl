// _ScreenSpaceOcclusionTexture
// _ScreenSpaceShadowmapTexture


void GetShadowValue_float(float2 uv, out float Out)
{
    UnityTexture2D tex = _ScreenSpaceShadowmapTexture;
    float3 rgb = SAMPLE_TEXTURE2D_LOD(texture.tex, texture.samplerstate, uv, 0).xyz;
    return (rgb.x + rgb.y + rgb.z) /3;
}
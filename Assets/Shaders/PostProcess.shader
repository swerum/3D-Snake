Shader "Custom/PostProcess"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _CameraOpaqueTexture ("Camera Opaque Texture", 2D) = "white" {}
        _Intensity ("Intensity", float) = 2
    }
    SubShader
    {
        Tags { "RenderType"= "Opaque" "RenderPipeline" = "UniversalPipeline"}
        // No culling or depth
        // Cull Off ZWrite Off ZTest Always

        Pass
        {
            Name "ColorBlitPass"

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            // The Blit.hlsl file provides the vertex shader (Vert),
            // input structure (Attributes) and output strucutre (Varyings)
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            #pragma vertex Vert
            #pragma fragment frag

            TEXTURE2D_X(_CameraOpaqueTexture);
            SAMPLER(sampler_CameraOpaqueTexture);

            TEXTURE2D_X(_MainTex);
            SAMPLER(sampler_MainTex);
            // sampler2D _MainTex;
            // float4 _MainTex_ST;

            float _Intensity;

            half4 frag (Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                float4 color = SAMPLE_TEXTURE2D_X(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, input.texcoord);
                // float4 color = SAMPLE_TEXTURE2D_X(_MainTex, sampler_MainTex, input.texcoord);
                // float4 color = tex2D(_MainTex, input.texcoord);
                // return color * float4(0, _Intensity, 0, 1);
                return color;
            }
            ENDHLSL
        }
    }
}

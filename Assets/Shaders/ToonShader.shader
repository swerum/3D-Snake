Shader "Custom/ToonShader"
{
    Properties
    {
        [Header(Toon Shading)]
        _NumSteps ("Number of Steps", int) = 3
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _ShadowColor ("Shadow Color", Color) = (1,1,1,1)
        
        [Header(Specular Highlight)]
        _HasSpecularHighlight ("Has Specular Highlight", int) = 1
        _HighlightColor ("Highlight Color", Color) = (1,1,1,1)
        _Glossiness ("Glossiness", Range(0.0, 10.0)) = 1
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
        LOD 100

        HLSLINCLUDE
        // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        ENDHLSL
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN

            #include "UnityCG.cginc"
            #include "HLSL/ToonShading.hlsl"

            ENDHLSL
        }

        Pass {
            // The shadow caster pass, which draws to shadow maps
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ColorMask 0 // No color output, only depth

            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "HLSL/ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
}

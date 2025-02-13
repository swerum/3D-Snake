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
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "HLSL/ToonShading.hlsl"

            ENDCG
        }

        Pass {
            // The shadow caster pass, which draws to shadow maps
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ColorMask 0 // No color output, only depth

            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "HLSL/ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
}

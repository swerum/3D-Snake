Shader "Custom/ToonShader"
{
    Properties
    {
        [Header(Drawn Effect)]
        _TextureNoise ("TextureNoiseMap", 2D) = "white" {}
        _BackgroundColor ("Background Color", Color) = (1,1,1,1)
        _Tiling("Tiling", Vector) = (5,5,0,0)

        [Header(Toon Shading)]
        _NumSteps ("Number of Steps", int) = 3
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _ShadowColor ("Shadow Color", Color) = (1,1,1,1)
        _LightDirection ("Light Direction", Vector) = (1,1,1, 0)
        
        [Header(Specular Highlight)]
        _HasSpecularHighlight ("Has Specular Highlight", int) = 1
        _HighlightColor ("Highlight Color", Color) = (1,1,1,1)
        _Glossiness ("Glossiness", int) = 1
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

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
                float2 uv : TEXCOORD0;
				float3 viewDir : TEXCOORD1;	
            };

            fixed4 _BaseColor;
            fixed4 _ShadowColor;
            fixed4 _HighlightColor;
            fixed4 _LightDirection;
            int _NumSteps;
            float _LightIntensity;
            float _Glossiness;
            int _HasSpecularHighlight;

            float2 _Tiling;
            fixed4 _BackgroundColor;
            sampler2D _TextureNoise;
            float4 _TextureNoise_ST;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);		
				o.viewDir = WorldSpaceViewDir(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _TextureNoise);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //get specular highlight
                if (_HasSpecularHighlight) {
                    float3 viewDir = normalize(i.viewDir);
                    float3 halfVector = normalize(viewDir - normalize(_LightDirection));
                    float dotProduct = dot(halfVector, normalize(i.worldNormal));
                    float specular = pow(dotProduct, 4);
                    if (specular >1-_Glossiness/100) { return _HighlightColor; }
                }

                //get base color
                float cosineAngle = dot(normalize(i.worldNormal), normalize(_LightDirection.xyz));
                cosineAngle = smoothstep(-1,1, cosineAngle);
                if (cosineAngle == 1) cosineAngle = 0.999;
                cosineAngle = max(cosineAngle, 0.0);
                cosineAngle = floor(cosineAngle * _NumSteps) / (_NumSteps-1);
                fixed4 toonColor = lerp(_BaseColor, _ShadowColor, cosineAngle);

                // add crayon shading
                // fixed alpha = tex2D(_TextureNoise, i.uv*_Tiling).x;
                // fixed4 finalColor = lerp(_BackgroundColor, toonColor, alpha);

                return toonColor;
                // return finalColor;
            }
            ENDCG
        }
    }
}

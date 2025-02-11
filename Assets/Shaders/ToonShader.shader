Shader "Custom/ToonShader"
{
    Properties
    {
        
        _NumSteps ("Number of Steps", int) = 3
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _ShadowColor ("Shadow Color", Color) = (1,1,1,1)
        _LightDirection ("Light Direction", Vector) = (1,1,1, 0)
        
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);		
				o.viewDir = WorldSpaceViewDir(v.vertex);
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
                cosineAngle = max(cosineAngle, 0.0);
                cosineAngle = floor(cosineAngle * _NumSteps) / (_NumSteps-1);
                fixed4 toonColor = lerp(_BaseColor, _ShadowColor, cosineAngle);

                return toonColor;
            }
            ENDCG
        }
    }
}

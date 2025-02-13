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
float3 _LightDirection;
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
    _LightDirection = normalize(_LightDirection);
    if (_HasSpecularHighlight) {
        float3 viewDir = normalize(i.viewDir);
        float3 halfVector = normalize(viewDir + _LightDirection);
        float dotProduct = dot(halfVector, normalize(i.worldNormal));
        float specular = pow(dotProduct, _Glossiness*_Glossiness);
        if (specular > 0.9) { return _HighlightColor; }
    }

    //get base color
    float cosineAngle = dot(normalize(i.worldNormal), _LightDirection);
    cosineAngle = smoothstep(-1,1, cosineAngle);
    if (cosineAngle == 1) cosineAngle = 0.999;
    cosineAngle = max(cosineAngle, 0.0);
    cosineAngle = floor(cosineAngle * _NumSteps) / (_NumSteps-1);
    fixed4 toonColor = lerp(_ShadowColor, _BaseColor, cosineAngle);

    return toonColor;
}
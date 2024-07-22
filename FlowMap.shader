Shader "MyShader/04_FlowMap"
{
    Properties
    {
        _tex("tex", 2D) = "white" {}
        _flowMap("flowMap", 2D) = "white" {}
        _intensity("intensity", range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _tex;
            sampler2D _flowMap;
            float4 _tex_ST;
            float _intensity;
            
            fixed4 frag (v2f i) : SV_Target
            {
                float2 tiling = _tex_ST.xy;

                float4 flowMap = tex2D(_flowMap, i.uv) * 2 - 1;
                float alpha = frac(_Time.y) * 0.2;
                float alpha2 = frac(_Time.y);

                float beta = frac(_Time.y + 0.5) * 0.2;
                float flowLerp = abs((0.5 - alpha2) / 0.5);
                
                float4 tex1 = tex2D(_tex, i.uv * tiling + flowMap.xy * alpha * _intensity );
                float4 tex2 = tex2D(_tex, i.uv * tiling + flowMap.xy * beta * _intensity);

                float4 finalTex = lerp(tex1, tex2, flowLerp);

                return finalTex;
            }
            ENDCG
        }
    }
}

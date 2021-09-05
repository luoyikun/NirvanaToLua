//------------------------------------------------------------------------------
// Copyright c 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

Shader "Game/PostEffect/DownSample"
{
	Properties
    {
        _MainTex ("Base (RGB)", 2D) = "" {}
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    struct v2f
    {
        float4 pos : SV_POSITION;
        float2 uv[4] : TEXCOORD0;
    };

    sampler2D _MainTex;
    half4 _MainTex_TexelSize;

	v2f vert(appdata_img v)
	{
		v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv[0] = v.texcoord.xy + _MainTex_TexelSize.xy * 0.5;
        o.uv[1] = v.texcoord.xy - _MainTex_TexelSize.xy * 0.5;
        o.uv[2] = v.texcoord.xy - _MainTex_TexelSize.xy * half2(1, -1) * 0.5;
        o.uv[3] = v.texcoord.xy + _MainTex_TexelSize.xy * half2(1, -1) * 0.5;
        return o;
    }

    half4 frag(v2f i) : SV_Target
    {
        half4 outColor = 0;
        outColor += tex2D(_MainTex, i.uv[0].xy);
        outColor += tex2D(_MainTex, i.uv[1].xy);
        outColor += tex2D(_MainTex, i.uv[2].xy);
        outColor += tex2D(_MainTex, i.uv[3].xy);
        return outColor / 4;
    }

    ENDCG

    SubShader
    {
		Cull Off
		ZTest Off
		ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
    }

	Fallback off
}

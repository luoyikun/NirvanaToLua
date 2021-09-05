//------------------------------------------------------------------------------
// Copyright c 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

Shader "Game/PostEffect/BrightPass"
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
		float2 uv : TEXCOORD0;
	};

	sampler2D _MainTex;
	half4 _Threshhold;

	v2f vert(appdata_img v) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv =  v.texcoord.xy;
		return o;
	} 

	half4 frag(v2f i) : SV_Target 
	{
		half4 color = tex2D(_MainTex, i.uv);
		color.rgb = max(half3(0,0,0), color.rgb - _Threshhold.rgb);
		return color;
	}	

	ENDCG 
	
	Subshader 
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

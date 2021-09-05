//------------------------------------------------------------------------------
// Copyright c 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

Shader "Game/PostEffect/BlurPass"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
	}
	
	CGINCLUDE

	#include "UnityCG.cginc"

	struct v2f
	{
		half4 pos : SV_POSITION;
		half2 uv : TEXCOORD0;
		half4 uv01 : TEXCOORD1;
		half4 uv23 : TEXCOORD2;
		half4 uv45 : TEXCOORD3;
		half4 uv67 : TEXCOORD4;
	};
	
	sampler2D _MainTex;
	half4 _MainTex_TexelSize;
	half4 _Offsets;

	v2f vert(appdata_img v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv.xy = v.texcoord.xy;
		o.uv01 =  v.texcoord.xyxy + _Offsets.xyxy * half4(1, 1, -1, -1);
		o.uv23 =  v.texcoord.xyxy + _Offsets.xyxy * half4(1, 1, -1, -1) * 2.0;
		o.uv45 =  v.texcoord.xyxy + _Offsets.xyxy * half4(1, 1, -1, -1) * 3.0;
		o.uv67 =  v.texcoord.xyxy + _Offsets.xyxy * half4(1, 1, -1, -1) * 4.0;
		o.uv67 =  v.texcoord.xyxy + _Offsets.xyxy * half4(1, 1, -1, -1) * 5.0;
		return o;
	}

	half4 frag (v2f i) : SV_Target
	{
		half4 color = half4 (0,0,0,0);
		color += 0.225 * tex2D (_MainTex, i.uv);
		color += 0.150 * tex2D (_MainTex, i.uv01.xy);
		color += 0.150 * tex2D (_MainTex, i.uv01.zw);
		color += 0.110 * tex2D (_MainTex, i.uv23.xy);
		color += 0.110 * tex2D (_MainTex, i.uv23.zw);
		color += 0.075 * tex2D (_MainTex, i.uv45.xy);
		color += 0.075 * tex2D (_MainTex, i.uv45.zw);	
		color += 0.0525 * tex2D (_MainTex, i.uv67.xy);
		color += 0.0525 * tex2D (_MainTex, i.uv67.zw);
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

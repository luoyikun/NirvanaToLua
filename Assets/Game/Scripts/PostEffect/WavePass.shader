//------------------------------------------------------------------------------
// Copyright c 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

Shader "Game/PostEffect/WavePass"
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
	half4 _WaveStrength;

	v2f vert(appdata_img v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv.xy = v.texcoord.xy;
		o.uv01 = v.texcoord.xyxy + _Offsets.xyxy * half4(1, 1, -1, -1);
		o.uv23 = v.texcoord.xyxy + _Offsets.xyxy * half4(1, 1, -1, -1) * 2.0;
		o.uv45 = v.texcoord.xyxy + _Offsets.xyxy * half4(1, 1, -1, -1) * 3.0;
		o.uv67 = v.texcoord.xyxy + _Offsets.xyxy * half4(1, 1, -1, -1) * 4.0;
		o.uv67 = v.texcoord.xyxy + _Offsets.xyxy * half4(1, 1, -1, -1) * 5.0;
		return o;
	}

	half4 frag(v2f i) : SV_Target
	{
		//计算uv到中间点的向量(向外扩，反过来就是向里缩)
		half2 dv = half2(0.5, 0.5) - i.uv;
		//按照屏幕长宽比进行缩放
		dv = dv * half2(_ScreenParams.x / _ScreenParams.y, 1);
		//计算像素点距中点的距离
		half dis = sqrt(dv.x * dv.x + dv.y * dv.y);
		//用sin函数计算出波形的偏移值factor  
		//dis在这里都是小于1的，所以我们需要乘以一个比较大的数，比如60，这样就有多个波峰波谷  
		//sin函数是（-1，1）的值域，我们希望偏移值很小，所以这里我们缩小100倍，据说乘法比较快,so...  
		half _distanceFactor = 2.0;
		half _totalFactor = 10.0;
		half _waveWidth = 0.25;
		half _curWaveDis = _WaveStrength;
		half sinFactor = sin(dis * _distanceFactor) * _totalFactor * 0.01;
		//距离当前波纹运动点的距离，如果小于waveWidth才予以保留，否则已经出了波纹范围，factor通过clamp设置为0  
		half discardFactor = clamp(_waveWidth - abs(_curWaveDis - dis), 0, 1);
		//归一化  
		half2 dv1 = normalize(dv);
		//计算每个像素uv的偏移值  
		half2 offset = dv1 * sinFactor * discardFactor;

		//模糊处理
		half4 color = half4(0,0,0,0);
		color += 0.225 * tex2D(_MainTex, offset + i.uv);
		color += 0.150 * tex2D(_MainTex, offset + i.uv01.xy);
		color += 0.150 * tex2D(_MainTex, offset + i.uv01.zw);
		color += 0.110 * tex2D(_MainTex, offset + i.uv23.xy);
		color += 0.110 * tex2D(_MainTex, offset + i.uv23.zw);
		color += 0.075 * tex2D(_MainTex, offset + i.uv45.xy);
		color += 0.075 * tex2D(_MainTex, offset + i.uv45.zw);
		color += 0.0525 * tex2D(_MainTex, offset + i.uv67.xy);
		color += 0.0525 * tex2D(_MainTex, offset + i.uv67.zw);
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

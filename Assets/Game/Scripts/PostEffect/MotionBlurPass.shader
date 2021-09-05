
Shader "Game/PostEffect/MotionBlurPass" {
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_fSampleDist("SampleDist", Float) = 1 //采样距离
		_fSampleStrength("SampleStrength", Float) = 1.5 //采样力度
	}
		
	SubShader
	{
		Pass 
		{
			ZTest Always Cull Off ZWrite Off
			Fog { Mode off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata_t 
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD;
			};

			struct v2f 
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD;
			};

			float4 _MainTex_ST;

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			sampler2D _MainTex;
			float _fSampleDist;
			float _fSampleStrength;

			// some sample positions  
			static const float samples[6] =
			{
				-0.05,
				-0.03,
				-0.01,
				0.01,
				0.03,
				0.05,
			};

			half4 frag(v2f i) : SV_Target
			{
				//0.5,0.5屏幕中心
				float2 dir = float2(0.5, 0.5) - i.texcoord;//从采样中心到uv的方向向量
				float2 texcoord = i.texcoord;
					float dist = length(dir);
				dir = normalize(dir);
				float4 color = tex2D(_MainTex, texcoord);

				float4 sum = color;
				//    6次采样
				for (int i = 0; i < 6; ++i)
				{
					sum += tex2D(_MainTex, texcoord + dir * samples[i] * _fSampleDist);
				}

				//求均值
				sum /= 7.0f;

				//越离采样中心近的地方，越不模糊
				float t = saturate(dist * _fSampleStrength);

				//插值
				return lerp(color, sum, t);
			}
			ENDCG
		}
	}
	Fallback off
}
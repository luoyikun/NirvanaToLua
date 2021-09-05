//a simple billboard shader used for demos

Shader "MTE/Grass/Billboard"
{
	Properties
	{
		_MainTex("Grass Texture", 2D) = "white" {}
		_Cutoff("Alpha cutoff", Range(0,1)) = 0.5
	}

	SubShader
	{
		Tags{
			"Queue" = "AlphaTest"
			"IgnoreProjector" = "True"
			"DisableBatching" = "True"
			"RenderType" = "TransparentCutout"
		}

		Pass
		{
			CGPROGRAM

			#pragma vertex vert  
			#pragma fragment frag

			uniform sampler2D _MainTex;
			uniform float _Cutoff;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 tex : TEXCOORD0;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
			};


			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				output.pos = mul(UNITY_MATRIX_P,
					mul(UNITY_MATRIX_MV, float4(0.0, 0.0, 0.0, 1.0))
					+ float4(input.vertex.x, input.vertex.y, 0.0, 0.0));

				output.tex = input.tex;

				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				float4 c = tex2D(_MainTex, float2(input.tex.xy));
				clip(c.a - _Cutoff);
				return c;
			}

			ENDCG
		}
	}
}

//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

Shader "Nirvana/Editor/GridCell"
{
	Properties
	{
    }

	SubShader
	{
		Tags
        {
            "RenderType"="Transparent"
            "Queue" = "Transparent+100"
        }

		LOD 100

		Pass
		{
			ZTest Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

            sampler2D _CameraDepthTexture;

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
                float4 screenPos : TEXCOORD0;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;

                o.screenPos = ComputeScreenPos(o.vertex);
                COMPUTE_EYEDEPTH(o.screenPos.z);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                half depth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, i.screenPos).r);
                if (depth < i.screenPos.z - 0.5)
                {
                    return 0.75 * i.color;
                }
                else
                {
                    return i.color;
                }
			}
			ENDCG
		}
	}
}

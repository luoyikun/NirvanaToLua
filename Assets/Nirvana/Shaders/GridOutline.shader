//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

Shader "Nirvana/Editor/GridOutline"
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

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(0, 0, 0, 0.25);
			}
			ENDCG
		}
	}
}

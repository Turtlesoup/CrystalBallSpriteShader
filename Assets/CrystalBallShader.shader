// Author: Luke Brown (lukebrown4290@hotmail.com)
// Modified shader based on ArcadiaSpritesWaterDistortion.shader by Federico Mercurio https://github.com/padreperoni/sprites-water-distortion/blob/master/ArcadiaSpritesWaterDistortion.shader
Shader "Sprites/CrystalBallShader"
{
	Properties
	{
		[PerRendererData] _Color("Tint", Color) = (1,1,1,1)
		[NoScaleOffset] _DistortionTexture("Distortion Texture", 2D) = "white" {}

		_RefractionXOffset("X Refraction Offset", Range(-0.1,0.1)) = 0.01
		_RefractionYOffset("Y Refraction Offset", Range(-0.1,0.1)) = 0.01

		_DistortionScaleX("Distortion Scale X", float) = 1.0
		_DistortionScaleY("Distortion Scale Y", float) = 1.0
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Opaque"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Fog{ Mode Off }
		Blend One OneMinusSrcAlpha

		GrabPass{}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata_t
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
				half2 grabcoord : TEXCOORD1;
			};

			fixed4 _Color;
			sampler2D _GrabTexture;
			float _RefractionXOffset;
			float _RefractionYOffset;

			sampler2D _DistortionTexture;
			float _DistortionScaleX;
			float _DistortionScaleY;

			v2f vert(appdata_t input)
			{
				v2f output;
				output.vertex = UnityObjectToClipPos(input.vertex);

				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif

				output.grabcoord = (float2(output.vertex.x, output.vertex.y * scale) + output.vertex.w) * 0.5;
				output.texcoord = input.texcoord.xy;

				output.grabcoord.x -= _RefractionXOffset / 2;
				output.grabcoord.y -= _RefractionYOffset / 2;

				output.color = input.color * _Color;

				return output;
			}

			fixed4 frag(v2f input) : SV_Target
			{
				float2 offsetFromCenter = input.texcoord - float2(0.5, 0.5);
				float2 distortionScale = float2(_DistortionScaleX, _DistortionScaleY);
				float distortionIntensity = tex2D(_DistortionTexture, input.texcoord);
				
				fixed4 c = tex2D(_GrabTexture, input.grabcoord + offsetFromCenter * distortionScale * distortionIntensity) * input.color;
				c.rgb *= c.a;

				return c;
			}
			ENDCG
		}
	}
}
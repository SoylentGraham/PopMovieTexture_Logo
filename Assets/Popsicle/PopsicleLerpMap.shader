Shader "NewChromantics/PopsicleLerpMap" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		Colour2 ("Colour2", Color) = (0,0,1,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		fixed4 Colour2;
		//float4 _Time;


		float4 AnimateColour(float4 a,float4 b,float4 c,float2 uv)
		{
			float TimeMajor;
			float TimeScalar = 2;
			float TimeMinor = modf( _Time.y*TimeScalar, TimeMajor );

			float Varying = ((a.x + a.y + a.z)/3) + TimeMinor;
					
			//	make uv.y wrap
			if ( Varying > 1 )
				Varying -= 1;

			//	turn 0..1 to 0..05...0
			{
				Varying *= 2;

				if ( Varying > 1 )
					Varying = 1 - (Varying-1);
				//uv.y /= 2;
			}

			//Varying *= (a.x + a.y + a.z) / 3;

			float LerpTime = Varying;

			//a = float4( uv.x, uv.y, 0, 1 );
			return lerp( c, b, LerpTime );
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);

			c = AnimateColour( c, _Color, Colour2, IN.uv_MainTex );

			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}

Shader "NewChromantics/PopsicleMovieAnimate" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		Colour2 ("Colour2", Color) = (0,0,1,1)
		TimeScalar("TimeScalar", Range(0,4) ) = 1
		TimeOffset("TimeOffset", Range(0,1) ) = 0
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
		float TimeScalar;
		float TimeOffset;



		float4 AnimateColour(float4 a,float4 b,float4 c,float2 uv)
		{
			float TimeMajor;
			float TimeMinor = modf( (_Time.y*TimeScalar) + TimeOffset, TimeMajor );

			float Varying = TimeMinor;

			Varying += uv.y;
					
			//	make uv.y wrap
			if ( Varying > 1 )
				Varying -= 1;

						/*
			//	turn 0..1 to 0..05...0
			{
				Varying *= 2;

				if ( Varying > 1 )
					Varying = 1 - (Varying-1);
				//uv.y /= 2;
			}
			*/
			uv.y = Varying;

			float LerpTime = tex2D (_MainTex, uv).x;
			return lerp( b, c, LerpTime );

			return float4( uv.x, uv.y, 0, 1 );
		}

		#define PIf 3.1415926535897932384626433832795f

		float2 fault(float2 uv, float s)
		{
	    	//float v = (0.5 + 0.5 * cos(2.0 * pi * uv.y)) * (2.0 * uv.y - 1.0);
	    	float v = pow(0.5 - 0.5 * cos(2.0 * PIf * uv.y), 100.0) * sin(2.0 * PIf * uv.y);
	    	uv.x += v * s;
	    	return uv;
		}

		float fract(float f)
		{
			float Major;
			float Minor = modf( f, Major );
			return Minor;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);

			//	mirror uv
			float2 uv = IN.uv_MainTex;
			uv.x = 1-uv.x;


			//	noise
			//float r = texture2D(iChannel2, float2(t, 0.0)).x;
			float r = 0;
			float t = _Time.y;

			//	apply tv fault
		//	uv = fault(uv + float2(0.0, fract(t * 2.0)), 5.0 * sign(r) * pow(abs(r), 5.0)) - float2(0.0, fract(t * 2.0));


			c = AnimateColour( c, _Color, Colour2, uv );

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

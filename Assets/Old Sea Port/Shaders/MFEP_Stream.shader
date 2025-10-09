Shader "MFEP_Stream_URP"
{
    Properties
    {
        _Ripples_Displacement("Ripples_Displacement", 2D) = "gray" {}
        _Ripples("Ripples", 2D) = "bump" {}
        _Ripples2("Ripples2", 2D) = "bump" {}
        _Color("Color", Color) = (0,0,0,0)
        _Displacement("Displacement", Range( 0 , 1)) = 0
        _Metallic("Metallic", Range( 0 , 1)) = 0
        _Base_Smoothness("Base_Smoothness", Range( 0 , 1)) = 0
        _Speed("Speed", Range( 0 , 1)) = 0
        [HideInInspector] _texcoord( "", 2D ) = "white" {}
    }

    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque" 
            "Queue" = "Geometry+0" 
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }
        
        LOD 300
        Cull Back

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // URP includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float4 positionCS : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            TEXTURE2D(_Ripples);
            SAMPLER(sampler_Ripples);
            
            TEXTURE2D(_Ripples2);
            SAMPLER(sampler_Ripples2);
            
            TEXTURE2D(_Ripples_Displacement);
            SAMPLER(sampler_Ripples_Displacement);

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float _Displacement;
                float _Metallic;
                float _Base_Smoothness;
                float _Speed;
                float4 _Ripples2_ST;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                // Displacement
                float2 pannerUV = input.uv + _Time.y * float2(_Speed, 0);
                float displacement = SAMPLE_TEXTURE2D_LOD(_Ripples_Displacement, sampler_Ripples_Displacement, pannerUV, 0).r;
                
                // Apply displacement along normal
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
                input.positionOS.xyz += normalWS * displacement * _Displacement;

                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(output.positionWS);
                output.normalWS = normalWS;
                output.uv = input.uv;
                output.color = input.color;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                // Animated UVs for ripples
                float2 pannerUV = input.uv + _Time.y * float2(_Speed, 0);
                
                // Sample normal maps
                float3 normal1 = UnpackNormal(SAMPLE_TEXTURE2D(_Ripples, sampler_Ripples, pannerUV));
                float2 uv_Ripples2 = input.uv * _Ripples2_ST.xy + _Ripples2_ST.zw;
                float3 normal2 = UnpackNormal(SAMPLE_TEXTURE2D(_Ripples2, sampler_Ripples2, uv_Ripples2));
                
                // Combine normals
                float3 combinedNormal = normalize(normal1 + normal2);

                // PBR setup
                float3 normalWS = normalize(input.normalWS);
                normalWS = normalize(TransformTangentToWorld(combinedNormal, float3x3(normalWS, float3(0,0,1), float3(1,0,0))));

                // Base color
                float3 albedo = (_Color * input.color).rgb;

                // PBR parameters
                float metallic = _Metallic;
                float smoothness = _Base_Smoothness;
                float occlusion = 1.0;
                float alpha = 1.0;

                // Lighting
                InputData inputData = (InputData)0;
                inputData.positionWS = input.positionWS;
                inputData.normalWS = normalWS;
                inputData.viewDirectionWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
                inputData.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                inputData.fogCoord = 0; // Not using fog
                inputData.vertexLighting = float3(0, 0, 0);
                inputData.bakedGI = SampleSH(normalWS);
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
                inputData.shadowMask = float4(1, 1, 1, 1);

                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.albedo = albedo;
                surfaceData.specular = 1.0;
                surfaceData.metallic = metallic;
                surfaceData.smoothness = smoothness;
                surfaceData.normalTS = combinedNormal;
                surfaceData.emission = 0;
                surfaceData.occlusion = occlusion;
                surfaceData.alpha = alpha;
                surfaceData.clearCoatMask = 0;
                surfaceData.clearCoatSmoothness = 1;

                half4 color = UniversalFragmentPBR(inputData, surfaceData);
                color.rgb = MixFog(color.rgb, inputData.fogCoord);
                
                return color;
            }
            ENDHLSL
        }

        // Shadow casting
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            float3 _LightDirection;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            TEXTURE2D(_Ripples_Displacement);
            SAMPLER(sampler_Ripples_Displacement);

            CBUFFER_START(UnityPerMaterial)
                float _Displacement;
                float _Speed;
            CBUFFER_END

            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                // Apply displacement for shadows too
                float2 pannerUV = input.uv + _Time.y * float2(_Speed, 0);
                float displacement = SAMPLE_TEXTURE2D_LOD(_Ripples_Displacement, sampler_Ripples_Displacement, pannerUV, 0).r;
                
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
                input.positionOS.xyz += normalWS * displacement * _Displacement;

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
                output.uv = input.uv;

                return output;
            }

            half4 ShadowPassFragment(Varyings input) : SV_TARGET
            {
                return 0;
            }
            ENDHLSL
        }
    }
    
    FallBack "Universal Render Pipeline/Lit"
}
// Copyright (c) 2024 Richard Hawkins
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include <metal_stdlib>
using namespace metal;
#import "Common.h"


struct VertexIn {
    float4 position [[attribute(PositionIndex)]];
    float3 normal [[attribute(NormalIndex)]];
    float2 uv [[attribute(UVIndex)]];
    float3 tangent [[attribute(TangentIndex)]];
    float3 bitangent [[attribute(BitangentIndex)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 fragPosition;
    float2 uv;
    float3 tangentLightPos;
    float3 tangentViewPos;
    float3 tangentFragPos;
};

vertex VertexOut vertex_main(const VertexIn in [[stage_in]], constant Uniforms &uniforms [[buffer(UniformBufferIndex)]]) {
    float4 worldPosition = uniforms.modelMatrix * in.position;
    
    float3 T = normalize(uniforms.normalMatrix * in.tangent);
    float3 N = normalize(uniforms.normalMatrix * in.normal);
    T = normalize(T - dot(T, N) * N);
    float3 B = cross(N, T);
    float3x3 TBN = transpose(float3x3(T, B, N));
    
    VertexOut out {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * worldPosition,
        .fragPosition = worldPosition.xyz,
        .uv = in.uv,
        .tangentLightPos = TBN * uniforms.lightPosition,
        .tangentViewPos = TBN * uniforms.viewPosition,
        .tangentFragPos = TBN * worldPosition.xyz
    };
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]], constant Params &params [[buffer(ParamBufferIndex)]], texture2d<float> baseColorTexture [[texture(BaseColorTextureIndex)]], texture2d<float> normalTexture [[texture(NormalTextureIndex)]]) {
    
    constexpr sampler textureSampler(filter::linear, mip_filter::linear, max_anisotropy(8), address::repeat);
    float3 baseColor = baseColorTexture.sample(textureSampler, in.uv).rgb;
    float3 normal = normalTexture.sample(textureSampler, in.uv).rgb;
    normal = normal * 2.0 - 1;
        
    // Calculate Ambient Component
    float3 ambient = params.ambientStrength * baseColor;
    
    // Calculate Diffuse Component
    float3 lightDir = normalize(in.tangentLightPos - in.tangentFragPos);
    float diff = max(dot(lightDir, normal), 0.0);
    float3 diffuse = diff * baseColor;
    
    // Calculate Specular Component
    float3 viewDir = normalize(in.tangentViewPos - in.tangentFragPos);
    float3 reflectDir = reflect(-lightDir, normal);
    float3 halfwayDir = normalize(lightDir + viewDir);
    float spec = pow(max(dot(normal, halfwayDir), 0.0), 8.0);
    float3 specular = float3(0.2) * spec;

    // Calculate Final Color
    vector_float3 color = ambient + diffuse + specular;
    return float4(color, 1.0);
}

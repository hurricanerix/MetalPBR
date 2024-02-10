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
};

struct VertexOut {
    float4 position [[position]];
    float3 fragPosition;
    float3 normal;
    float2 uv;
};

vertex VertexOut vertex_main(const VertexIn vertex_in [[stage_in]], constant Uniforms &uniforms [[buffer(UniformBufferIndex)]]) {
    float4 worldPosition = uniforms.modelMatrix * vertex_in.position;
    
    VertexOut out {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * worldPosition,
        .fragPosition = worldPosition.xyz,
        .normal = (uniforms.modelMatrix * float4(vertex_in.normal, 1.0)).xyz,
        .uv = vertex_in.uv
    };
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]], constant Params &params [[buffer(ParamBufferIndex)]], texture2d<float> baseColorTexture [[texture(BaseColorTextureIndex)]]) {
    constexpr sampler textureSampler(filter::linear, mip_filter::linear, max_anisotropy(8), address::repeat);
    float3 baseColor = baseColorTexture.sample(textureSampler, in.uv).rgb;
    
    float3 ambient = params.ambientStrength * baseColor;
    
    float3 normal = normalize(in.normal);
    float3 lightDirection = normalize(params.lightPosition - normal);
    
    float diff = max(dot(normal, lightDirection), 0.0);
    float3 diffuse = diff * baseColor;
    
    vector_float3 color = ambient + diffuse;
    return float4(color, 1.0);
}

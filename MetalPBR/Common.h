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

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef enum {
    VertexBufferIndex = 0,
    TangentBufferIndex = 1,
    BitangentBufferIndex = 2,
    UniformBufferIndex = 3,
    ParamBufferIndex = 4,
} BufferIndices;

typedef enum {
    PositionIndex = 0,
    NormalIndex = 1,
    UVIndex = 2,
    TangentIndex = 3,
    BitangentIndex = 4
} AttributeIndices;

typedef enum {
    BaseColorTextureIndex = 0,
    EmissiveTextureIndex = 1,
    MetallicTextureIndex = 2,
    RoughnessTextureIndex = 3,
    NormalTextureIndex = 4,
    OcclusionTextureIndex = 5,
    OpacityTextureIndex = 6,
    ClearcoatTextureIndex = 7,
    ClearcoatRoughnessTextureIndex = 8
} TextureIndices;

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
    simd_float3 lightPosition;
    simd_float3 viewPosition;
} Uniforms;

typedef struct {
    uint width;
    uint height;
    float ambientStrength;
} Params;

#endif /* Common_h */

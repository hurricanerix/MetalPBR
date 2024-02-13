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

#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
typedef metal::int32_t EnumBackingType;
#else
#import <Foundation/Foundation.h>
typedef NSInteger EnumBackingType;
#endif

#import <simd/simd.h>

typedef NS_ENUM(EnumBackingType, BufferIndices) {
    BufferIndicesVertex = 0,
    BufferIndicesTangent = 1,
    BufferIndicesBitangent = 2,
    BufferIndicesUniforms = 3,
    BufferIndicesParams = 4,
};

typedef NS_ENUM(EnumBackingType, AttributeIndices) {
    AttributeIndicesPosition = 0,
    AttributeIndicesNormal = 1,
    AttributeIndicesTexCoords = 2,
    AttributeIndicesTangent = 3,
    AttributeIndicesBitangent = 4
};

typedef NS_ENUM(EnumBackingType, TextureIndices) {
    TextureIndicesBaseColor = 0,
    TextureIndicesEmissive = 1,
    TextureIndicesMetallic = 2,
    TextureIndicesRoughness = 3,
    TextureIndicesNormal = 4,
    TextureIndicesOcclusion = 5,
    TextureIndicesOpacity = 6,
    TextureIndicesClearcoat = 7,
    TextureIndicesClearcoatRoughness = 8
};

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

#endif /* ShaderTypes_h */

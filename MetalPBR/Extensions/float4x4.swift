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

import simd

private let  piBy180: Float = Float.pi / 180

extension float4x4 {
    
    static func translate(by v: SIMD3<Float>) -> float4x4 {
        return float4x4(
            [1,   0,   0,   0],
            [0,   1,   0,   0],
            [0,   0,   1,   0],
            [v.x, v.y, v.z, 1])
    }
    
    static func scale(to v: SIMD3<Float>) -> float4x4 {
        return float4x4(
            [v.x, 0,   0,   0],
            [0,   v.y, 0,   0],
            [0,   0,   v.z, 0],
            [0,   0,   0,   1]
        )
    }
    
    static func scale(to s: Float) -> float4x4 {
        return float4x4(
            [s, 0, 0, 0],
            [0, s, 0, 0],
            [0, 0, s, 0],
            [0, 0, 0, 1]
        )
    }
    
    static func rotate(eulerX degrees: Float) -> float4x4 {
        let radians: Float = degrees * piBy180
        return float4x4(
            [1,           0,          0, 0],
            [0,  cos(radians), sin(radians), 0],
            [0, -sin(radians), cos(radians), 0],
            [0,           0,          0, 1]
        )
    }
    
    static func rotate(eulerY degrees: Float) -> float4x4 {
        let radians: Float = degrees * piBy180
        return float4x4(
            [cos(radians), 0, -sin(radians), 0],
            [         0, 1,           0, 0],
            [sin(radians), 0,  cos(radians), 0],
            [         0, 0,           0, 1]
        )
    }
    
    static func rotate(eulerZ degrees: Float) -> float4x4 {
        let radians: Float = degrees * piBy180
        return float4x4(
            [ cos(radians), sin(radians), 0, 0],
            [-sin(radians), cos(radians), 0, 0],
            [          0,          0, 1, 0],
            [          0,          0, 0, 1]
        )
    }
    
    static func rotate(eulers degrees: SIMD3<Float>) -> float4x4 {
        return rotate(eulerX: degrees.x) * rotate(eulerY: degrees.y) * rotate(eulerZ: degrees.z)
    }
    
    static func viewMatrix(translation: SIMD3<Float>, rotation: SIMD3<Float>) ->
    float4x4 {
        let translationMatrix = float4x4.translate(by: translation)
        let rotationMatrix = float4x4.rotate(eulers: rotation)
        return (translationMatrix * rotationMatrix).inverse
    }
    
    static func projectionMatrix(fov: Float, near: Float, far: Float, aspect: Float) -> float4x4 {
        let fov = 45 * piBy180
        var matrix = float4x4()
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = far / (far - near)
        let X = SIMD4<Float>( x,  0,  0,  0)
        let Y = SIMD4<Float>( 0,  y,  0,  0)
        let Z = SIMD4<Float>( 0,  0,  z, 1)
        let W = SIMD4<Float>( 0,  0,  z * -near,  0)
        matrix.columns = (X, Y, Z, W)
        return matrix
    }
    
}

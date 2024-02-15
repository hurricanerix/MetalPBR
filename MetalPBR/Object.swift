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

import Foundation
import simd

class Object: ObservableObject {
    @Published var position: SIMD3<Float> = SIMD3<Float>(0.0, 0.0, 0.0)
    @Published var rotation: SIMD3<Float> = SIMD3<Float>(0.0, 0.0, 0.0)
    @Published var scale: SIMD3<Float> = SIMD3<Float>(1.0, 1.0, 1.0)
    
    var autorotate: Bool = true
    var speed: Float = 5
    
    var modelMatrix: float4x4{
        get {
            var m = matrix_identity_float4x4
            m = m * float4x4.translate(by: position)
            m = m * float4x4.rotate(eulerX: rotation.x) * float4x4.rotate(eulerY: rotation.y) * float4x4.rotate(eulerZ: rotation.z)
            m = m * float4x4.scale(to: scale)
            return m
        }
    }
    
    func update(_ deltaTime: Float) {
        if !autorotate {
            return
        }
        
        rotation += SIMD3<Float>(10.0 * speed * deltaTime,
                                 7.0 * speed * deltaTime,
                                 3.0 * speed * deltaTime)
        if rotation.x > 360 {
            rotation.x = rotation.x - 360
        }
        if rotation.y > 360 {
            rotation.y = rotation.y - 360
        }
        if rotation.z > 360 {
            rotation.z = rotation.z - 360
        }
    }
}

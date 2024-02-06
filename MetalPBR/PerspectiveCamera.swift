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

import SwiftUI
import simd

class PerspectiveCamera: ObservableObject {
    internal static let  piBy180: Float = Float.pi / 180
    
    @Published var viewMatrix: float4x4
    @Published var projectionMatrix: float4x4
    
    var position: SIMD3<Float>
    var rotation: SIMD3<Float> = [0.0, 1.0, 0.0]
    var fov: Float
    var near: Float
    var far: Float
    var aspect: Float
    
    init(position: SIMD3<Float> = [0.0, 0.0, -5.0],
         rotation: SIMD3<Float> = [0.0, 1.0, 0.0],
         fov: Float = 45,
         near: Float = 0.1,
         far: Float = 100,
         aspect: Float = 4/3) {
        self.position = position
        self.rotation = rotation
        self.fov = fov
        self.near = near
        self.far = far
        self.aspect = aspect
        
        viewMatrix = float4x4()
        projectionMatrix = float4x4()
        
        updateViewMatrix()
        updateProjectionMatrix()
    }
    
    func set(position newPosition: SIMD3<Float>) {
        position = newPosition
        updateViewMatrix()
    }
    
    func set(rotation newRotation: SIMD3<Float>) {
        rotation = newRotation
        updateViewMatrix()
    }
    
    func set(fov newFOV: Float) {
        fov = newFOV
        updateProjectionMatrix()
    }
    
    func set(near newNear: Float) {
        near = newNear
        updateProjectionMatrix()
    }
    
    func set(far newFar: Float) {
        far = newFar
        updateProjectionMatrix()
    }
    
    func set(aspect newAspect: Float) {
        aspect = newAspect
        updateProjectionMatrix()
    }
    
    func updateViewMatrix() {
        viewMatrix = PerspectiveCamera.calculateViewMatrix(translation: position, rotation: rotation)
    }
    
    func updateProjectionMatrix() {
        projectionMatrix = PerspectiveCamera.calculateProjectionMatrix(fov: fov, near: near, far: far, aspect: aspect)
    }
    
    internal static func calculateViewMatrix(translation: SIMD3<Float>, rotation: SIMD3<Float>) ->
    float4x4 {
        let translationMatrix = float4x4.translate(by: translation)
        let rotationMatrix = float4x4.rotate(eulers: rotation)
        return (translationMatrix * rotationMatrix).inverse
    }
    
    internal static func calculateProjectionMatrix(fov: Float, near: Float, far: Float, aspect: Float) -> float4x4 {
        let fovRadians = fov * PerspectiveCamera.piBy180
        var matrix = float4x4()
        let y = 1 / tan(fovRadians * 0.5)
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

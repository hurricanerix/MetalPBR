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

import XCTest
@testable import MetalPBR

final class float4x4Tests: XCTestCase {
    let accuracy: Float = 0.001
    
    // TODO: Create extension to allow testing equality of matrices rather than individual components.
    
    func testTranslate_XYZ_ReturnsCorrectMatrix() throws {
        // given
        let x: Float = 2.0
        let y: Float = 3.0
        let z: Float = 4.0
        
        // when
        let m = float4x4.translate(by: [x, y, z])
        
        // then
        XCTAssertEqual(m.columns.0.x, 1.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.1.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.y, 1.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.2.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.z, 1.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.3.x, x, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.y, y, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.z, z, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.w, 1.0, accuracy: accuracy)
    }
    
    func testScale_WithVector_ReturnsCorrectMatrix() throws {
        // given
        let xScale: Float = 2.0
        let yScale: Float = 3.0
        let zScale: Float = 4.0
        let scale: SIMD3<Float> = [xScale, yScale, zScale]
        
        // when
        let m = float4x4.scale(to: scale)
        
        // then
        XCTAssertEqual(m.columns.0.x, xScale, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.1.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.y, yScale, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.2.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.z, zScale, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.3.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.w, 1.0, accuracy: accuracy)
    }
    
    func testScale_WithFloat_ReturnsCorrectMatrix() throws {
        // given
        let scale: Float = 2.0
        
        // when
        let m = float4x4.scale(to: scale)
        
        // then
        XCTAssertEqual(m.columns.0.x, scale, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.1.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.y, scale, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.2.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.z, scale, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.3.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.w, 1.0, accuracy: accuracy)
    }
    
    func testRotate_WithEulerX_ReturnsCorrectMatrix() throws {
        // given
        let angle: Float = 45.0
        
        // when
        let m = float4x4.rotate(eulerX: angle)
        
        // then
        XCTAssertEqual(m.columns.0.x, 1.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.1.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.y, 0.707, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.z, 0.707, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.2.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.y, -0.707, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.z, 0.707, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.3.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.w, 1.0, accuracy: accuracy)
    }
    
    func testRotate_WithEulerY_ReturnsCorrectMatrix() throws {
        // given
        let angle: Float = 45.0
        
        // when
        let m = float4x4.rotate(eulerY: angle)
        
        // then
        XCTAssertEqual(m.columns.0.x, 0.707, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.z, -0.707, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.1.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.y, 1.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.2.x, 0.707, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.z, 0.707, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.3.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.w, 1.0, accuracy: accuracy)
    }
    
    func testRotate_WithEulerZ_ReturnsCorrectMatrix() throws {
        // given
        let angle: Float = 45.0
        
        // when
        let m = float4x4.rotate(eulerZ: angle)
        
        // then
        XCTAssertEqual(m.columns.0.x, 0.707, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.y, 0.707, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.1.x, -0.707, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.y, 0.707, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.2.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.z, 1.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.3.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.w, 1.0, accuracy: accuracy)
    }
    
    func testRotate_WithEulers_ReturnsCorrectMatrix() throws {
        // given
        let xAngle: Float = 45.0
        let yAngle: Float = 45.0
        let zAngle: Float = 45.0
        let angles: SIMD3<Float> = [xAngle, yAngle, zAngle]
        
        // when
        let m = float4x4.rotate(eulers: angles)
        
        // then
        XCTAssertEqual(m.columns.0.x, 0.499, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.y, 0.853, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.z, 0.146, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.1.x, -0.5, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.y, 0.146, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.z, 0.853, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.2.x, 0.707, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.y, -0.5, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.z, 0.499, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.3.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.w, 1.0, accuracy: accuracy)
    }
    
    func testViewMatrix_WithTranslationAndRotation_ReturnsCorrectMatrix() throws {
        // given
        let translation: SIMD3<Float> = [0.0, 0.0, -5]
        let rotation: SIMD3<Float> = [0.0, 1.0, 0.0]
    
        // when
        let m = float4x4.viewMatrix(translation: translation, rotation: rotation)
        
        // then
        XCTAssertEqual(m.columns.0.x, 0.999, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.z, 0.017, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.1.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.y, 1.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.2.x, -0.017, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.z, 0.999, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.3.x, -0.087, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.z, 4.999, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.w, 1.0, accuracy: accuracy)
    }
    
    func testProjectionMatrix_WithPerspective_ReturnsCorrectMatrix() throws {
        // given
        let fov: Float = 0.785
        let near: Float = 0.1
        let far: Float = 100
        let aspect: Float = 9/19.5
    
        // when
        let m = float4x4.projectionMatrix(fov: fov, near: near, far: far, aspect: aspect)
        
        // then
        XCTAssertEqual(m.columns.0.x, 5.230, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.1.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.y, 2.414, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.2.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.z, 1.001, accuracy: accuracy)
        XCTAssertEqual(m.columns.2.w, 1.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.3.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.z, -0.1, accuracy: accuracy)
        XCTAssertEqual(m.columns.3.w, 0.0, accuracy: accuracy)
    }
    
    
    
}

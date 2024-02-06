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

final class PerspectiveCameraTests: XCTestCase {
    let accuracy: Float = 0.001
    
    func testViewMatrix_WithTranslationAndRotation_ReturnsCorrectMatrix() throws {
        // given
        let position: SIMD3<Float> = [0.0, 0.0, -5]
        let rotation: SIMD3<Float> = [0.0, 1.0, 0.0]
        
        // when
        let m = PerspectiveCamera.calculateViewMatrix(translation: position, rotation: rotation)
        
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
        let m = PerspectiveCamera.calculateProjectionMatrix(fov: fov, near: near, far: far, aspect: aspect)
        
        // then
        XCTAssertEqual(m.columns.0.x, 316.277, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.y, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.z, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.0.w, 0.0, accuracy: accuracy)
        
        XCTAssertEqual(m.columns.1.x, 0.0, accuracy: accuracy)
        XCTAssertEqual(m.columns.1.y, 145.974, accuracy: accuracy)
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

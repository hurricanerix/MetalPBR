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
import simd
@testable import MetalPBR

final class SIMD3FloatTests: XCTestCase {
    let accuracy: Float = 0.001
    
    func testRGB_Gets_CorrectComponentValues() throws {
        // given
        let red: Float = 1.0
        let blue: Float = 2.0
        let green: Float = 3.0
        
        // when
        let color = SIMD3<Float>(red, green, blue)
        
        // then
        XCTAssertEqual(color.r, red, accuracy: accuracy)
        XCTAssertEqual(color.g, green, accuracy: accuracy)
        XCTAssertEqual(color.b, blue, accuracy: accuracy)
    }
    
    func testR_Sets_CorrectRedComponent() throws {
        // given
        var color = SIMD3<Float>(0.0, 0.0, 0.0)
        let newValue: Float = 1.0

        // when
        color.r = newValue
        
        // then
        XCTAssertEqual(color.r, newValue, accuracy: accuracy)
        XCTAssertEqual(color.g, 0.0, accuracy: accuracy)
        XCTAssertEqual(color.b, 0.0, accuracy: accuracy)
    }
    
    func testG_Sets_CorrectGreenComponent() throws {
        // given
        var color = SIMD3<Float>(0.0, 0.0, 0.0)
        let newValue: Float = 1.0

        // when
        color.g = newValue
        
        // then
        XCTAssertEqual(color.r, 0.0, accuracy: accuracy)
        XCTAssertEqual(color.g, newValue, accuracy: accuracy)
        XCTAssertEqual(color.b, 0.0, accuracy: accuracy)
    }
    
    func testB_Sets_CorrectBlueComponent() throws {
        // given
        var color = SIMD3<Float>(0.0, 0.0, 0.0)
        let newValue: Float = 1.0

        // when
        color.b = newValue
        
        // then
        XCTAssertEqual(color.r, 0.0, accuracy: accuracy)
        XCTAssertEqual(color.g, 0.0, accuracy: accuracy)
        XCTAssertEqual(color.b, newValue, accuracy: accuracy)
    }
}

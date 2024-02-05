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
import SwiftUI
@testable import MetalPBR

final class ColorTests: XCTestCase {
    let accuracy: Float = 0.1
    
    func testColor_ForBlack_ReturnsCorrectRGBA() throws {
        // given
        let color = Color.black
        
        // when
        let rgba = color.rgba()
        
        // then
        XCTAssertEqual(rgba[0], 0.0, accuracy: accuracy, "red")
        XCTAssertEqual(rgba[1], 0.0, accuracy: accuracy, "green")
        XCTAssertEqual(rgba[2], 0.0, accuracy: accuracy, "blue")
        XCTAssertEqual(rgba[3], 1.0, accuracy: accuracy, "alpha")
    }
    
    func testColor_ForWhite_ReturnsCorrectRGBA() throws {
        // given
        let color = Color.white
        
        // when
        let rgba = color.rgba()
        
        // then
        XCTAssertEqual(rgba[0], 1.0, accuracy: accuracy, "red")
        XCTAssertEqual(rgba[1], 1.0, accuracy: accuracy, "green")
        XCTAssertEqual(rgba[2], 1.0, accuracy: accuracy, "blue")
        XCTAssertEqual(rgba[3], 1.0, accuracy: accuracy, "alpha")
    }
    
    func testColor_ForRed_ReturnsCorrectRGBA() throws {
        // given
        let color = Color.red
        
        // when
        let rgba = color.rgba()
        
        // then
        XCTAssertEqual(rgba[0], 1.0, accuracy: accuracy, "red")
        XCTAssertEqual(rgba[1], 0.2, accuracy: accuracy, "green")
        XCTAssertEqual(rgba[2], 0.1, accuracy: accuracy, "blue")
        XCTAssertEqual(rgba[3], 1.0, accuracy: accuracy, "alpha")
    }
    
    func testColor_ForGreen_ReturnsCorrectRGBA() throws {
        // given
        let color = Color.green
        
        // when
        let rgba = color.rgba()
        
        // then
        XCTAssertEqual(rgba[0], 0.2, accuracy: accuracy, "red")
        XCTAssertEqual(rgba[1], 0.7, accuracy: accuracy, "green")
        XCTAssertEqual(rgba[2], 0.3, accuracy: accuracy, "blue")
        XCTAssertEqual(rgba[3], 1.0, accuracy: accuracy, "alpha")
    }
    
    func testColor_ForBlue_ReturnsCorrectRGBA() throws {
        // given
        let color = Color.blue
        
        // when
        let rgba = color.rgba()
        
        // then
        XCTAssertEqual(rgba[0], 0.0, accuracy: accuracy, "red")
        XCTAssertEqual(rgba[1], 0.4, accuracy: accuracy, "green")
        XCTAssertEqual(rgba[2], 1.0, accuracy: accuracy, "blue")
        XCTAssertEqual(rgba[3], 1.0, accuracy: accuracy, "alpha")
    }
}

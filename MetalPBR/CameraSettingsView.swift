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

struct CameraSettingsView: View {
    @EnvironmentObject var camera: PerspectiveCamera
    
    @State private var positionX: Float = 0
    @State private var positionY: Float = 0
    @State private var positionZ: Float = -5
    
    @State private var angleX: Float = 0
    @State private var angleY: Float = 1
    @State private var angleZ: Float = 0
    
    @State private var fov: Float = 45
    @State private var near: Float = 0.1
    @State private var far: Float = 100
    
    @State private var foo = 0
    
    var body: some View {
        VStack {
            PBRView(clearColor: .green)
            Form {
                HStack {
                    Text("Position")
                        .bold()
                    HStack {
                        TextField("X", value: $positionX, format: .number)
                        TextField("Y", value: $positionY, format: .number)
                        TextField("Z", value: $positionZ, format: .number)
                    }
                    .onSubmit {
                        let newPosition = SIMD3<Float>(positionX, positionY, positionZ)
                        camera.set(position: newPosition)
                    }
                }
                
                HStack {
                    Text("Rotation")
                        .bold()
                    HStack {
                        TextField("X", value: $angleX, format: .number)
                        TextField("Y", value: $angleY, format: .number)
                        TextField("Z", value: $angleZ, format: .number)
                    }
                    .onSubmit {
                        let newRotation = SIMD3<Float>(angleX, angleY, angleZ)
                        camera.set(rotation: newRotation)
                    }
                }
                
                
                HStack {
                    Text("FOV")
                        .bold()
                    TextField("45", value: $fov, format: .number)
                        .onSubmit {
                            camera.set(fov: fov)
                        }
                }
                HStack {
                    Text("Near")
                        .bold()
                    TextField("0.1", value: $near, format: .number)
                        .onSubmit {
                            camera.set(near: near)
                        }
                }
                HStack {
                    Text("Far")
                        .bold()
                    TextField("0.1", value: $far, format: .number)
                        .onSubmit {
                            camera.set(far: far)
                        }
                }
            }
        }
    }
}

#Preview {
    CameraSettingsView()
        .environmentObject(PerspectiveCamera())
}

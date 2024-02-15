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
    
    var body: some View {
        VStack {
            PBRView()
            HStack {
                GroupBox(label: Label(
                    title: { Text("Position") },
                    icon: { Image(systemName: "move.3d") }
                )) {
                    HStack {
                        TextField("X", value: $camera.position.x, format: .number)
                        TextField("Y", value: $camera.position.y, format: .number)
                        TextField("Z", value: $camera.position.z, format: .number)
                    }
                }
            }
            GroupBox(label: Label(
                title: { Text("Rotation") },
                icon: { Image(systemName: "rotate.3d") }
            )) {
                HStack {
                    HStack {
                        
                        TextField("X", value: $camera.rotation.x, format: .number)
                        
                        TextField("Y", value: $camera.rotation.y, format: .number)
                        
                        TextField("Z", value: $camera.rotation.z, format: .number)
                    }
                }
            }
            
            GroupBox(label: Label(
                title: { Text("Frustrum") },
                icon: { Image(systemName: "questionmark.circle") }
            )) {
                HStack {
                    Text("FOV")
                        .bold()
                    TextField("45", value: $camera.fov, format: .number)
                }
                HStack {
                    Text("Near")
                        .bold()
                    TextField("0.1", value: $camera.near, format: .number)
                }
                HStack {
                    Text("Far")
                        .bold()
                    TextField("0.1", value: $camera.far, format: .number)
                }
            }
        }
    }
}

#Preview {
    CameraSettingsView()
        .environmentObject(SceneEnvironment())
        .environmentObject(PerspectiveCamera())
}

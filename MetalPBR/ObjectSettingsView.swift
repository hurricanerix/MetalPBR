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

struct ObjectSettingsView: View {
    @EnvironmentObject var subject: Object
    
    var body: some View {
        VStack {
            PBRView()

            HStack {
                GroupBox(label: Label(
                    title: { Text("Position") },
                    icon: { Image(systemName: "move.3d") }
                )) {
                    HStack {
                        TextField("X", value: $subject.position.x, format: .number)
                        TextField("Y", value: $subject.position.y, format: .number)
                        TextField("Z", value: $subject.position.z, format: .number)
                    }
                }
            }
            
            HStack {
                GroupBox(label: Label(
                    title: { Text("Rotation") },
                    icon: { Image(systemName: "rotate.3d") }
                )) {
                    HStack {
                        
                        TextField("X", value: $subject.rotation.x, format: .number)
                        TextField("Y", value: $subject.rotation.y, format: .number)
                        TextField("Z", value: $subject.rotation.z, format: .number)
                    }
                    Toggle(isOn: $subject.autorotate) {
                        Text("Auto Rotate")
                    }
                }
            }
            
            HStack {
                GroupBox(label: Label(
                    title: { Text("Scale") },
                    icon: { Image(systemName: "scale.3d") }
                )) {
                    HStack {
                        TextField("X", value: $subject.scale.x, format: .number)
                        TextField("Y", value: $subject.scale.y, format: .number)
                        TextField("Z", value: $subject.scale.z, format: .number)
                    }
                }
            }
        }
    }
}

#Preview {
    ObjectSettingsView()
        .environmentObject(SceneEnvironment())
        .environmentObject(PerspectiveCamera())
        .environmentObject(Object())
}

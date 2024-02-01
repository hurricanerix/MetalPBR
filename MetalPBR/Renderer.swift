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

import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    var mesh: MTKMesh!
    
    var pipelineState: MTLRenderPipelineState!
    
    init(metalView: MTKView) {
        // MARK: Initialize Metal
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("TODO: Handle case where GPU is not supported")
        }
        Self.device = device
        metalView.device = device
                
        // MARK: Load a model
        let allocator = MTKMeshBufferAllocator(device: device)
        let mdlMesh = MDLMesh(boxWithExtent: [1, 1, 1], segments: [4, 4, 4], inwardNormals: false, geometryType: .triangles, allocator: allocator)
        do {
            let mesh = try MTKMesh(mesh: mdlMesh, device: device)
            self.mesh = mesh
        } catch {
            fatalError("TODO: Handle case where MDLMesh could not be converted to MTKMesh")
        }
        
        // MARK: Set up the pipeline
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("TODO: Handle case where command queue could not be created")
        }
        Self.commandQueue = commandQueue
        
        let library = device.makeDefaultLibrary()
        Self.library = library
        let vertexFunction = Self.library.makeFunction(name: "vertex_main")
        let fragmentFunction = Self.library.makeFunction(name: "fragment_main")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(self.mesh.vertexDescriptor)
        do {
            let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            self.pipelineState = pipelineState
        } catch {
            fatalError("TODO: Handle case where pipeline state could not be created")
        }
        
        super.init()
        metalView.clearColor = MTLClearColor(red: 0.254, green: 0.410, blue: 0.879, alpha: 1)
        metalView.delegate = self
    }
}

// MARK: MTKViewDelegate Implementation

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // TODO: Handle resize events.
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = Self.commandQueue.makeCommandBuffer(),
                let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else {
            fatalError("TODO: Handle case where command buffer could not be created")
        }
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(
            self.mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: submesh.indexCount,
                indexType: submesh.indexType,
                indexBuffer: submesh.indexBuffer.buffer,
                indexBufferOffset: submesh.indexBuffer.offset)
        }
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            fatalError("TODO: Handle case where could not get currentDrawable")
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

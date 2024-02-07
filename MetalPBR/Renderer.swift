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
    let speed: Float = 5
    
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    
    var lastTime: Double = CFAbsoluteTimeGetCurrent()
    var mesh: MTKMesh!
    var pipelineState: MTLRenderPipelineState!
    var uniforms: Uniforms
    var params: Params
    var xRotation: Float
    var yRotation: Float
    var zRotation: Float
    var cameraPosition: SIMD3<Float>
    var camera: PerspectiveCamera
    
    init(metalView: MTKView, clearColor: SIMD4<Float>, camera: PerspectiveCamera) {
        // MARK: Create device
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("TODO: Handle case where GPU is not supported")
        }
        Self.device = device
        metalView.device = device
        
        // MARK: Load a model
        let allocator = MTKMeshBufferAllocator(device: device)
//        let mdlMesh = MDLMesh(boxWithExtent: [1, 1, 1], segments: [1, 1, 1], inwardNormals: false, geometryType: .triangles, allocator: allocator)
        guard let assetURL = Bundle.main.url(forResource: "cube", withExtension: "usdz") else {
            fatalError("TODO: Handle case where model could not be loaded")
        }
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = Int(VertexIndex.rawValue)
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride
        let meshDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        (meshDescriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        let asset = MDLAsset(url: assetURL, vertexDescriptor: meshDescriptor, bufferAllocator: allocator)
        let mdlMesh = asset.childObjects(of: MDLMesh.self).first as! MDLMesh
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

        // MARK: Initialize stored properties
        
        uniforms = Uniforms()
        params = Params()
        cameraPosition = SIMD3<Float>(0, 0, -10)
        xRotation = 0.0
        yRotation = 0.0
        zRotation = 0.0
        self.camera = camera
        
        super.init()
        
        metalView.clearColor = MTLClearColor(red: Double(clearColor[0]), green: Double(clearColor[1]), blue: Double(clearColor[2]), alpha: Double(clearColor[3]))
        metalView.delegate = self
        
        mtkView(
            metalView,
            drawableSizeWillChange: metalView.drawableSize)
    }
}

// MARK: MTKViewDelegate

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        camera.set(aspect: Float(size.width/size.height))
    }
    
    func draw(in view: MTKView) {
        // MARK: Create Command Buffer
        guard let commandBuffer = Self.commandQueue.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else {
            fatalError("TODO: Handle case where command buffer could not be created")
        }
        
        // MARK: Update
        let currentTime = CFAbsoluteTimeGetCurrent()
        let deltaTime = Float(currentTime - lastTime)
        lastTime = currentTime
        
        xRotation += 10.0 * speed * deltaTime
        yRotation += 7.0 * speed * deltaTime
        zRotation += 3.0 * speed * deltaTime
        let modelMatrix = float4x4.rotate(eulerX: xRotation) * float4x4.rotate(eulerY: yRotation) * float4x4.rotate(eulerZ: zRotation)
        
        // MARK: Update buffer data
        uniforms.modelMatrix = modelMatrix
        uniforms.viewMatrix = camera.viewMatrix
        uniforms.projectionMatrix = camera.projectionMatrix
        params.cameraPosition = cameraPosition
        
        // MARK: Set Pipeline State
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // MARK: Set Buffer Data
        renderEncoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            index: Int(UniformsIndex.rawValue))
        
        renderEncoder.setFragmentBytes(
            &params,
            length: MemoryLayout<Params>.stride,
            index: Int(ParamsIndex.rawValue))
        
        renderEncoder.setVertexBuffer(
            self.mesh.vertexBuffers[0].buffer, offset: 0, index: Int(VertexIndex.rawValue))
        
        // MARK: Render
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: submesh.indexCount,
                indexType: submesh.indexType,
                indexBuffer: submesh.indexBuffer.buffer,
                indexBufferOffset: submesh.indexBuffer.offset)
        }
        
        // MARK: End Encoding
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            fatalError("TODO: Handle case where could not get currentDrawable")
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

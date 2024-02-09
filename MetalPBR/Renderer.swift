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
    var depthStencilState: MTLDepthStencilState!
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
        guard let assetURL = Bundle.main.url(forResource: "cube", withExtension: "usdz") else {
            fatalError("TODO: Handle case where model could not be loaded")
        }
        
        let mdlVertexDescriptor = MDLVertexDescriptor()
        var offset = 0
        mdlVertexDescriptor.attributes[Int(PositionIndex.rawValue)] = MDLVertexAttribute(
            name: MDLVertexAttributePosition,
            format: .float3,
            offset: 0,
            bufferIndex: Int(VertexBufferIndex.rawValue))
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        mdlVertexDescriptor.attributes[Int(NormalIndex.rawValue)] = MDLVertexAttribute(
            name: MDLVertexAttributeNormal,
            format: .float3,
            offset: offset,
            bufferIndex: Int(VertexBufferIndex.rawValue))
        offset += MemoryLayout<SIMD3<Float>>.stride
        mdlVertexDescriptor.layouts[Int(VertexBufferIndex.rawValue)]
        = MDLVertexBufferLayout(stride: offset)
        
        mdlVertexDescriptor.attributes[Int(UVIndex.rawValue)] = MDLVertexAttribute(
            name: MDLVertexAttributeTextureCoordinate,
            format: .float2,
            offset: offset,
            bufferIndex: Int(VertexBufferIndex.rawValue))
        
        mdlVertexDescriptor.layouts[Int(VertexBufferIndex.rawValue)] = MDLVertexBufferLayout(stride: MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD2<Float>>.stride)
        
        let mtlVertexDescriptor = MTLVertexDescriptor()
        
        mtlVertexDescriptor.attributes[Int(PositionIndex.rawValue)].format = .float3
        mtlVertexDescriptor.attributes[Int(PositionIndex.rawValue)].offset = 0
        mtlVertexDescriptor.attributes[Int(PositionIndex.rawValue)].bufferIndex = Int(VertexBufferIndex.rawValue)
        
        mtlVertexDescriptor.attributes[Int(NormalIndex.rawValue)].format = .float3
        mtlVertexDescriptor.attributes[Int(NormalIndex.rawValue)].offset = 3
        mtlVertexDescriptor.attributes[Int(NormalIndex.rawValue)].bufferIndex = Int(VertexBufferIndex.rawValue)
        
        mtlVertexDescriptor.attributes[Int(UVIndex.rawValue)].format = .float3
        mtlVertexDescriptor.attributes[Int(UVIndex.rawValue)].offset = 6
        mtlVertexDescriptor.attributes[Int(UVIndex.rawValue)].bufferIndex = Int(VertexBufferIndex.rawValue)
        
        mtlVertexDescriptor.layouts[Int(VertexBufferIndex.rawValue)].stride = MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD2<Float>>.stride
        
        let asset = MDLAsset(url: assetURL, vertexDescriptor: mdlVertexDescriptor, bufferAllocator: allocator)
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
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        do {
            let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            self.pipelineState = pipelineState
        } catch {
            fatalError("TODO: Handle case where pipeline state could not be created")
        }
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
        
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
        metalView.depthStencilPixelFormat = .depth32Float
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
        params.ambientStrength = 0.1
        params.ambientColor = SIMD3<Float>(1.0, 1.0, 1.0)
        params.lightPosition = SIMD3<Float>(-1.0, 10.0, -5.0)
        params.lightColor = SIMD3<Float>(0.2, 0.2, 0.8)
        
        // MARK: Set Pipeline State
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // MARK: Set Buffer Data
        renderEncoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            index: Int(UniformBufferIndex.rawValue))
        
        renderEncoder.setFragmentBytes(
            &params,
            length: MemoryLayout<Params>.stride,
            index: Int(ParamBufferIndex.rawValue))
        
        renderEncoder.setVertexBuffer(
            self.mesh.vertexBuffers[0].buffer, offset: 0, index: Int(VertexBufferIndex.rawValue))
        
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

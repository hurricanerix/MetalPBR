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
    
    static var metalView: MTKView!
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    
    var environment: SceneEnvironment
    var camera: PerspectiveCamera
    
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
    
    var baseColor: MTLTexture?
    var normal: MTLTexture?
    
    init(metalView: MTKView, camera: PerspectiveCamera, environment: SceneEnvironment) {
        Self.metalView = metalView
        Self.device = metalView.device

        guard let commandQueue = Self.device.makeCommandQueue() else {
            fatalError("TODO: Handle case where command queue could not be created")
        }
        Self.commandQueue = commandQueue
        
        let mtlVertexDescriptor = Renderer.buildMetalVertexDescriptor()
        
        do {
            pipelineState = try Renderer.buildRenderPipelineWithDevice(device: Self.device,
                                                                       mtlVertexDescriptor: mtlVertexDescriptor)
        } catch {
            fatalError("Unable to compile render pipeline state.  Error info: \(error)")
        }
    
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = Self.device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    
        let mdlMesh: MDLMesh
        do {
            mdlMesh = try Renderer.buildMesh(device: Self.device)
        } catch {
            fatalError("Unable to build MetalKit Mesh. Error info: \(error)")
        }
        
        do {
            self.mesh = try MTKMesh(mesh: mdlMesh, device: Self.device)
        } catch {
            fatalError("Unable to build MetalKit Mesh. Error info: \(error)")
        }
        
        uniforms = Uniforms()
        params = Params()
        cameraPosition = SIMD3<Float>(0, 0, -10)
        xRotation = 0.0
        yRotation = 0.0
        zRotation = 0.0
        
        self.camera = camera
        self.environment = environment
        
        super.init()
        
        for s in mdlMesh.submeshes! {
            let submesh = s as! MDLSubmesh?
            if submesh == nil {
                continue
            }
            
            if let property = submesh?.material?.property(with: .baseColor), property.type == .texture, let mdlTexture = property.textureSamplerValue?.texture {
                baseColor = try? Renderer.loadTexture(device: Self.device, mdlTexture: mdlTexture)
            }
            
            if let property = submesh?.material?.property(with: .tangentSpaceNormal), property.type == .texture, let mdlTexture = property.textureSamplerValue?.texture {
                normal = try? Renderer.loadTexture(device: Self.device, mdlTexture: mdlTexture)
            }
        }
        
        updateClearColor()
        
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.delegate = self
        
        mtkView(
            metalView,
            drawableSizeWillChange: metalView.drawableSize)
    }
    
    func updateClearColor() {
        Self.metalView.clearColor = MTLClearColor(red: Double(environment.backgroundColor.r), green: Double(environment.backgroundColor.g), blue: Double(environment.backgroundColor.b), alpha: 1.0)
    }
    
    class func buildMetalVertexDescriptor() -> MTLVertexDescriptor  {
        // Create a Metal vertex descriptor specifying how vertices will by laid out for input into our render
        //   pipeline and how we'll layout our Model IO vertices
        
        let descriptor = MTLVertexDescriptor()
        var offset = 0
        
        descriptor.attributes[AttributeIndices.position.rawValue].format = .float3
        descriptor.attributes[AttributeIndices.position.rawValue].offset = offset
        descriptor.attributes[AttributeIndices.position.rawValue].bufferIndex = BufferIndices.vertex.rawValue
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        descriptor.attributes[AttributeIndices.normal.rawValue].format = .float3
        descriptor.attributes[AttributeIndices.normal.rawValue].offset = offset
        descriptor.attributes[AttributeIndices.normal.rawValue].bufferIndex = BufferIndices.vertex.rawValue
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        descriptor.attributes[AttributeIndices.texCoords.rawValue].format = .float2
        descriptor.attributes[AttributeIndices.texCoords.rawValue].offset = offset
        descriptor.attributes[AttributeIndices.texCoords.rawValue].bufferIndex = BufferIndices.vertex.rawValue
        offset += MemoryLayout<SIMD2<Float>>.stride
        descriptor.layouts[BufferIndices.vertex.rawValue].stride = offset
        
        descriptor.attributes[AttributeIndices.tangent.rawValue].format = .float3
        descriptor.attributes[AttributeIndices.tangent.rawValue].offset = 0
        descriptor.attributes[AttributeIndices.tangent.rawValue].bufferIndex = BufferIndices.tangent.rawValue
        descriptor.layouts[BufferIndices.tangent.rawValue].stride = MemoryLayout<SIMD3<Float>>.stride

        descriptor.attributes[AttributeIndices.bitangent.rawValue].format = .float3
        descriptor.attributes[AttributeIndices.bitangent.rawValue].offset = 0
        descriptor.attributes[AttributeIndices.bitangent.rawValue].bufferIndex = BufferIndices.bitangent.rawValue
        descriptor.layouts[BufferIndices.bitangent.rawValue].stride = MemoryLayout<SIMD3<Float>>.stride
        
        return descriptor
    }
    
    class func buildRenderPipelineWithDevice(device: MTLDevice,
                                             mtlVertexDescriptor: MTLVertexDescriptor) throws -> MTLRenderPipelineState {
        /// Build a render state pipeline object
        
        let library = device.makeDefaultLibrary()
        Self.library = library
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "RenderPipeline"
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = mtlVertexDescriptor
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    class func buildMesh(device: MTLDevice) throws -> MDLMesh {
        /// Create and condition mesh data to feed into a pipeline using the given vertex descriptor

        let allocator = MTKMeshBufferAllocator(device: Self.device)
        guard let assetURL = Bundle.main.url(forResource: "cube", withExtension: "usdz") else {
            fatalError("TODO: Handle case where model could not be loaded")
        }
        
        let mdlVertexDescriptor = MDLVertexDescriptor()
        var offset = 0
        mdlVertexDescriptor.attributes[AttributeIndices.position.rawValue] = MDLVertexAttribute(
            name: MDLVertexAttributePosition,
            format: .float3,
            offset: 0,
            bufferIndex: BufferIndices.vertex.rawValue)
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        mdlVertexDescriptor.attributes[AttributeIndices.normal.rawValue] = MDLVertexAttribute(
            name: MDLVertexAttributeNormal,
            format: .float3,
            offset: offset,
            bufferIndex: BufferIndices.vertex.rawValue)
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        mdlVertexDescriptor.attributes[AttributeIndices.texCoords.rawValue] = MDLVertexAttribute(
            name: MDLVertexAttributeTextureCoordinate,
            format: .float2,
            offset: offset,
            bufferIndex: BufferIndices.vertex.rawValue)
        offset += MemoryLayout<SIMD2<Float>>.stride
        
        mdlVertexDescriptor.layouts[BufferIndices.vertex.rawValue] = MDLVertexBufferLayout(stride: offset)
        
        mdlVertexDescriptor.attributes[AttributeIndices.tangent.rawValue] =
          MDLVertexAttribute(
            name: MDLVertexAttributeTangent,
            format: .float3,
            offset: 0,
            bufferIndex: BufferIndices.tangent.rawValue)
        mdlVertexDescriptor.layouts[BufferIndices.tangent.rawValue] = MDLVertexBufferLayout(stride: MemoryLayout<SIMD3<Float>>.stride)
        
        mdlVertexDescriptor.attributes[AttributeIndices.bitangent.rawValue] =
          MDLVertexAttribute(
            name: MDLVertexAttributeBitangent,
            format: .float3,
            offset: 0,
            bufferIndex: BufferIndices.bitangent.rawValue)
        mdlVertexDescriptor.layouts[BufferIndices.bitangent.rawValue]
          = MDLVertexBufferLayout(stride: MemoryLayout<SIMD3<Float>>.stride)
        
        let asset = MDLAsset(url: assetURL, vertexDescriptor: mdlVertexDescriptor, bufferAllocator: allocator)
        asset.loadTextures()
        let mdlMesh = asset.childObjects(of: MDLMesh.self).first as! MDLMesh

        mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, tangentAttributeNamed: MDLVertexAttributeTangent, bitangentAttributeNamed: MDLVertexAttributeBitangent)
        return mdlMesh
    }
    
    class func loadTexture(device: MTLDevice, mdlTexture: MDLTexture) throws -> MTLTexture {
        /// Load texture data with optimal parameters for sampling

        let textureLoader = MTKTextureLoader(device: device)

        let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [
            .origin: MTKTextureLoader.Origin.bottomLeft,
            .generateMipmaps: true,
            .textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            .textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
        ]

        return try textureLoader.newTexture(texture: mdlTexture,
                                            options: textureLoaderOptions)
    }
}

// MARK: MTKViewDelegate

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        camera.aspect = Float(size.width/size.height)
    }
    
    func draw(in view: MTKView) {
        do {
            try renderFrame(Self.commandQueue, view)
        }
        catch {
            fatalError("TODO: Handle case where frame can't be rendered")
        }
    }
    
    internal func renderFrame(_ commandQueue: MTLCommandQueue, _ view: MTKView) throws -> Void {
        // MARK: Create Command Buffer
        let commandBuffer = Self.commandQueue.makeCommandBuffer()!
        let renderPassDescriptor = view.currentRenderPassDescriptor!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        // MARK: Update
        let currentTime = CFAbsoluteTimeGetCurrent()
        let deltaTime = Float(currentTime - lastTime)
        lastTime = currentTime
        
        // TODO: Probably shouldn't do this every frame, but should work for now.
        updateClearColor()
        
        updateGameState(deltaTime)
        
        // MARK: Set Pipeline State
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // MARK: Set Buffer Data
        renderEncoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            index: BufferIndices.uniforms.rawValue)
        
        renderEncoder.setFragmentBytes(
            &params,
            length: MemoryLayout<Params>.stride,
            index: BufferIndices.params.rawValue)
        
        renderEncoder.setVertexBuffer(
            self.mesh.vertexBuffers[0].buffer, offset: 0, index: BufferIndices.vertex.rawValue)
        
        renderEncoder.setVertexBuffer(
            self.mesh.vertexBuffers[1].buffer, offset: 0, index: BufferIndices.tangent.rawValue)
        
        renderEncoder.setVertexBuffer(
            self.mesh.vertexBuffers[2].buffer, offset: 0, index: BufferIndices.bitangent.rawValue)
        
        // MARK: Render
        for submesh in mesh.submeshes {
            
            renderEncoder.setFragmentTexture(
              baseColor,
              index: TextureIndices.baseColor.rawValue)
            
            renderEncoder.setFragmentTexture(
              normal,
              index: TextureIndices.normal.rawValue)
            
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
    
    internal func updateGameState(_ deltaTime: Float) {
        xRotation += 10.0 * speed * deltaTime
        yRotation += 7.0 * speed * deltaTime
        zRotation += 3.0 * speed * deltaTime
        let modelMatrix = float4x4.rotate(eulerX: xRotation) * float4x4.rotate(eulerY: yRotation) * float4x4.rotate(eulerZ: zRotation)
        
        // MARK: Update buffer data
        uniforms.modelMatrix = modelMatrix
        uniforms.viewMatrix = camera.viewMatrix
        uniforms.projectionMatrix = camera.projectionMatrix
        uniforms.normalMatrix = getNormalMatrix(modelMatrix)
        uniforms.lightPosition = SIMD3<Float>(-1.0, 10.0, -5.0)
        uniforms.viewPosition = cameraPosition
        
        params.ambientStrength = 0.1
    }
}

func getNormalMatrix(_ modelMatrix: float4x4) -> float3x3 {
    return float3x3(
        [modelMatrix.columns.0.x, modelMatrix.columns.0.y, modelMatrix.columns.0.z],
        [modelMatrix.columns.1.x, modelMatrix.columns.1.y, modelMatrix.columns.1.z],
        [modelMatrix.columns.2.x, modelMatrix.columns.2.y, modelMatrix.columns.2.z]
    ).inverse.transpose
}

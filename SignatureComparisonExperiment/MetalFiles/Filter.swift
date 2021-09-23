//
//  Filter.swift
//  MetalAndImages
//
//  Created by Paul Mayer on 5/10/21.
//

import Metal
import MetalKit

// UIImage -> CGImage -> MTLTexture -> COMPUTE HAPPENS -> MTLTexture -> CGImage -> UIImage
class Filter {
    
    var device: MTLDevice
    var defaultLib: MTLLibrary?
    var grayscaleShader: MTLFunction?
    var commandQueue: MTLCommandQueue?
    var commandBuffer: MTLCommandBuffer?
    var commandEncoder: MTLComputeCommandEncoder?
    var pipelineState: MTLComputePipelineState?
    
    var resultsBuff: MTLBuffer?
    var inputImage: UIImage
    var height, width: Int
    
    //TODO: Figure out how to optimize this
    // most devices have a limit of 512 threads per group
    let threadsPerBlock = MTLSize(width: 1, height: 1, depth: 1)
    
    init(img: UIImage){
        self.inputImage = img
        self.height = Int(self.inputImage.size.height)
        self.width = Int(self.inputImage.size.width)

        //SETUP METAL & GPU Configuration
        self.device = MTLCreateSystemDefaultDevice()!
        self.defaultLib = self.device.makeDefaultLibrary()
        self.grayscaleShader = self.defaultLib?.makeFunction(name: "black")
        self.commandQueue = self.device.makeCommandQueue()
        self.commandBuffer = self.commandQueue?.makeCommandBuffer()
        self.commandEncoder = self.commandBuffer?.makeComputeCommandEncoder()
        do{
            pipelineState = try device.makeComputePipelineState(function: grayscaleShader!)
        } catch{
            print("Could not setup GPU Shared Memory Pipeline with Metal Functions: \(error)")
        }
        let memoryLayoutSize = self.width * self.height
        let inputTexture = device.makeBuffer(length: MemoryLayout<Float>.size * memoryLayoutSize, options: .storageModeShared)
        let outputTexture = device.makeBuffer(length: MemoryLayout<Float>.size * memoryLayoutSize, options: .storageModeShared)
        resultsBuff = device.makeBuffer(length: MemoryLayout<uint>.size * memoryLayoutSize, options: .storageModeShared)
        commandEncoder?.setComputePipelineState(pipelineState!)
        commandEncoder?.setBuffer(inputTexture, offset: 0, index: 0)
        commandEncoder?.setBuffer(outputTexture, offset: 0, index: 1)
        commandEncoder?.setBuffer(resultsBuff, offset: 0, index: 2)
    }
    
    func computeRandomArray() -> [Float]{
        var returnArray = [Float].init(repeating: 0.0, count: 3)
        for i in 0..<3{
            returnArray[i] = Float.random(in: 1.0..<255.0)
        }
        returnArray.append(1.0)
        return returnArray
    }
    
    func getCGImage(from uiimg: UIImage) -> CGImage? {
        UIGraphicsBeginImageContext(uiimg.size)
        uiimg.draw(in: CGRect(origin: .zero, size: uiimg.size))
        let contextImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return contextImage?.cgImage
    }
    
    func getMTLTexture(from cgimg: CGImage) -> MTLTexture {
        let textureLoader = MTKTextureLoader(device: self.device)
        do{
            let texture = try textureLoader.newTexture(cgImage: cgimg, options: nil)
            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: texture.pixelFormat, width: width, height: height, mipmapped: false)
            textureDescriptor.usage = [.shaderRead, .shaderWrite]
            return texture
        } catch {
            fatalError("Couldn't convert CGImage to MTLtexture")
        }
    }
    
    func getCGImage(from mtlTexture: MTLTexture) -> CGImage? {
        var data = Array<UInt8>(repeatElement(0, count: 4*width*height))
        mtlTexture.getBytes(&data,
                            bytesPerRow: 4*width,
                            from: MTLRegionMake2D(0, 0, width, height),
                            mipmapLevel: 0)
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &data,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: 4*width,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo.rawValue)
        return context?.makeImage()
    }
    
    func getUIImage(from cgimg: CGImage) -> UIImage? {
        return UIImage(cgImage: cgimg)
    }
    
    func getEmptyMTLTexture() -> MTLTexture? {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: MTLPixelFormat.rgba8Unorm,
            width: width,
            height: height,
            mipmapped: false)
        textureDescriptor.usage = [.shaderRead, .shaderWrite]
        return self.device.makeTexture(descriptor: textureDescriptor)
    }
    
    func getInputMTLTexture() -> MTLTexture? {
        if let inputImage = getCGImage(from: self.inputImage) {
            return getMTLTexture(from: inputImage)
        }
        else { fatalError("Unable to convert Input image to MTLTexture") }
    }
    
    func getBlockDimensions() -> MTLSize {
        let blockWidth = width / self.threadsPerBlock.width
        let blockHeight = height / self.threadsPerBlock.height
        return MTLSizeMake(blockWidth, blockHeight, 1)
    }
    
    func applyFilter() -> UIImage? {
        if let encoder = self.commandEncoder, let buffer = self.commandBuffer,
            let outputTexture = getEmptyMTLTexture(), let inputTexture = getInputMTLTexture() {
            encoder.setTextures([outputTexture, inputTexture], range: 0..<2)
            encoder.dispatchThreadgroups(self.getBlockDimensions(), threadsPerThreadgroup: threadsPerBlock)
            encoder.endEncoding()
    
            buffer.commit()
            buffer.waitUntilCompleted()
            
            var resultsBufferPointer = resultsBuff?.contents().bindMemory(to: uint.self, capacity: MemoryLayout<uint>.size * (height * width))
            for i in 0..<100{
                
                print("\(uint(resultsBufferPointer!.pointee) as Any)")
                resultsBufferPointer = resultsBufferPointer?.advanced(by: 1)
            }
            guard let outputImage = getCGImage(from: outputTexture) else { fatalError("Couldn't obtain CGImage from MTLTexture") }
            return getUIImage(from: outputImage)
        } else { fatalError("optional unwrapping failed") }
        
    }
    
    
}

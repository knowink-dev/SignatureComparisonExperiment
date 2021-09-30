
//
//  ParseImage.swift
//
//  Created by Paul Mayer on 5/12/21.
//

import UIKit
import CoreGraphics
import Accelerate

class ParseImage{
    
    /// Phase 1 Debug Image
    var imagePixelsPhase1: [[UInt32]]!
    
    #if DEBUG || FAKE_RELEASE
    /// Phase 2 Debug Image
    var imagePixelsPhase2: [[UInt32]]!
    
    /// Phase 3 Debug Image
    var imagePixelsPhase3: [[UInt32]]!
    #endif
    
    /// Phase 4 Debug Image
    var imagePixelsPhase4: [[UInt32]]!
    
    /// Active Pixels used in phases 2-4
    var imagePixelsArray: [ImagePixel] = []
    
    /// Dictionary used to create the neighboring pixels for each pixel.
    var pixelImageMap: [PixelCoordinate:ImagePixel] = [:]
    
    
    /// Parses an image pixel data of RGB and Monochrome. Image parser goes through 4 phases of destructing and constructing in order to form lines / vectors with measurable angles to be used for comparison.
    /// - Parameters:
    ///   - inputImage: Image to parse
    /// - Returns: Image object that was parsed during execution.
    func parseImage(inputImage: UIImage) -> Result<ParsedImage>{
        
        //MARK: - Init Vars
        guard let cgImage = inputImage.cgImage,
              let data = cgImage.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data)
        else {
            return .failure(.unableToParseImage("Couldn't access CG Image Data"))
        }
        imagePixelsPhase1 = [[UInt32]](
            repeating: [UInt32](
                repeating: UInt32.max,
                count: cgImage.width),
            count: cgImage.height)
        #if DEBUG || FAKE_RELEASE
        imagePixelsPhase2 = imagePixelsPhase1
        imagePixelsPhase3 = imagePixelsPhase2
        #endif
        imagePixelsPhase4 = imagePixelsPhase1
        
        let parsedImageObj = ParsedImage()

        //MARK: - Phase 1 - Converts image to black and white pixels only.
        #if DEBUG || FAKE_RELEASE
        var phaseOneStart: CFAbsoluteTime = 0
        var phase1Interval: Double = 0
        #endif
        
        if cgImage.colorSpace?.model == .rgb || cgImage.colorSpace?.model == .monochrome{
            #if DEBUG || FAKE_RELEASE
            phaseOneStart = CFAbsoluteTimeGetCurrent()
            #endif
            
            parseImagePhase1(cgImage, bytes)
            #if DEBUG || FAKE_RELEASE
            phase1Interval = Double(CFAbsoluteTimeGetCurrent() - phaseOneStart)
            #endif
            
        } else{
            return .failure(.invalidImageSupplied("Image is not in the correct format. Acceptable formats include RGBA and MonoChrome"))
        }
        
        //MARK: - Phase 2 - Delete all neighbor pixels to the left.
        #if DEBUG || FAKE_RELEASE
        imagePixelsPhase2 = imagePixelsPhase1
        let phaseTwoStart = CFAbsoluteTimeGetCurrent()
        #endif
        
        parseImagePhase2(cgImage)
        #if DEBUG || FAKE_RELEASE
        let phase2Interval = Double(CFAbsoluteTimeGetCurrent() - phaseTwoStart)
        #endif
        
        //MARK: - Phase 3 - Transform image signature into vectors.
        #if DEBUG || FAKE_RELEASE
        imagePixelsPhase3 = imagePixelsPhase2
        let phaseThreeStart = CFAbsoluteTimeGetCurrent()
        #endif
        
        parseImagePhase3()
        #if DEBUG || FAKE_RELEASE
        let phase3Interval = Double(CFAbsoluteTimeGetCurrent() - phaseThreeStart)
        #endif
        
        //MARK: - Phase 4 - Process all vectors and mapped them to their appropriate quadrants.
        #if DEBUG || FAKE_RELEASE
        let phaseFourStart = CFAbsoluteTimeGetCurrent()
        #endif
        
        parsedImageObj.vectors = parseImagePhase4(cgImage.height)
        #if DEBUG || FAKE_RELEASE
        let phase4Interval: Double = Double(CFAbsoluteTimeGetCurrent() - phaseFourStart)
        #endif
        
        //MARK: - Debug Info
        #if DEBUG || FAKE_RELEASE
        let secondsPhase1 = (String(format: "%.4f", phase1Interval))
        let secondsPhase2 = (String(format: "%.4f", phase2Interval))
        let secondsPhase3 = (String(format: "%.4f", phase3Interval))
        let secondsPhase4 = (String(format: "%.4f", phase4Interval))
        let totalTime = (String(format: "%.4f", phase1Interval + phase2Interval + phase3Interval + phase4Interval))
        
        debugPrint("Phase1: \(secondsPhase1)")
        debugPrint("Phase2: \(secondsPhase2)")
        debugPrint("Phase3: \(secondsPhase3)")
        debugPrint("Phase4: \(secondsPhase4)")
        debugPrint("Total: \(totalTime)")
        debugPrint("")
        
        parsedImageObj.debugImageDic[.phase1] = generateDebugImage(pixelArray: imagePixelsPhase1, cgImage: cgImage)
        parsedImageObj.debugImageDic[.phase2] = generateDebugImage(pixelArray: imagePixelsPhase2, cgImage: cgImage)
        parsedImageObj.debugImageDic[.phase3] = generateDebugImage(pixelArray: imagePixelsPhase3, cgImage: cgImage)
        parsedImageObj.debugImageDic[.phase4] = generateDebugImage(pixelArray: imagePixelsPhase4, cgImage: cgImage)
        #endif
        
        return .success(parsedImageObj)
    }
}

//MARK: - Private Functions.
private extension ParseImage{
    
    /// Creates an actual UIimage from the 2D pixel data recieved. This is used to create the images for each phase in debug mode.
    /// - Parameters:
    ///   - pixelArray: 2D pixel array.
    ///   - cgImage: Current  core graphics image.
    /// - Returns: The Uimage of the 2D pixel array.
    func generateDebugImage(pixelArray: [[UInt32]], cgImage: CGImage) -> UIImage?{
        let imageData = pixelArray.flatMap({$0})
        let width = Int(cgImage.width)
        let height = Int(cgImage.height)
        let bitsPerComponent = 8
        let bytesPerPixel2 = 4
        let bytesPerRow = width * bytesPerPixel2
        let imageDataMemoryAllocation = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue

        guard let imageContext = CGContext(data: imageDataMemoryAllocation,
                                           width: width,
                                           height: height,
                                           bitsPerComponent: bitsPerComponent,
                                           bytesPerRow: bytesPerRow,
                                           space: colorSpace,
                                           bitmapInfo: bitmapInfo),
              let buffer = imageContext.data?.bindMemory(to: UInt32.self,
                                                         capacity: imageData.count)
        else { return nil}

        for index in 0 ..< width * height {
            buffer[index] = imageData[index]
        }
        return imageContext.makeImage().flatMap { UIImage(cgImage: $0) }
    }
}


















//MARK: - Models and Enums
struct Pixel {
    var value: UInt32
    var red: UInt8 {
        get { return UInt8(value & 0xFF) }
        set { value = UInt32(newValue) | (value & 0xFFFFFF00) }
    }
    var green: UInt8 {
        get { return UInt8((value >> 8) & 0xFF) }
        set { value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF) }
    }
    var blue: UInt8 {
        get { return UInt8((value >> 16) & 0xFF) }
        set { value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF) }
    }
    var alpha: UInt8 {
        get { return UInt8((value >> 24) & 0xFF) }
        set { value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF) }
    }
}

struct PixelCoordinate: Hashable {
    let x: Int
    let y: Int
}

class PixelVector{
    var pixelPath: [ImagePixel] = []
    var angle: Double = 0.0
    var processed = false
    var startPixel: ImagePixel!
    var endPixel: ImagePixel!{
        didSet{
            let firstPixel: ImagePixel!
            let secondPixel: ImagePixel!
            if startPixel.xPos <= endPixel.xPos{
                firstPixel = startPixel
                secondPixel = endPixel
            } else {
                firstPixel = endPixel
                secondPixel = startPixel
            }
            if secondPixel.xPos > firstPixel.xPos{
                angle = (atan(((Double(secondPixel.yPos) - Double(firstPixel.yPos))) / (Double(firstPixel.xPos) - Double(secondPixel.xPos))) * (180 / Double.pi)) + 90
            } else{
                angle = (atan((Double(secondPixel.yPos) - Double(firstPixel.yPos)) / (Double(secondPixel.xPos) - Double(firstPixel.xPos))) * (180 / Double.pi)) + 90
            }
        }
    }
}

class ImagePixel{
    var color: PixelColor = .clear
    var debugColor: PixelColor?
    var xPos: Int
    var yPos: Int
    var pixelStatus: PixelStatus = .normal
    var neighbors: [ImagePixel] = []
    
    var topLeftPix: ImagePixel?{
        didSet{
            if let pixel = topLeftPix{
                neighbors.append(pixel)
            }
        }
    }
    var topPix: ImagePixel?{
        didSet{
            if let pixel = topPix{
                neighbors.append(pixel)
            }
        }
    }
    var topRightPix: ImagePixel?{
        didSet{
            if let pixel = topRightPix{
                neighbors.append(pixel)
            }
        }
    }
    var rightPix: ImagePixel?{
        didSet{
            if let pixel = rightPix{
                neighbors.append(pixel)
            }
        }
    }
    var bottomRightPix: ImagePixel?{
        didSet{
            if let pixel = bottomRightPix{
                neighbors.append(pixel)
            }
        }
    }
    var bottomPix: ImagePixel?{
        didSet{
            if let pixel = bottomPix{
                neighbors.append(pixel)
            }
        }
    }
    var bottomLeftPix: ImagePixel?{
        didSet{
            if let pixel = bottomLeftPix{
                neighbors.append(pixel)
            }
        }
    }
    var leftPix: ImagePixel? {
        didSet{
            if let pixel = leftPix{
                neighbors.append(pixel)
            }
        }
    }
    
    init(_ color: PixelColor, xPos: Int, yPos: Int) {
        self.color = color
        self.xPos = xPos
        self.yPos = yPos
    }
    
    func hasAtLeastOneNeighborProcessed() -> ImagePixel?{
        return neighbors.first(where: {$0.pixelStatus == .processed})
    }
    
    func canBeStartPixel() -> Bool{
        if neighbors.filter({$0.color == .black}).count == 1{
            return true
        }
        return false
    }
}

public class ParsedImage {
    var vectors: [PixelVector] = []
    var debugImageDic: [DebugImageName: UIImage] = [:]
}

enum DebugImageName: String{
    case phase1 = "PHASE: 1 - Black White Image"
    case phase2 = "PHASE: 2 - Trimmed Image"
    case phase3 = "PHASE: 3 - Altered Image"
    case phase4 = "PHASE: 4 - Processed Image"
}

enum PixelStatus{
    case processed
    case normal
    case deleted
    case permanentlyDeleted
    case maybeDeleteBottomLeft
    case maybeDeleteBottomRight
    case restoredRight
    case maybeRestoreRight
    case restoredLeft
    case maybeRestoreLeft
    
}

enum PixelColor: UInt32{
    case clear = 0
    case white = 0b11111111111111111111111111111111 //UInt32.max
    case black = 255
    case red = 0b11111111000000000000000011111111
    case green = 0b00000000111111110000000011111111
    case blue = 0b00000000000000001111111111111111
    case yellow = 0b11111111111111110000000011111111
    case pink = 0b11111111000000001111111111111111
    case teal = 0b00000000111111111111111111111111
    case orange = 0xFFA500FF
    case purple = 0x6A0DADFF
    case lightGreen = 0x90EE90FF
    case gold = 0xDAA520FF
    case brown = 0x964B00FF
    case gray = 0x808080FF
    case grayBlue = 0x43A6C6FF
    case darkBlue = 0x000C66FF
    case darkGreen = 0x024b30FF
    case knowInkYellow = 0xC5D428FF
}

public enum ImageParserError: Error {
    case invalidImageSupplied(String)
    case unableToParseImage(String)
}

enum Result<Value> {
    case success(Value)
    case failure(ImageParserError)
}

extension Thread {
    class func printCurrent() {
        debugPrint("\nThread: \(Thread.current)\n" + "Operation Queue: \(OperationQueue.current?.name ?? "None")\n")
    }
}

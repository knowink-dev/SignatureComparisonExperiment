//
//  Phase1.swift
//
//
//  Created by Paul Mayer on 9/13/21.
//

import UIKit

//MARK: - Phase 1
internal extension ParseImage{
    
    /// - Converts an RGB  image to black and white pixels only. Also initializes key variables for image parser. Only active pixels continue to phases 2-4.
    /// - Parameters:
    ///   - cgImage: The image signature in Core Graphic format
    ///   - bytes: Pointer to the image data
    func parseRgbImagePhase1(_ cgImage: CGImage, _ bytes: UnsafePointer<UInt8>){
        let bytesPerPixel = cgImage.bitsPerPixel / cgImage.bitsPerComponent
        let black = PixelColor.black
        let white = PixelColor.white
        let width = cgImage.width
        let height = cgImage.height
        let xBoundary = width - 1
        let yBoundary = height - 1
        
        for y in 0 ..< height {
            for x in 0 ..< width {
                //check with conditions to make sure it is a black pixel
                let offset = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)
                
                if x == 0 || y == 0 || y == yBoundary || x == xBoundary {
                    let newPixel = ImagePixel(white, xPos: x, yPos: y)
                    pixelImageMap[PixelCoordinate(x: x, y: y)] = newPixel
                    continue
                }
                
                let a = bytes[offset + 3]
                if a <= 0 { continue }
                let r = bytes[offset]
                if r != 0 { continue }
                let g = bytes[offset + 1]
                if g != 0 { continue }
                let b = bytes[offset + 2]
                if b != 0 { continue }
                
                let newPixel = ImagePixel(black, xPos: x, yPos: y)
                imagePixelsArray.append(newPixel)
                pixelImageMap[PixelCoordinate(x: x, y: y)] = newPixel
                imagePixelsPhase1[y][x] = black.rawValue
            }
        }
    }
    
    
    /// - Converts a grayscale monochrome image to black and white pixels only. Also initializes key variables for image parser. Only active pixels continue to phases 2-4.
    /// - Parameters:
    ///   - cgImage: The image signature in Core Graphic format
    ///   - bytes: Pointer to the image data
    func parseMonochromeImagePhase1(_ cgImage: CGImage, _ bytes: UnsafePointer<UInt8>){
        let bytesPerPixel = cgImage.bitsPerPixel / cgImage.bitsPerComponent
        let black = PixelColor.black
        let white = PixelColor.white
        let width = cgImage.width
        let height = cgImage.height
        let xBoundary = width - 1
        let yBoundary = height - 1
        
        for y in 0 ..< height {
            for x in 0 ..< width {
                //check with conditions to make sure it is a black pixel
                let offset = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)
                
                if x == 0 || y == 0 || y == yBoundary || x == xBoundary {
                    let newPixel = ImagePixel(white, xPos: x, yPos: y)
                    pixelImageMap[PixelCoordinate(x: x, y: y)] = newPixel
                    continue
                }
                
                let r = Int(bytes[offset])
                let g = Int(bytes[offset + 1])
                let b = Int(bytes[offset + 2])
                let greyScale = Double(r + g + b) / 3.0
                
                if bytes[offset + 3] > 0 && greyScale < 200{
                    let newPixel = ImagePixel(black, xPos: x, yPos: y)
                    imagePixelsArray.append(newPixel)
                    pixelImageMap[PixelCoordinate(x: x, y: y)] = newPixel
                    imagePixelsPhase1[y][x] = PixelColor.black.rawValue
                }
            }
        }
    }
}


//
//  Phase1.swift
//
//
//  Created by Paul Mayer on 9/13/21.
//

import UIKit

//MARK: - Phase 1
internal extension ParseImage{
    
    /// - Converts the image to black and white pixels only. Also initializes key variables for image parser. Only active pixels continue to phases 2-4.
    /// - Parameters:
    ///   - cgImage: The image signature in Core Graphic format
    ///   - bytes: Pointer to the image data
    func parseImagePhase1(_ cgImage: CGImage, _ bytes: UnsafePointer<UInt8>){
        let bytesPerPixel = cgImage.bitsPerPixel / cgImage.bitsPerComponent
        for y in 0 ..< cgImage.height {
            for x in 0 ..< cgImage.width {
                let offset = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)
                let r = bytes[offset]
                let g = bytes[offset + 1]
                let b = bytes[offset + 2]
                let a = bytes[offset + 3]
                
                var color: PixelColor = .clear
                let newPixel = ImagePixel(color, xPos: x, yPos: y)
                if r == 0 && g == 0 && b == 0 && a > 0{ //If its already black
                    color = .black
                    imagePixelsArray.append(newPixel)
                }else{ //White
                    color = .white
                }
                newPixel.color = color
                imagePixelsPhase1[y][x] = color.rawValue
                pixelImageMap[PixelCoordinate(x: x, y: y)] = newPixel
            }
        }
    }
}


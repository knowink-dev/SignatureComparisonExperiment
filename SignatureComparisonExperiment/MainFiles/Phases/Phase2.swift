//
//  Phase2.swift
//
//
//  Created by Paul Mayer on 9/13/21.
//

import UIKit

//MARK: - Phase 2
internal extension ParseImage{
    
    /// - Delete all neighbor pixels to the left, in order to create single connecting lines and handle different stroke sizes.
    /// - Parameter cgImage: The image signature in Core Graphic format
    func parseImagePhase2(_ cgImage: CGImage){
        for currentPixel in imagePixelsArray{
            if (currentPixel.xPos > 0 && currentPixel.xPos < cgImage.width - 1)
                && (currentPixel.yPos > 0 && currentPixel.yPos < cgImage.height - 1) {
                /* DELETE Current Pixel if pixel has neighbor pixel to the right.
                    ex:    @ - *
                */
                if imagePixelsPhase1[currentPixel.yPos][currentPixel.xPos + 1] == PixelColor.black.rawValue {
                    currentPixel.color = .white
                    currentPixel.pixelStatus = .deleted
                    imagePixelsPhase2[currentPixel.yPos][currentPixel.xPos] = PixelColor.brown.rawValue
                }
            }

            setPixelNeighbors(
                pixelImageMap,
                currentPixel.xPos,
                currentPixel.yPos,
                imagePixelsPhase1.count - 1,
                imagePixelsPhase1[currentPixel.yPos].count - 1,
                currentPixel)
        }
    }
    
    
    /// Sets the 3-8 neighboring pixel that can exsist for each pixel.
    /// - Parameters:
    ///   - imgPixels: Dictionary of all the pixels for the current image being parsed.
    ///   - x: X position of the pixel
    ///   - y: Y position of the pixel
    ///   - yMax: Max height of the Image
    ///   - xMax: Max width of the Image
    ///   - currentPixel: Current pixel having it's neighbors set.
    func setPixelNeighbors(_ imgPixels: [String:ImagePixel],_ x: Int,_ y: Int,_ yMax: Int,_ xMax: Int,_ currentPixel: ImagePixel){
        if x != 0 && y != 0{
            currentPixel.topLeftPix = imgPixels["\(x - 1)-\(y - 1)"]
        }
        
        if y != 0{
            currentPixel.topPix = imgPixels["\(x)-\(y - 1)"]
        }
        
        if x < xMax && y != 0{
            currentPixel.topRightPix = imgPixels["\(x + 1)-\(y - 1)"]
        }
        
        if x < xMax{
            currentPixel.rightPix = imgPixels["\(x + 1)-\(y)"]
        }
        
        if x < xMax && y < yMax{
            currentPixel.bottomRightPix = imgPixels["\(x + 1)-\(y + 1)"]
        }
        
        if y < yMax{
            currentPixel.bottomPix = imgPixels["\(x)-\(y + 1)"]
        }
        
        if x != 0 && y < yMax{
            currentPixel.bottomLeftPix = imgPixels["\(x - 1)-\(y + 1)"]
        }
        
        if x != 0 {
            currentPixel.leftPix = imgPixels["\(x - 1)-\(y)"]
        }
    }
}




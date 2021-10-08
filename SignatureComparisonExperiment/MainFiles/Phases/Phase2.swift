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
        let xPositionBoundary = cgImage.width - 1
        let yPositionBoundary = cgImage.height - 1
        let black = PixelColor.black.rawValue
        let white = PixelColor.white
        let brown = PixelColor.brown.rawValue
        let deletedStatus = PixelStatus.deleted
        for currentPixel in imagePixelsArray{
            /* DELETE Current Pixel if pixel has neighbor pixel to the right.
                ex:    @ - *
            */
            if imagePixelsPhase1[currentPixel.yPos][currentPixel.xPos + 1] == black {
                currentPixel.color = white
                currentPixel.pixelStatus = deletedStatus
                currentPixel.debugColor = .brown
                #if DEBUG || FAKE_RELEASE
                imagePixelsPhase2[currentPixel.yPos][currentPixel.xPos] = brown
                #endif
            } else {
                currentPixel.color = .black
                currentPixel.debugColor = .black
                currentPixel.pixelStatus = .normal
                imagePixelsPhase2[currentPixel.yPos][currentPixel.xPos] = black
                
            }
            setPixelNeighbors(
                pixelImageMap,
                currentPixel.xPos,
                currentPixel.yPos,
                yPositionBoundary,
                xPositionBoundary,
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
    func setPixelNeighbors(
        _ imgPixels: [PixelCoordinate:ImagePixel],
        _ x: Int,
        _ y: Int,
        _ yMax: Int,
        _ xMax: Int,
        _ currentPixel: ImagePixel) {
        
        if x != 0 && y != 0{
            currentPixel.topLeftPix = imgPixels[PixelCoordinate(x: x - 1, y: y - 1)] ?? ImagePixel(.white, xPos: x - 1, yPos: y - 1)
        }
        
        if y != 0{
            currentPixel.topPix = imgPixels[PixelCoordinate(x: x, y: y - 1)] ?? ImagePixel(.white, xPos: x, yPos: y - 1)
        }
        
        if x < xMax && y != 0{
            currentPixel.topRightPix = imgPixels[PixelCoordinate(x: x + 1, y: y - 1)] ?? ImagePixel(.white, xPos: x + 1, yPos: y - 1)
        }
        
        if x < xMax{
            currentPixel.rightPix = imgPixels[PixelCoordinate(x: x + 1, y: y)] ?? ImagePixel(.white, xPos: x + 1, yPos: y)
        }
        
        if x < xMax && y < yMax{
            currentPixel.bottomRightPix = imgPixels[PixelCoordinate(x: x + 1, y: y + 1)] ?? ImagePixel(.white, xPos: x + 1, yPos: y + 1)
        }
        
        if y < yMax{
            currentPixel.bottomPix = imgPixels[PixelCoordinate(x: x, y: y + 1)] ?? ImagePixel(.white, xPos: x, yPos: y + 1)
        }
        
        if x != 0 && y < yMax{
            currentPixel.bottomLeftPix = imgPixels[PixelCoordinate(x: x - 1, y: y + 1)] ?? ImagePixel(.white, xPos: x - 1, yPos: y + 1)
        }
        
        if x != 0 {
            currentPixel.leftPix = imgPixels[PixelCoordinate(x: x - 1, y: y)] ?? ImagePixel(.white, xPos: x - 1, yPos: y)
        }
    }
}




//
//  Phase4.swift
//
//
//  Created by Paul Mayer on 9/13/21.
//

import UIKit

//MARK: - Phase 4
internal extension ParseImage{
    
    /// - Process all lines and turn them into vectors with vertices.
    /// - Parameter imgHeight: The height of the current image used for trimming the vectors length
    /// - Returns: The collection of image vectors from processing the lines, and any silent errors that were recogonized while creating vectors.
    func parseImagePhase4(_ imgHeight: Int) -> [PixelVector]{
        var vectors: [PixelVector] = []
        let vectorTrimmerLength = Int(round(Double(imgHeight) * 0.02))
        let vectorTrimmer = (vectorTrimmerLength <= 5 ? 5 : vectorTrimmerLength >= 15 ? 15 : vectorTrimmerLength)
        for currentPixel in imagePixelsArray{
            //Convert pixel lines into vectors
            if currentPixel.color == .black,
               currentPixel.hasAtLeastOneNeighborProcessed() == nil,
               currentPixel.canBeStartPixel(){

                let vector = PixelVector()
                vector.startPixel = currentPixel
                vector.pixelPath.append(currentPixel)
                currentPixel.pixelStatus = .processed
                #if DEBUG || FAKE_RELEASE
                imagePixelsPhase4[currentPixel.yPos][currentPixel.xPos] = PixelColor.red.rawValue
                #endif
                var neighbors = currentPixel.neighbors
                while (!neighbors.isEmpty){
                    if let nextNeighbor = neighbors.first(where: {$0.pixelStatus != .processed && $0.color == .black}){
                        nextNeighbor.pixelStatus = .processed
                        neighbors = nextNeighbor.neighbors
                        #if DEBUG || FAKE_RELEASE
                        imagePixelsPhase4[nextNeighbor.yPos][nextNeighbor.xPos] = PixelColor.darkBlue.rawValue
                        #endif
                        vector.pixelPath.append(nextNeighbor)
                    } else {
                        neighbors = []
                    }
                }
                vector.endPixel = vector.pixelPath.last
                #if DEBUG || FAKE_RELEASE
                imagePixelsPhase4[vector.endPixel?.yPos ?? 0][vector.endPixel?.xPos ?? 0] = PixelColor.green.rawValue
                #endif
                if vector.pixelPath.count > vectorTrimmer{
                    vectors.append(vector)
                }
                continue
            }
        }
        return (vectors)
    }
}




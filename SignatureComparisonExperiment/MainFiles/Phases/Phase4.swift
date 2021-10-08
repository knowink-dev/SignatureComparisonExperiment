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
                currentPixel.pixelStatus = .processed
                #if DEBUG || FAKE_RELEASE
                imagePixelsPhase4[currentPixel.yPos][currentPixel.xPos] = PixelColor.red.rawValue
                #endif
                processLine(pixelImage: currentPixel, line: vector)
                let lastPixel = vector.pixelPath.last
                vector.endPixel = lastPixel
                #if DEBUG || FAKE_RELEASE
                imagePixelsPhase4[lastPixel?.yPos ?? 0][lastPixel?.xPos ?? 0] = PixelColor.green.rawValue
                #endif
                if vector.pixelPath.count > vectorTrimmer{
                    vectors.append(vector)
                }
                continue
            }
        }
        return (vectors)
    }
    
    
    /// Recursive function that processes the current pixel and then moves on to the next neighboring pixel if one exists.
    /// - Parameters:
    ///   - pixelImage: Current Pixel being processed.
    ///   - line: Collection of the pixels being processed to form a curved line.
    func processLine(pixelImage: ImagePixel?,
                     line: PixelVector){
        guard let currentPixel = pixelImage else { return }
        let currentNeighbors = currentPixel.neighbors
        if currentNeighbors.count > 0 {
            if let nextNeighbor = currentNeighbors.first(where: {$0.pixelStatus != .processed && $0.color == .black}){
                nextNeighbor.pixelStatus = .processed
                #if DEBUG || FAKE_RELEASE
                imagePixelsPhase4[nextNeighbor.yPos][nextNeighbor.xPos] = PixelColor.darkBlue.rawValue
                #endif
                line.pixelPath.append(nextNeighbor)
                processLine(pixelImage: nextNeighbor, line: line)
            }
        }
    }
}




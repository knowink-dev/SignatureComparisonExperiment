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
    /// - Returns: The collection of image vectors from processing the lines, and any silent errors that were recogonized while creating vectors.
    func parseImagePhase4() -> [PixelVector]{
        var vectors: [PixelVector] = []
        for currentPixel in imagePixelsArray{
            //Convert pixel lines into vectors
            if currentPixel.color == .black,
               currentPixel.hasAtLeastOneNeighborProcessed() == nil,
               currentPixel.canBeStartPixel(){

                let vector = PixelVector()
                vector.startPixel = currentPixel
                currentPixel.pixelStatus = .processed
                imagePixelsPhase4[currentPixel.yPos][currentPixel.xPos] = PixelColor.red.rawValue
                processLine(pixelImage: currentPixel, line: vector, &imagePixelsPhase4)
                let lastPixel = vector.pixelPath.last
                vector.endPixel = lastPixel
                imagePixelsPhase4[lastPixel?.yPos ?? 0][lastPixel?.xPos ?? 0] = PixelColor.green.rawValue
                if vector.pixelPath.count > 14{
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
    ///   - imgPixels: Image pixel map of phase 4 to create a viewable image of phase 4 in debug mode.
    func processLine(pixelImage: ImagePixel?,
                     line: PixelVector,
                     _ imgPixels: inout [[UInt32]]){
        
        guard let currentPixel = pixelImage else { return }
        let currentNeighbors = currentPixel.neighbors
        if currentNeighbors.count > 0 {
            let nextNeighbor = currentPixel.neighbors.filter({$0.color == .black && $0.pixelStatus != .processed})
            if nextNeighbor.count == 1{
                guard let pixelToProcess = nextNeighbor.first else {
                    debugPrint("Process Line Error: Could not access first neighboring pixel.")
                    return
                }
                pixelToProcess.pixelStatus = .processed
                imgPixels[pixelToProcess.yPos][pixelToProcess.xPos] = PixelColor.darkBlue.rawValue
                line.pixelPath.append(pixelToProcess)
                processLine(pixelImage: pixelToProcess, line: line, &imgPixels)
            } else if nextNeighbor.count == 0{
                return
            } else{
                debugPrint("Process Line Error: Pixel had more than one neighbor.")
            }
        } else {
            return
        }
    }
}




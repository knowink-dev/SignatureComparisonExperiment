//
//  SignatureDriver.swift
//  MetalAndImages
//
//  Created by Paul Mayer on 8/16/21.
//

import Foundation
import UIKit


public class SignatureDriver{
    
    public enum Errors: Error {
        public enum Images {
            case primary, secondary
        }
        
        case parsing(image: Images, message: String)
        case invalid(image: Images, message: String)
        case noLinesRecognized(image: Images)
        case emptyParsedImages
    }
    
    
    /// Public fucntion to compare two signatures together and provide a confidence level of how similar the images are.
    /// - Parameters:
    ///   - primarySignature: Source image to compare against.
    ///   - secondarySignature: Secondary image that is compared against the source image.
    ///   - handler: Callback value providing the signature comparison percentage, and an error if one or more occured.
    public class func compare(
        _ primarySignature: UIImage,
        _ secondarySignature: UIImage,
        _ handler: @escaping (Swift.Result<Double, Error>) -> Void) {
        compareSignatures(primarySignature,
                          secondarySignature) { result, parsedImages in
            handler(result)
        }
    }
    
    
    /// Project specfific function that spins off separate image parsing operations and calculates the confidence score based on the vectors and angles that are returned.
    /// - Parameters:
    ///   - primarySignature: Source image to compare against
    ///   - secondarySignature: Secondary image that is compared against the source image.
    ///   - handler: Callback value providing the signature comparison percentage, and an error if one or more occured.
    class func compareSignatures(
        _ primarySignature: UIImage,
        _ secondarySignature: UIImage,
        _ handler: @escaping (
            Swift.Result<Double, Error>,
            _ imageObj: [ParsedImage]?
        ) -> Void) {
        
        let parseImgQueue = OperationQueue()
        var primaryImgObj: ParsedImage?
        var secondaryImgObj: ParsedImage?
        let overallTimeStart: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
           
        DispatchQueue.global().async {
            parseImgQueue.addOperation {
                let imgParser = ParseImage()
                let result = imgParser.parseImage(inputImage: primarySignature)
                switch result {
                case .success(let data):
                    primaryImgObj = data
                case .failure(let error):
                    switch error {
                    case .invalidImageSupplied(let errorMessage):
                        handler(.failure(Errors.invalid(image: .primary, message: errorMessage)), nil)
                    case .unableToParseImage(let errorMessage):
                        handler(.failure(Errors.parsing(image: .primary, message: errorMessage)), nil)
                    }
                }
            }
            
            parseImgQueue.addOperation {
                let imgParser = ParseImage()
                let result = imgParser.parseImage(inputImage: secondarySignature)
                switch result {
                case .success(let data):
                    secondaryImgObj = data
                case .failure(let error):
                    switch error {
                    case .invalidImageSupplied(let errorMessage):
                        handler(.failure(Errors.invalid(image: .secondary, message: errorMessage)), nil)
                    case .unableToParseImage(let errorMessage):
                        handler(.failure(Errors.parsing(image: .secondary, message: errorMessage)), nil)
                    }
                }
            }
            parseImgQueue.waitUntilAllOperationsAreFinished()

            if let primaryImage = primaryImgObj, let secondaryImage = secondaryImgObj{
                var overallPercentage = 0.0
                if primaryImage.vectors.count >= secondaryImage.vectors.count{
                    if primaryImage.vectors.count > 0{
                        overallPercentage = computePercentage(numImg: secondaryImage, denImg: primaryImage)
                    } else {
                        handler(.failure(Errors.noLinesRecognized(image: .primary)), nil)
                    }
                } else {
                    if secondaryImage.vectors.count > 0{
                        overallPercentage = computePercentage(numImg: primaryImage, denImg: secondaryImage)
                    } else {
                        handler(.failure(Errors.noLinesRecognized(image: .secondary)), nil)
                    }
                }
                #if DEBUG || FAKE_RELEASE
                let overallTimeEnd  = Double(CFAbsoluteTimeGetCurrent() - overallTimeStart)
                debugPrint("Overall Time: \(overallTimeEnd)")
                #endif
                handler(.success(overallPercentage), [primaryImage, secondaryImage])
            } else {
                handler(.failure(Errors.emptyParsedImages), nil)
            }
        }
    }
}

private extension SignatureDriver{
    
    /// Compares the vector's angles for each image against each other. Every vector finds the closest angle to compare itself to.
    /// - Parameters:
    ///   - numImg: Secondary Image
    ///   - denImg: Source Image
    /// - Returns: Confidence level for the signature comparison.
    class func computePercentage(numImg: ParsedImage, denImg: ParsedImage) -> Double{
        var totalPercentage = 0.0
        let sortedNumVectors = numImg.vectors.sorted(by: {$0.minXPos < $1.minXPos})
        let sortedDenVectors = denImg.vectors.sorted(by: {$0.minXPos < $1.minXPos})
        for (index, numVector) in sortedNumVectors.enumerated(){
            let nearestDenVectors = findNearestVectors(from: index, sortedDenVectors: sortedDenVectors)
            if let nearestDenVector = nearestDenVectors.filter({!$0.processed}).min(by: {abs($0.angle - numVector.angle) < abs($1.angle - numVector.angle)}){
                var numerator = 0.0
                if nearestDenVector.angle >= numVector.angle{
                    numerator = 180 - (nearestDenVector.angle - numVector.angle)
                } else {
                    numerator = 180 - (numVector.angle - nearestDenVector.angle)
                }
                totalPercentage = totalPercentage + (numerator / 180)
                nearestDenVector.processed = true
            }
        }
        return totalPercentage / Double(denImg.vectors.count)
    }
    
    
    /// Finds the five nearest vectors from the sorted array's index.
    /// - Parameters:
    ///   - numIndex: The source of where all the nearest vectors are measured from.
    ///   - sortedDenVectors: Vectors to measure their index distance
    /// - Returns: The five nearest vectors from the index provided based.
    class func findNearestVectors(from numIndex: Int, sortedDenVectors: [PixelVector]) -> [PixelVector]{
        var nearestCount = 5
        if sortedDenVectors.count <= nearestCount{
            return sortedDenVectors
        }
        var leftSideIndex = numIndex
        var rightSideIndex = numIndex
        var nearestVectors: [PixelVector] = []
        
        while (nearestCount > 0) {
            rightSideIndex += 1
            if leftSideIndex >= 0{
                nearestVectors.append(sortedDenVectors[leftSideIndex])
                nearestCount -= 1
            }
            leftSideIndex -= 1
            if rightSideIndex < sortedDenVectors.count && nearestCount > 0{
                nearestVectors.append(sortedDenVectors[rightSideIndex])
                nearestCount -= 1
            }
        }
        return nearestVectors
    }
}

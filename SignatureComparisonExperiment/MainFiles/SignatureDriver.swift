//
//  SignatureDriver.swift
//  MetalAndImages
//
//  Created by Paul Mayer on 8/16/21.
//

import Foundation
import UIKit


public class SignatureDriver{
    
    
    /// Public fucntion to compare two signatures together and provide a confidence level of how similar the images are.
    /// - Parameters:
    ///   - primarySignature: Source image to compare against.
    ///   - secondarySignature: Secondary image that is compared against the source image.
    ///   - handler: Callback value providing the signature comparison percentage, and an error if one or more occured.
    public class func compare(_ primarySignature: UIImage,
                                  _ secondarySignature: UIImage,
                                  _ handler: @escaping (Swift.Result<Double, Error>) -> Void) {
        compareSignatures(primarySignature,
                          secondarySignature,
                          false) { result,
                                   parsedImages in
            handler(result)
        }
    }
    
    
    /// Project specfific function that spins off separate image parsing operations and calculates the confidence score based on the vectors and angles that are returned.
    /// - Parameters:
    ///   - primarySignature: Source image to compare against
    ///   - secondarySignature: Secondary image that is compared against the source image.
    ///   - isDebugMode: Boolean value that if turned on will provide the debug images for each image parsing phase.
    ///   - handler: Callback value providing the signature comparison percentage, and an error if one or more occured.
    class func compareSignatures(_ primarySignature: UIImage,
                           _ secondarySignature: UIImage,
                           _ isDebugMode: Bool = false,
                           _ handler: @escaping (Swift.Result<Double, Error>,
                                                 _ imageObj: [ParsedImage]?) -> Void) {
        let parseImgQueue = OperationQueue()
        parseImgQueue.maxConcurrentOperationCount = 2
        var primaryImgObj: ParsedImage?
        var secondaryImgObj: ParsedImage?
           
        DispatchQueue.global().async {
            let primaryBlock = BlockOperation{
                let imgParser = ParseImage()
                let result = imgParser.parseImage(inputImage: primarySignature,
                                                            runInDebugMode: isDebugMode)
                switch result {
                case .success(let data):
                    primaryImgObj = data
                case .failure(let error):
                    switch error {
                    case .invalidImageSupplied(let errorMessage):
                        handler(.failure(NSError(domain: "INVALID PRIMARY IMAGE SUPPLIED: \(errorMessage)", code: 0, userInfo: nil)), nil)
                        parseImgQueue.cancelAllOperations()
                    case .unableToParseImage(let errorMessage):
                        handler(.failure(NSError(domain: "PRIMARY IMAGE PARSING ERROR: \(errorMessage)", code: 0, userInfo: nil)), nil)
                        parseImgQueue.cancelAllOperations()
                    }
                }
            }
            
            let secondaryBlock = BlockOperation{
                let imgParser = ParseImage()
                let result = imgParser.parseImage(inputImage: secondarySignature,
                                                            runInDebugMode: isDebugMode)
                switch result {
                case .success(let data):
                    secondaryImgObj = data
                case .failure(let error):
                    switch error {
                    case .invalidImageSupplied(let errorMessage):
                        handler(.failure(NSError(domain: "INVALID SECONDARY IMAGE SUPPLIED: \(errorMessage)", code: 0, userInfo: nil)), nil)
                        parseImgQueue.cancelAllOperations()
                    case .unableToParseImage(let errorMessage):
                        handler(.failure(NSError(domain: "SECONDARY IMAGE PARSING ERROR: \(errorMessage)", code: 0, userInfo: nil)), nil)
                        parseImgQueue.cancelAllOperations()
                    }
                }
            }
            parseImgQueue.addOperations([primaryBlock, secondaryBlock], waitUntilFinished: true)

            if let primaryImage = primaryImgObj, let secondaryImage = secondaryImgObj{
                var overallPercentage = 0.0
                if primaryImage.vectors.count >= secondaryImage.vectors.count{
                    if primaryImage.vectors.count > 0{
                        overallPercentage = computePercentage(numImg: secondaryImage, denImg: primaryImage)
                    } else {
                        handler(.failure(NSError(domain: "ERROR: Unable to Parse Image. No lines were recognized for the Primary Image supplied.", code: 0, userInfo: nil)), nil)
                    }
                } else {
                    if secondaryImage.vectors.count > 0{
                        overallPercentage = computePercentage(numImg: primaryImage, denImg: secondaryImage)
                    } else {
                        handler(.failure(NSError(domain: "ERROR: Unable to Parse Image. No lines were recognized for the Secondary Image supplied.", code: 0, userInfo: nil)), nil)
                    }
                }
                handler(.success(overallPercentage), [primaryImage, secondaryImage])
            } else {
                handler(.failure(NSError(domain: "ERROR: Empty parsed image objects", code: 0, userInfo: nil)), nil)
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
        for numVector in numImg.vectors{
            if let denVector = denImg.vectors.min(by: {abs($0.angle - numVector.angle) < abs($1.angle - numVector.angle)}){
                var numerator = 0.0
                if denVector.angle >= numVector.angle{
                    numerator = 180 - (denVector.angle - numVector.angle)
                } else {
                    numerator = 180 - (numVector.angle - denVector.angle)
                }
                totalPercentage = totalPercentage + (numerator / 180)
            }
        }
        return totalPercentage / Double(denImg.vectors.count)
    }
}

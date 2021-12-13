//
//  ViewController.swift
//  SignatureComparisonExperiment
//
//  Created by Paul Mayer on 9/23/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var signatureView: CanvasView!
    @IBOutlet weak var lblSignHere: UILabel!
    @IBOutlet weak var secondarySignatureView: CanvasView!
    @IBOutlet weak var secondaryLblSignHere: UILabel!
    @IBOutlet weak var btnSaveImg: UIButton!
    @IBOutlet weak var btnGetImg: UIButton!
    @IBOutlet weak var btnCompare: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    
    var currentTopSignature: UIImage?
    var currentBottomSignature: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnCompare.layer.cornerRadius = 12
        btnSaveImg.layer.cornerRadius = 12
        btnGetImg.layer.cornerRadius = 12
        btnClear.layer.cornerRadius = 12
        
        signatureView.delegate = self
        secondarySignatureView.delegate = self
        secondarySignatureView.drawWidth = 6
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let doneBtn = UIAlertAction(title: "Done", style: .cancel, handler: nil)
        alert.addAction(doneBtn)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnCompare(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15) {
            if let sourceImg = self.signatureView.image,
               let secondaryImg = self.secondarySignatureView.image{
                SignatureDriver.compareWithDebugView(self, sourceImg, secondaryImg)
            } else{
                self.showAlert(message: "There must be two signatures to use the compare feature.")
            }
        }
    }
    
    @IBAction func btnSaveImgs(_ sender: UIButton) {
        if let topImage = currentTopSignature, let bottomImage = currentBottomSignature {
            let topPngData = topImage.pngData()
            UserDefaults.standard.setValue(topPngData, forKey: "TopImage")
            let bottomPngData = bottomImage.pngData()
            UserDefaults.standard.setValue(bottomPngData, forKey: "BottomImage")
            showAlert(message: "Images Saved.")
        } else{
            showAlert(message: "There must be at least two signatures to save.")
        }
    }
    
    
    @IBAction func btnGetImg(_ sender: UIButton) {
        if let topImgData = UserDefaults.standard.value(forKey: "TopImage") as? Data,
           let bottomImgData = UserDefaults.standard.value(forKey: "BottomImage") as? Data{
            let topImage = UIImage(data: topImgData)
            let bottomImage = UIImage(data: bottomImgData)
            signatureView.image = topImage
            secondarySignatureView.image = bottomImage
            btnCompare(sender)
        } else {
            showAlert(message: "There are no saved images yet.")
        }
    }
    
    
    @IBAction func clearSignatures(_ sender: UIButton) {
        signatureView.clearImage()
        secondarySignatureView.clearImage()
        lblSignHere.isHidden = false
        secondaryLblSignHere.isHidden = false
    }
}

extension ViewController: CanvasViewDelegate{
    func signatureStarted(tag: Int) {
        if tag == 0{
            lblSignHere.isHidden = true
        } else {
            secondaryLblSignHere.isHidden = true
        }
    }
    
    func signatureEnded(tag: Int) {
        if signatureView.image != nil, tag == 0{
            currentTopSignature = signatureView.image
        } else if secondarySignatureView.image != nil, tag == 1{
            currentBottomSignature = secondarySignatureView.image
        }
    }
}



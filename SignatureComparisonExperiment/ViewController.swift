//
//  ViewController.swift
//  SignatureComparisonExperiment
//
//  Created by Paul Mayer on 9/23/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var signatureView: CanvasView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgScrollView: UIScrollView!
    @IBOutlet weak var lblSignHere: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!

    @IBOutlet weak var secondarySignatureView: CanvasView!
    @IBOutlet weak var secondaryImgView: UIImageView!
    @IBOutlet weak var secondaryImgScrollView: UIScrollView!
    @IBOutlet weak var secondaryLblSignHere: UILabel!
    @IBOutlet weak var secondaryLoader: UIActivityIndicatorView!

    @IBOutlet weak var btnSaveImg: UIButton!
    @IBOutlet weak var btnGetImg: UIButton!
    @IBOutlet weak var btnCompare: UIButton!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var centerViewOffsetConstraint: NSLayoutConstraint!
    
    var comparePressed = false
    var debugImages: [DebugImageName] = []
    var currentTopParsedImgObj: ParsedImage?
    var currentTopDebugImg: DebugImageName?
    var currentBottomParsedImgObj: ParsedImage?
    var currentBottomDebugImg: DebugImageName?
    var currentTopSignature: UIImage?
    var currentBottomSignature: UIImage?
    var originalSignatureViewHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signatureView.drawColor = .black
        signatureView.drawWidth = 1
        signatureView.delegate = self
        originalSignatureViewHeight = signatureView.frame.height
        secondarySignatureView.drawColor = .black
        secondarySignatureView.drawWidth = 6
        secondarySignatureView.delegate = self
        
        imgScrollView.delegate = self
        imgScrollView.minimumZoomScale = 1.0
        imgScrollView.maximumZoomScale = 1000.0
        imgScrollView.tag = 0
        imgScrollView.isMultipleTouchEnabled = true
        secondaryImgScrollView.delegate = self
        secondaryImgScrollView.minimumZoomScale = 1.0
        secondaryImgScrollView.maximumZoomScale = 1000.0
        secondaryImgScrollView.tag = 1
        
        loader.isHidden = true
        loader.style = .large
        secondaryLoader.isHidden = true
        secondaryLoader.style = .large
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanMiddleView(_:)))
        centerView.addGestureRecognizer(dragGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnDebugImg(_:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(didTapOnDebugImg(_:)))
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(tapGesture)
        secondaryImgView.isUserInteractionEnabled = true
        secondaryImgView.addGestureRecognizer(tapGesture2)
        
        centerView.layer.cornerRadius = 10
        btnCompare.layer.cornerRadius = 12
        btnSaveImg.layer.cornerRadius = 12
        btnGetImg.layer.cornerRadius = 12
    }
    
    @objc func didPanMiddleView(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        if translation.y < ((originalSignatureViewHeight / 4) * 3) &&
            translation.y > -((originalSignatureViewHeight / 4) * 3){
            centerViewOffsetConstraint.constant =  translation.y
        }
    }
    
    @objc func didTapOnDebugImg(_ sender: UITapGestureRecognizer){
        if comparePressed{
            self.imgScrollView.zoomScale = 1.0
            self.secondaryImgScrollView.zoomScale = 1.0
            debugImages = []
            if sender.view?.tag == 0{
                let debubImgTemp = currentTopParsedImgObj?.debugImageDic.map({$0.key}) ?? []
                debugImages = debubImgTemp.sorted(by: {$0.rawValue < $1.rawValue})
            } else {
                let debubImgTemp = currentBottomParsedImgObj?.debugImageDic.map({$0.key}) ?? []
                debugImages = debubImgTemp.sorted(by: {$0.rawValue < $1.rawValue})
            }
            let sourceView = sender.view?.convert(sender.view?.bounds ?? self.view.bounds, to: self.view) ?? CGRect()
            let dropdown = DropDownView(sourceView: sourceView,
                                        customCellName: "",
                                        direction: (sender.view?.tag == 0 ? .ArrowDown : .ArrowUp),
                                        maxWidth: 300,
                                        maxHeight: 50 * CGFloat(debugImages.count),
                                        xOffset: -10,
                                        yOffset: nil,
                                        arrowOffset: nil,
                                        bgColor: UIColor.lightGray,
                                        cornerRadias: 12,
                                        autoDismiss: true,
                                        addShadow: true,
                                        borderWidth: nil,
                                        borderColor: nil,
                                        addCellSeparator: nil,
                                        tag: sender.view?.tag)
            dropdown.delegate = self
            dropdown.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            dropdown.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(dropdown, animated: false, completion: nil)
        } else{
            showAlert(message: "There are no signatures to view yet.")
        }
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
                self.lblSignHere.isHidden = true
                self.secondaryLblSignHere.isHidden = true
                sender.isEnabled = false
                self.signatureView.clearImage()
                self.loader.isHidden = false
                self.loader.startAnimating()
                self.signatureView.isUserInteractionEnabled = false
                self.secondarySignatureView.clearImage()
                self.secondaryLoader.isHidden = false
                self.secondaryLoader.startAnimating()
                self.secondarySignatureView.isUserInteractionEnabled = false
                self.comparePressed = true
                
                SignatureDriver.compareSignatures(sourceImg,
                                                  secondaryImg,
                                                  true) { result,
                                                          parsedImages in
                    DispatchQueue.main.async {
                        sender.isEnabled = true
                        self.loader.isHidden = true
                        self.loader.stopAnimating()
                        self.signatureView.isUserInteractionEnabled = true
                        self.lblSignHere.isHidden = false
                        self.secondaryLoader.isHidden = true
                        self.secondaryLoader.stopAnimating()
                        self.secondarySignatureView.isUserInteractionEnabled = true
                        self.secondaryLblSignHere.isHidden = false
                        
                        switch result{
                        case .success(let percentage):
                            if let parsedImgs = parsedImages, parsedImgs.count > 0{
                                self.currentTopParsedImgObj = parsedImgs.first
                                self.imgView.image = self.currentTopParsedImgObj?.debugImageDic[.phase3]
                                self.currentBottomParsedImgObj = parsedImgs.last
                                self.imgScrollView.zoomScale = 1.0
                                self.secondaryImgScrollView.zoomScale = 1.0
                                self.secondaryImgView.image = self.currentBottomParsedImgObj?.debugImageDic[.phase3]
                            }
                            self.showAlert(message: "\(Int(round(percentage * 100)))% Match")
                        case .failure(let error):
                            self.showAlert(message: error.localizedDescription)
                        }
                    }
                }
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

extension ViewController: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView.tag == 0{
            return imgView
        } else if scrollView.tag == 1{
            return secondaryImgView
        }
        return nil
    }
}

//MARK: - Drop Down Delegate
extension ViewController : DropDownDelegate{
    
    func tableViewPopup(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return debugImages.count
    }
    
    func tableViewPopup(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, tag: Int) -> UITableViewCell {
        let cell = UITableViewCell()
        let debugImage = debugImages[indexPath.row]
        if (debugImage == currentTopDebugImg && tag == 0) || (debugImage == currentBottomDebugImg && tag == 1){
            cell.textLabel?.textColor = .YellowLime()
        } else {
            cell.textLabel?.textColor = .black
        }
        cell.contentView.backgroundColor = .lightGray
        cell.textLabel?.text = debugImage.rawValue.capitalized
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        cell.textLabel?.textAlignment = .left
        return cell
    }
    
    func tableViewPopup(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, tag: Int) {
        let debugImg = debugImages[indexPath.row]
        if tag == 0 {
            currentTopDebugImg = debugImg
            imgView.image = currentTopParsedImgObj?.debugImageDic[debugImg]
        } else{
            currentBottomDebugImg = debugImg
            secondaryImgView.image = currentBottomParsedImgObj?.debugImageDic[debugImg]
        }
    }
    
    func tableViewPopup(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func popupDismissed() {
        UIView.animate(withDuration: 0.1) {
//            self.navBar.imgSort.tintColor = .white
//            self.navBar.lblSort.textColor = .white
        }
    }
}


//
//  ComparisonView.swift
//  SignatureComparisonExperiment
//
//  Created by Paul Mayer on 12/3/21.
//

import UIKit

class ComparisonView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var topScrollView: UIScrollView!
    @IBOutlet weak var topImgView: UIImageView!
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var bottomImgView: UIImageView!
    
    var parentVC: UIViewController?
    var debugImages: [DebugImageName] = []
    var currentTopParsedImgObj: ParsedImage?
    var currentTopDebugImg: DebugImageName?
    var currentBottomParsedImgObj: ParsedImage?
    var currentBottomDebugImg: DebugImageName?
    let loadingIndicator =  UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        let bundle = Bundle(for: ComparisonView.self)
        let nib = UINib(nibName: "ComparisonView", bundle: bundle)
        contentView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewDidLoad()
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let doneBtn = UIAlertAction(title: "Done", style: .cancel, handler: nil)
        alert.addAction(doneBtn)
        parentVC?.present(alert, animated: true, completion: nil)
    }
}

private extension ComparisonView{
    
    func viewDidLoad(){
        topScrollView.delegate = self
        topScrollView.minimumZoomScale = 1.0
        topScrollView.maximumZoomScale = 1000.0
        topScrollView.tag = 0
        topImgView.tag = 0
        bottomScrollView.delegate = self
        bottomScrollView.minimumZoomScale = 1.0
        bottomScrollView.maximumZoomScale = 1000.0
        bottomScrollView.tag = 1
        bottomImgView.tag = 1
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnDebugImg(_:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(didTapOnDebugImg(_:)))
        topImgView.isUserInteractionEnabled = true
        topImgView.addGestureRecognizer(tapGesture)
        bottomImgView.isUserInteractionEnabled = true
        bottomImgView.addGestureRecognizer(tapGesture2)
        
        loadingIndicator.style = .large
        loadingIndicator.frame = CGRect(x: (UIScreen.main.bounds.width / 2) - (loadingIndicator.frame.width / 2), y: (UIScreen.main.bounds.height / 2) - 50, width: 0, height: 0)
        loadingIndicator.color = .white
        self.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }
    
    @objc func didTapOnDebugImg(_ sender: UITapGestureRecognizer){
        self.topScrollView.zoomScale = 1.0
        self.bottomScrollView.zoomScale = 1.0
        debugImages = []
        if sender.view?.tag == 0{
            let debubImgTemp = currentTopParsedImgObj?.debugImageDic.map({$0.key}) ?? []
            debugImages = debubImgTemp.sorted(by: {$0.rawValue < $1.rawValue})
        } else {
            let debubImgTemp = currentBottomParsedImgObj?.debugImageDic.map({$0.key}) ?? []
            debugImages = debubImgTemp.sorted(by: {$0.rawValue < $1.rawValue})
        }
        let sourceView = sender.view?.convert(sender.view?.bounds ?? self.contentView.bounds, to: self.contentView) ?? CGRect()
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
        parentVC?.present(dropdown, animated: false, completion: nil)
    }
    
    @IBAction func dismissPressed(_ sender: UIButton) {
        self.removeFromSuperview()
    }
}

//MARK: - Scroll View Delegate
extension ComparisonView: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView.tag == 0{
            return topImgView
        } else if scrollView.tag == 1{
            return bottomImgView
        }
        return nil
    }
}

//MARK: - Drop Down Delegate
extension ComparisonView : DropDownDelegate{
    
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
            topImgView.image = currentTopParsedImgObj?.debugImageDic[debugImg]
        } else{
            currentBottomDebugImg = debugImg
            bottomImgView.image = currentBottomParsedImgObj?.debugImageDic[debugImg]
        }
    }
    
    func tableViewPopup(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func popupDismissed() {
        debugPrint("Nothing here")
    }
}

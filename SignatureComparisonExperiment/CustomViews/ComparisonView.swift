//
//  ComparisonView.swift
//  SignatureComparisonExperiment
//
//  Created by Paul Mayer on 12/3/21.
//

import UIKit

class ComparisonView: UIView {
    
    var parentVC: UIViewController?
    let topScrollView = UIScrollView()
    let topImgView = UIImageView()
    let bottomScrollView = UIScrollView()
    let bottomImgView = UIImageView()
    let topView = UIView()
    let bottomView = UIView()
    let loadingIndicator =  UIActivityIndicatorView()
    
    var debugImages: [DebugImageName] = []
    var currentTopParsedImgObj: ParsedImage?
    var currentTopDebugImg: DebugImageName?
    var currentBottomParsedImgObj: ParsedImage?
    var currentBottomDebugImg: DebugImageName?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func loadView(){
        
        let contentView = UIView()
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 110))
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -40))
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 40))
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -40))
        
        let stackView = UIStackView()
        stackView.backgroundColor = UIColor.clear
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        stackView.axis = .vertical
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0))

        
        topView.backgroundColor = UIColor.clear
        stackView.addArrangedSubview(topView)

        bottomView.backgroundColor = UIColor.clear
        stackView.addArrangedSubview(bottomView)

        topScrollView.delegate = self
        topScrollView.minimumZoomScale = 1.0
        topScrollView.maximumZoomScale = 1000.0
        topScrollView.tag = 0
        topScrollView.frame = topView.bounds
        topScrollView.backgroundColor = UIColor.clear
        topView.addSubview(topScrollView)
        topScrollView.translatesAutoresizingMaskIntoConstraints = false
        topView.addConstraint(NSLayoutConstraint(item: topScrollView, attribute: .top, relatedBy: .equal, toItem: topView, attribute: .top, multiplier: 1, constant: 0))
        topView.addConstraint(NSLayoutConstraint(item: topScrollView, attribute: .trailing, relatedBy: .equal, toItem: topView, attribute: .trailing, multiplier: 1, constant: 0))
        topView.addConstraint(NSLayoutConstraint(item: topScrollView, attribute: .leading, relatedBy: .equal, toItem: topView, attribute: .leading, multiplier: 1, constant: 0))
        topView.addConstraint(NSLayoutConstraint(item: topScrollView, attribute: .bottom, relatedBy: .equal, toItem: topView, attribute: .bottom, multiplier: 1, constant: 0))
        topView.addConstraint(NSLayoutConstraint(item: topScrollView, attribute: .centerX, relatedBy: .equal, toItem: topView, attribute: .centerX, multiplier: 1, constant: 0))
        topView.addConstraint(NSLayoutConstraint(item: topScrollView, attribute: .centerY, relatedBy: .equal, toItem: topView, attribute: .centerY, multiplier: 1, constant: 0))

        topImgView.backgroundColor = UIColor.DarkBlue()
        topImgView.tag = 0
        topImgView.contentMode = .scaleAspectFit
        topScrollView.addSubview(topImgView)
        topImgView.translatesAutoresizingMaskIntoConstraints = false
        topScrollView.addConstraint(NSLayoutConstraint(item: topImgView, attribute: .top, relatedBy: .equal, toItem: topScrollView, attribute: .top, multiplier: 1, constant: 0))
        topScrollView.addConstraint(NSLayoutConstraint(item: topImgView, attribute: .trailing, relatedBy: .equal, toItem: topScrollView, attribute: .trailing, multiplier: 1, constant: 0))
        topScrollView.addConstraint(NSLayoutConstraint(item: topImgView, attribute: .leading, relatedBy: .equal, toItem: topScrollView, attribute: .leading, multiplier: 1, constant: 0))
        topScrollView.addConstraint(NSLayoutConstraint(item: topImgView, attribute: .bottom, relatedBy: .equal, toItem: topScrollView, attribute: .bottom, multiplier: 1, constant: 0))
        topScrollView.addConstraint(NSLayoutConstraint(item: topImgView, attribute: .centerX, relatedBy: .equal, toItem: topScrollView, attribute: .centerX, multiplier: 1, constant: 0))
        topScrollView.addConstraint(NSLayoutConstraint(item: topImgView, attribute: .centerY, relatedBy: .equal, toItem: topScrollView, attribute: .centerY, multiplier: 1, constant: 0))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnDebugImg(_:)))
        topImgView.isUserInteractionEnabled = true
        topImgView.addGestureRecognizer(tapGesture)
        
        bottomScrollView.delegate = self
        bottomScrollView.minimumZoomScale = 1.0
        bottomScrollView.maximumZoomScale = 1000.0
        bottomScrollView.tag = 1
        bottomScrollView.frame = bottomView.bounds
        bottomScrollView.backgroundColor = UIColor.clear
        bottomView.addSubview(bottomScrollView)
        bottomScrollView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addConstraint(NSLayoutConstraint(item: bottomScrollView, attribute: .top, relatedBy: .equal, toItem: bottomView, attribute: .top, multiplier: 1, constant: 0))
        bottomView.addConstraint(NSLayoutConstraint(item: bottomScrollView, attribute: .trailing, relatedBy: .equal, toItem: bottomView, attribute: .trailing, multiplier: 1, constant: 0))
        bottomView.addConstraint(NSLayoutConstraint(item: bottomScrollView, attribute: .leading, relatedBy: .equal, toItem: bottomView, attribute: .leading, multiplier: 1, constant: 0))
        bottomView.addConstraint(NSLayoutConstraint(item: bottomScrollView, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .bottom, multiplier: 1, constant: 0))
        bottomView.addConstraint(NSLayoutConstraint(item: bottomScrollView, attribute: .centerX, relatedBy: .equal, toItem: bottomView, attribute: .centerX, multiplier: 1, constant: 0))
        bottomView.addConstraint(NSLayoutConstraint(item: bottomScrollView, attribute: .centerY, relatedBy: .equal, toItem: bottomView, attribute: .centerY, multiplier: 1, constant: 0))

        bottomImgView.backgroundColor = UIColor.DarkBlue()
        bottomImgView.tag = 1
        bottomImgView.contentMode = .scaleAspectFit
        bottomScrollView.addSubview(bottomImgView)
        bottomImgView.translatesAutoresizingMaskIntoConstraints = false
        bottomScrollView.addConstraint(NSLayoutConstraint(item: bottomImgView, attribute: .top, relatedBy: .equal, toItem: bottomScrollView, attribute: .top, multiplier: 1, constant: 0))
        bottomScrollView.addConstraint(NSLayoutConstraint(item: bottomImgView, attribute: .trailing, relatedBy: .equal, toItem: bottomScrollView, attribute: .trailing, multiplier: 1, constant: 0))
        bottomScrollView.addConstraint(NSLayoutConstraint(item: bottomImgView, attribute: .leading, relatedBy: .equal, toItem: bottomScrollView, attribute: .leading, multiplier: 1, constant: 0))
        bottomScrollView.addConstraint(NSLayoutConstraint(item: bottomImgView, attribute: .bottom, relatedBy: .equal, toItem: bottomScrollView, attribute: .bottom, multiplier: 1, constant: 0))
        bottomScrollView.addConstraint(NSLayoutConstraint(item: bottomImgView, attribute: .centerX, relatedBy: .equal, toItem: bottomScrollView, attribute: .centerX, multiplier: 1, constant: 0))
        bottomScrollView.addConstraint(NSLayoutConstraint(item: bottomImgView, attribute: .centerY, relatedBy: .equal, toItem: bottomScrollView, attribute: .centerY, multiplier: 1, constant: 0))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(didTapOnDebugImg(_:)))
        bottomImgView.isUserInteractionEnabled = true
        bottomImgView.addGestureRecognizer(tapGesture2)
        
        let dismissBtn = UIButton()
        dismissBtn.setTitle("Dismiss", for: .normal)
        dismissBtn.backgroundColor = UIColor.darkGray
        dismissBtn.tintColor = UIColor.white
        dismissBtn.addTarget(self, action: #selector(dismissPressed(_:)), for: .touchUpInside)
        self.addSubview(dismissBtn)
        dismissBtn.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: dismissBtn, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 35))
        self.addConstraint(NSLayoutConstraint(item: dismissBtn, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: dismissBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 70))
        self.addConstraint(NSLayoutConstraint(item: dismissBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200))

        loadingIndicator.style = .large
        loadingIndicator.frame = CGRect(x: (UIScreen.main.bounds.width / 2) - (loadingIndicator.frame.width / 2), y: (UIScreen.main.bounds.height / 2) - 50, width: 0, height: 0)
        loadingIndicator.color = .white
        self.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let doneBtn = UIAlertAction(title: "Done", style: .cancel, handler: nil)
        alert.addAction(doneBtn)
        parentVC?.present(alert, animated: true, completion: nil)
    }
}

private extension ComparisonView{
    
    @objc func didTapOnDebugImg(_ sender: UITapGestureRecognizer){
        debugImages = []
        var sourcViewFrame: UIView!
        if sender.view?.tag == 0{
            let debubImgTemp = currentTopParsedImgObj?.debugImageDic.map({$0.key}) ?? []
            debugImages = debubImgTemp.sorted(by: {$0.rawValue < $1.rawValue})
            sourcViewFrame = topView
        } else {
            let debubImgTemp = currentBottomParsedImgObj?.debugImageDic.map({$0.key}) ?? []
            debugImages = debubImgTemp.sorted(by: {$0.rawValue < $1.rawValue})
            sourcViewFrame = bottomView
        }

        let sourceView = sourcViewFrame.convert(sender.view?.bounds ?? self.bounds, to: self)
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
    
    @objc func dismissPressed(_ sender: UIButton) {
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

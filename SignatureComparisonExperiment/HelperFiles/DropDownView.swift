//
//  DropDownView.swift
//  CityBikes
//
//  Created by Sigurd Paul Mayer on 2/7/21.
//

import Foundation
import UIKit


protocol DropDownDelegate{
    func tableViewPopup(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func tableViewPopup(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, tag: Int) -> UITableViewCell
    func tableViewPopup(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, tag: Int)
    func tableViewPopup(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    func popupDismissed()
}

class DropDownView: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    var delegate: DropDownDelegate?
    private var sourceRec: CGRect!
    private var customCellName: String!
    private var tvDirection: Direction!
    private var tvMaxWidth: CGFloat!
    private var tvMaxHeight: CGFloat!
    private var tvPosXOffset: CGFloat!
    private var tvPosYOffset: CGFloat!
    private var arrowOffset: CGFloat!
    private var tvBgColor: UIColor!
    private var tvCornerRadias: CGFloat!
    private var autoDismiss: Bool!
    private var addShadow: Bool!
    private var tvBorderWidth: CGFloat!
    private var tvBorderColor: UIColor!
    private var addCellSeparator: Bool!
    private var tableViewTag: Int!
    
    private var tvPopUp: UITableView!
    private var tvSize: CGSize!
    private var currentTvRec: CGRect!
    private var addArrow = false
    private var animationDirection: AnimationDirection!
    private var arrowImage = CBImageView()
    private let safeAreaOffset: CGFloat = 7
    private var isInitalLoad = true
    private var shadowView: UIView!
    
    enum Direction : String{
        case Up = "up"
        case Down = "down"
        case Right = "right"
        case Left = "left"
        case ArrowUp = "arrowUp"
        case ArrowDown = "arrowDown"
        case ArrowRight = "arrowRight"
        case ArrowLeft = "arrowLeft"
    }
    
    private enum AnimationDirection{
        case Up
        case Down
        case Right
        case Left
    }
    
    // MARK: - Initializers
    init(sourceView: CGRect, customCellName: String?, direction: Direction?, maxWidth: CGFloat?, maxHeight: CGFloat?, xOffset: CGFloat?, yOffset: CGFloat?, arrowOffset: CGFloat?, bgColor: UIColor?, cornerRadias: CGFloat?, autoDismiss: Bool?, addShadow:Bool?, borderWidth: CGFloat?, borderColor: UIColor?, addCellSeparator: Bool?, tag: Int?){
        self.sourceRec = sourceView
        self.customCellName = customCellName ?? ""
        self.tvDirection = direction ?? .Down
        self.animationDirection = .Down
        self.tvMaxWidth = maxWidth ?? 150
        self.tvMaxHeight = maxHeight  ?? 150
        self.tvPosXOffset = xOffset ?? 0
        self.tvPosYOffset = yOffset ?? 0
        self.arrowOffset = arrowOffset ?? 0
        self.tvBgColor = bgColor ?? .white
        self.tvCornerRadias = cornerRadias ?? 10
        self.autoDismiss = autoDismiss ?? false
        self.addShadow = addShadow ?? false
        self.tvBorderWidth = borderWidth ?? 0.0
        self.tvBorderColor = borderColor ?? .clear
        self.addCellSeparator = addCellSeparator ?? true
        self.tvSize = CGSize(width: tvMaxWidth, height: tvMaxHeight)
        self.tvPopUp = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .grouped)
        self.tableViewTag = tag ?? 0
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRecOfTV()
        //--------- Screen Boundry Checks Begin --------------//
        //Right Edge Check
        let posXDiff = tvPopUp.frame.maxX - UIScreen.main.bounds.width
        if posXDiff >= 0 {
            tvPosXOffset = -(tvPosXOffset)
            if tvDirection == .Right{
                tvDirection = .Left
                setRecOfTV()
            } else if tvDirection == .ArrowRight{
                tvDirection = .ArrowLeft
                setRecOfTV()
            }
        }
        
        //Left Edge Check
        if tvPopUp.frame.minX < safeAreaOffset {
            tvPosXOffset = -(tvPosXOffset)
            if tvDirection == .Left{
                tvDirection = .Right
                setRecOfTV()
            } else if tvDirection == .ArrowLeft{
                tvDirection = .ArrowRight
                setRecOfTV()
            }
        }
        
        //Bottom Edge Check
        let posYDiff = tvPopUp.frame.maxY - UIScreen.main.bounds.height
        if posYDiff >= 0 {
            tvPosYOffset = -(tvPosYOffset)
            if tvDirection == .Down{
                tvDirection = .Up
                setRecOfTV()
            } else if tvDirection == .ArrowDown{
                tvDirection = .ArrowUp
                setRecOfTV()
            }
        }
        
        //Top Edge Check
        if tvPopUp.frame.minY < safeAreaOffset {
            tvPosYOffset = -(tvPosYOffset)
            if tvDirection == .Up{
                tvDirection = .Down
                setRecOfTV()
            } else if tvDirection == .ArrowUp{
                tvDirection = .ArrowDown
                setRecOfTV()
            }
        }
        
        //Right Edge Check
        let posXDiffNum2 = tvPopUp.frame.maxX - UIScreen.main.bounds.width
        if posXDiffNum2 >= 0 {
            tvPopUp.center.x = tvPopUp.center.x - (posXDiffNum2 + safeAreaOffset)
        }
        
        //Left Edge Check
        if tvPopUp.frame.minX < safeAreaOffset {
            tvPopUp.center.x = tvPopUp.center.x  + (-(tvPopUp.frame.minX) + safeAreaOffset)
        }
        
        //Bottom Edge Check
        let posYDiffNum2 = tvPopUp.frame.maxY - UIScreen.main.bounds.height
        if posYDiffNum2 >= 0 {
            tvPopUp.center.y = tvPopUp.center.y - (posYDiffNum2 + safeAreaOffset)
        }
        
        //Top Edge Check
        if tvPopUp.frame.minY < safeAreaOffset {
            tvPopUp.center.y = tvPopUp.center.y  + (-(tvPopUp.frame.minY) + safeAreaOffset)
        }
        //--------- Screen Boundry Checks End --------------//
        
        //Set Arrow Props
        if tvDirection.rawValue.lowercased().contains("arrow"){
            addArrow = true
            arrowImage.layer.zPosition = 4
            arrowImage.image = arrowImage.image?.withRenderingMode(.alwaysTemplate)
            updateArrowColor()
            if addShadow{
                setLayerShadow(layer: arrowImage.layer)
            }
            self.view.addSubview(arrowImage)
        }
        
        //Add Shadow Props
        if addShadow{
            shadowView = UIView(frame: tvPopUp.frame)
            shadowView.backgroundColor = tvBgColor.withAlphaComponent(0.99)//This cannot be 0.0 or 1.0
            shadowView.layer.cornerRadius = self.tvCornerRadias
            setLayerShadow(layer: shadowView.layer)
            shadowView.layer.zPosition = 3
            self.view.addSubview(shadowView)
        }
        
        //Set TV Props
        tvPopUp.dataSource = self
        tvPopUp.delegate = self
        if !(customCellName.isEmpty){
            tvPopUp.register(UINib(nibName: customCellName, bundle: nil), forCellReuseIdentifier: customCellName)
        } else {
            tvPopUp.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        }
        tvPopUp.layer.cornerRadius = tvCornerRadias
        tvPopUp.layer.zPosition = 5
        tvPopUp.backgroundColor = tvBgColor
        if tvBorderWidth != 0.0 {
            tvPopUp.layer.borderWidth = tvBorderWidth
            tvPopUp.layer.borderColor = tvBorderColor.cgColor
        }
        tvPopUp.tableFooterView = UIView()
        tvPopUp.layoutMargins = UIEdgeInsets.zero
        tvPopUp.separatorInset = UIEdgeInsets.zero
        tvPopUp.bounces = false
        if addCellSeparator{
            tvPopUp.separatorStyle = .singleLine
        } else{
            tvPopUp.separatorStyle = .none
        }
        tvSize = tvPopUp.frame.size
        self.view.addSubview(tvPopUp)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        dismissViewWithAnimation()
    }
    
    //MARK: - IBActions Functions
    @objc func screenTouched(_ sender : UITapGestureRecognizer){
        self.view.isUserInteractionEnabled = false
        dismissViewWithAnimation()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.tvPopUp) == true {
            return false
         }
         return true
    }
    
    //MARK: - Functions
    func setRecOfTV(){
        var arrowHeight: CGFloat = 0
        var arrowWidth: CGFloat = 0
        var tvRec = CGRect()
        
        switch tvDirection {
        case .Up:
            animationDirection = .Up
            tvRec = CGRect(x: sourceRec.minX + tvPosXOffset, y: sourceRec.minY - (tvMaxHeight + arrowHeight) + tvPosYOffset, width: tvMaxWidth, height: tvMaxHeight)
        case .Down:
            animationDirection = .Down
            tvRec = CGRect(x: sourceRec.minX + tvPosXOffset, y: sourceRec.maxY + arrowHeight + tvPosYOffset, width: tvMaxWidth, height: tvMaxHeight)
        case .Right:
            animationDirection = .Right
            tvRec = CGRect(x: sourceRec.maxX + tvPosXOffset, y: sourceRec.midY - (tvMaxHeight / 2) + tvPosYOffset, width: tvMaxWidth, height: tvMaxHeight)
        case .Left:
            animationDirection = .Left
            tvRec = CGRect(x: sourceRec.minX - tvMaxWidth + tvPosXOffset, y: sourceRec.midY - (tvMaxHeight / 2) + tvPosYOffset, width: tvMaxWidth, height: tvMaxHeight)
        case .ArrowUp:
            animationDirection = .Up
            arrowHeight = 8
            arrowWidth = 16
            arrowImage = CBImageView(frame: CGRect(x: sourceRec.midX - (arrowWidth / 2) + arrowOffset, y: sourceRec.minY - arrowHeight + tvPosYOffset, width: arrowWidth, height: arrowHeight))
            arrowImage.image = UIImage(named: "img_arrow_vertical")
            arrowImage.transform = CGAffineTransform(rotationAngle: .pi)
            tvRec = CGRect(x: sourceRec.midX - (tvMaxHeight / 2) + tvPosXOffset, y: sourceRec.minY - (tvMaxHeight + arrowHeight) + tvPosYOffset, width: tvMaxWidth, height: tvMaxHeight)
        case .ArrowDown:
            animationDirection = .Down
            arrowHeight = 8
            arrowWidth = 16
            arrowImage = CBImageView(frame: CGRect(x: sourceRec.midX - (arrowWidth / 2) + arrowOffset, y: sourceRec.maxY + tvPosYOffset, width: arrowWidth, height: arrowHeight))
            arrowImage.image = UIImage(named: "img_arrow_vertical")
            tvRec = CGRect(x: sourceRec.midX - (tvMaxWidth / 2) + tvPosXOffset, y: sourceRec.maxY + arrowHeight + tvPosYOffset, width: tvMaxWidth, height: tvMaxHeight)
        case .ArrowRight:
            animationDirection = .Right
            arrowHeight = 16
            arrowWidth = 8
            arrowImage = CBImageView(frame: CGRect(x: sourceRec.maxX + tvPosXOffset, y: sourceRec.midY - (arrowHeight / 2) + arrowOffset, width: arrowWidth, height: arrowHeight))
            arrowImage.image = UIImage(named: "img_arrow_horizontal")
            arrowImage.transform = CGAffineTransform(rotationAngle: .pi)
            tvRec = CGRect(x: sourceRec.maxX + arrowWidth + tvPosXOffset, y: sourceRec.midY - (tvMaxHeight / 2) + tvPosYOffset, width: tvMaxWidth, height: tvMaxHeight)
        case .ArrowLeft:
            animationDirection = .Left
            arrowHeight = 16
            arrowWidth = 8
            arrowImage = CBImageView(frame: CGRect(x: sourceRec.minX - (arrowWidth / 2) + tvPosXOffset, y: sourceRec.midY - (arrowHeight / 2) + arrowOffset, width: arrowWidth, height: arrowHeight))
            arrowImage.image = UIImage(named: "img_arrow_horizontal")
            tvRec = CGRect(x: sourceRec.minX - (tvMaxWidth + (arrowWidth / 2)) + tvPosXOffset, y: sourceRec.midY - (tvMaxHeight / 2) + tvPosYOffset, width: tvMaxWidth, height: tvMaxHeight)
        case .none:
            animationDirection = .Down
        }
        
        tvPopUp = UITableView(frame: tvRec)
        self.currentTvRec = tvRec
    }
    
    func updateArrowColor(){
        arrowImage.tintColor = self.tvBgColor
    }
    
    func setLayerShadow(layer: CALayer){
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 3
        layer.shadowColor = UIColor.black.cgColor
    }
    
    func refreshPopup(){
        tvPopUp.reloadData()
    }
    
    
    //MARK: - Animation Functions
    func showOnLoadAnimation(){
        switch animationDirection {
        case .Up:
            self.tvPopUp.frame = CGRect(x: self.tvPopUp.frame.origin.x, y: self.tvPopUp.frame.origin.y + self.tvMaxHeight, width: self.tvMaxWidth, height: 0)
        case .Down:
            self.tvPopUp.frame = CGRect(origin: self.tvPopUp.frame.origin, size: CGSize(width: self.tvMaxWidth, height: 0))
        case .Left:
            self.tvPopUp.frame = CGRect(x: self.tvPopUp.frame.origin.x + self.tvMaxWidth, y: self.tvPopUp.frame.origin.y, width: 0, height: self.tvMaxHeight)
        case .Right:
            self.tvPopUp.frame = CGRect(x: self.tvPopUp.frame.origin.x, y: self.tvPopUp.frame.origin.y, width: 0, height: self.tvMaxHeight)
        default:
            self.tvPopUp.frame = CGRect(origin: self.tvPopUp.frame.origin, size: CGSize(width: self.tvMaxWidth, height: 0))
        }
        if self.addShadow{
            self.shadowView.frame = self.tvPopUp.frame
        }
        UIView.animate(withDuration: 0.2, animations: {
            switch self.animationDirection {
            case .Up:
                self.tvPopUp.frame = CGRect(x: self.tvPopUp.frame.origin.x, y: self.tvPopUp.frame.origin.y - self.tvMaxHeight, width: self.tvMaxWidth, height: self.tvMaxHeight)
            case .Down:
                self.tvPopUp.frame = CGRect(origin: self.tvPopUp.frame.origin, size: CGSize(width: self.tvMaxWidth, height: self.tvMaxHeight))
            case .Left:
                self.tvPopUp.frame = CGRect(x: self.tvPopUp.frame.origin.x - self.tvMaxWidth, y: self.tvPopUp.frame.origin.y, width: self.tvMaxWidth, height: self.tvMaxHeight)
            case .Right:
                self.tvPopUp.frame = CGRect(x: self.tvPopUp.frame.origin.x, y: self.tvPopUp.frame.origin.y, width: self.tvMaxWidth, height: self.tvMaxHeight)
            default:
                self.tvPopUp.frame = CGRect(origin: self.tvPopUp.frame.origin, size: CGSize(width: self.tvMaxWidth, height: self.tvMaxHeight))
            }
            if self.addShadow{
                self.shadowView.frame = self.tvPopUp.frame
            }
        }) { (animation) in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.screenTouched(_:)))
            self.view.addGestureRecognizer(tapGesture)
            tapGesture.delegate = self
            self.view.isUserInteractionEnabled = true
        }
    }
    
    func dismissViewWithAnimation(delay : Double = 0){
        self.view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIView.animate(withDuration: 0.2, animations: {
                switch self.animationDirection {
                case .Up:
                    self.tvPopUp.frame = CGRect(x: self.tvPopUp.frame.origin.x, y: self.tvPopUp.frame.origin.y +  self.tvPopUp.frame.height, width: self.tvPopUp.frame.width, height: 0)
                case .Down:
                    self.tvPopUp.frame = CGRect(origin: self.tvPopUp.frame.origin, size: CGSize(width: self.tvPopUp.frame.width, height: 0))
                case .Left:
                    self.tvPopUp.frame = CGRect(x: self.tvPopUp.frame.origin.x + self.tvMaxWidth, y: self.tvPopUp.frame.origin.y, width: 0, height: self.tvMaxHeight)
                case .Right:
                    self.tvPopUp.frame = CGRect(x: self.tvPopUp.frame.origin.x, y: self.tvPopUp.frame.origin.y, width: 0, height: self.tvMaxHeight)
                default:
                    self.tvPopUp.frame = CGRect(origin: self.tvPopUp.frame.origin, size: CGSize(width: self.tvPopUp.frame.width, height: 0))
                }
                if self.addShadow{
                    self.shadowView.frame = self.tvPopUp.frame
                }
            }) { (animation) in
                self.view.isUserInteractionEnabled = true
                self.dismiss(animated: false, completion: nil)
                if let delegate = self.delegate{
                    delegate.popupDismissed()
                }
            }
        }
    }
    
    //MARK: - Table View & Data Source Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let delegate = self.delegate{
            return delegate.tableViewPopup(tableView, numberOfRowsInSection: section)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let delegate = self.delegate{
            return delegate.tableViewPopup(tableView, cellForRowAt: indexPath, tag: self.tableViewTag)
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let delegate = self.delegate{
            return delegate.tableViewPopup(tableView, heightForRowAt: indexPath)
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = self.delegate{
            delegate.tableViewPopup(tableView, didSelectRowAt: indexPath, tag: self.tableViewTag)
        }
        tableView.reloadData()
        if autoDismiss{
            dismissViewWithAnimation(delay: 0.2)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath && isInitalLoad {
                self.showOnLoadAnimation()
                isInitalLoad = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
}



//
//  CBImageView.swift
//  MetalAndImages
//
//  Created by Paul Mayer on 8/22/21.
//
import UIKit

@IBDesignable
class CBImageView: UIImageView {
    
    @IBInspectable var imageColor: UIColor = UIColor.clear {
        didSet{
            self.setImageProperties()
        }
    }

    func setImageProperties(){
        image = image?.withRenderingMode(.alwaysTemplate)
        tintColor = imageColor
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setImageProperties()
    }
}

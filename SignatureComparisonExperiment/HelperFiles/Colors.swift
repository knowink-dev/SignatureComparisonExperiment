//
//  Colors.swift
//  CityBikes
//
//  Created by Sigurd Paul Mayer on 2/4/21.
//

import Foundation
import UIKit

extension UIColor {

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    class func DarkBlue() -> UIColor{
        return UIColor(rgb: 0x122272)
    }
    
    class func YellowLime() -> UIColor{
        return UIColor(rgb: 0xC5D428)
    }
}


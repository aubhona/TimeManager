//
//  UIColorExtension.swift
//  ashabdullaevPW2
//
//  Created by Aubkhon Abdullaev on 03.10.2023.
//

import UIKit

// MARK: - UIColor extension

extension UIColor {
    
    // MARK: Constants for converting color
    
    enum Constants {
        static let colorBase : Int = 16
        static let colorLen : Int = 9
        
        static let maxBaseValue : String = "FF"
        
        static let colorMaxValue : Int = 255
        static let countOfColors : Int = 3;
        
        static let minAlphaValue : Int = 128
        static let maxAlphaValue : Int = 255
        
        static let redMask : UInt64 = 0xFF000000
        static let greenMask : UInt64 = 0x00FF0000
        static let blueMask : UInt64 = 0x0000FF00
        static let alfaMask : UInt64 = 0x000000FF
        
        static let redPos : UInt64 = 24
        static let greenPos : UInt64 = 16
        static let bluePos : UInt64 = 8
        
    }
    
    // MARK: init convert hex color to RGB
    
    convenience init(_ hexColor : String) {
        let hexColorChanged = hexColor.replacingOccurrences(of: "#", with: "") + (hexColor.count != Constants.colorLen ? Constants.maxBaseValue : "")
        
        let rgb = UInt64(hexColorChanged, radix: Constants.colorBase)!
        let red = CGFloat((rgb & Constants.redMask) >> Constants.redPos) / CGFloat(Constants.colorMaxValue)
        let green = CGFloat((rgb & Constants.greenMask) >> Constants.greenPos) / CGFloat(Constants.colorMaxValue)
        let blue = CGFloat((rgb & Constants.blueMask) >> Constants.bluePos) / CGFloat(Constants.colorMaxValue)
        let alpha = CGFloat(rgb & Constants.alfaMask) / CGFloat(Constants.colorMaxValue)
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // MARK: Random hex color generator
    
    static func generateRandomHexColor() -> String {
        var hexColor = "#"
        for _ in 0 ..< Constants.countOfColors {
            let randomHex = String(Int.random(in: 0...Constants.colorMaxValue), radix: Constants.colorBase)
            hexColor += randomHex.count == 1 ? "0" + randomHex : randomHex
        }
        hexColor += String(Int.random(in: Constants.minAlphaValue...Constants.maxAlphaValue), radix: Constants.colorBase)
        return hexColor
    }
}

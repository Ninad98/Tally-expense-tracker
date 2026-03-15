//
//  Font+Extensions.swift
//  Tally
//
//  Created by Mazen Tarek on 3/13/26.
//

import SwiftUI

extension Font {

    enum UrbanistWeight: String {
        case regular = "Urbanist-Regular"
        case semiBold = "Urbanist-SemiBold"
        case bold = "Urbanist-Bold"
        case extraBold = "Urbanist-ExtraBold"
    }

    enum ManropeWeight: String {
        case regular = "Manrope-Regular"
        case medium = "Manrope-Medium"
        case bold = "Manrope-Bold"
    }

    static func urbanist(_ weight: UrbanistWeight, size: CGFloat) -> Font {
        .custom(weight.rawValue, size: size)
    }

    static func manrope(_ weight: ManropeWeight, size: CGFloat) -> Font {
        .custom(weight.rawValue, size: size)
    }
}

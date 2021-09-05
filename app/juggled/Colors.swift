//
//  Colors.swift
//  juggled
//
//  Created by Anna Scholtz on 2021-09-04.
//  Copyright © 2021 Anna Scholtz. All rights reserved.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {

        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            // You can handle the failure here as you want
            return (0, 0, 0, 0)
        }

        return (r * 255, g * 255, b * 255, o)
    }
}

extension Color {
    static var entryBackground: Color  {
        return Color("entryBackground")
    }
    
    static var entryShadow: Color  {
        return Color("entryShadow")
    }
}

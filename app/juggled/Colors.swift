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

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red) / 255
        let g = try container.decode(Double.self, forKey: .green) / 255
        let b = try container.decode(Double.self, forKey: .blue) / 255
        
        self.init(red: r, green: g, blue: b)
    }

    public func encode(to encoder: Encoder) throws {
        let colorComponents = self.components
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        print(colorComponents)
        
        try container.encode(colorComponents.red, forKey: .red)
        try container.encode(colorComponents.green, forKey: .green)
        try container.encode(colorComponents.blue, forKey: .blue)
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

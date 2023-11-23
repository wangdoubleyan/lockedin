//
//  Color.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 8/28/23.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let foreground = Color("ForegroundColor")
    let primary = Color("MainColor")
    let secondary = Color("SecondColor")
    let trinary = Color("ThirdColor")
    let surface = Color("SurfaceColor")
    let sky = Color("SkyColor")
    
}

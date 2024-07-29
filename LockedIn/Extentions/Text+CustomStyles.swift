//
//  Text+CustomStyles.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 12/21/23.
//

import Foundation
import SwiftUI

extension Text {
    func largeTitleTextStyle() -> some View {
        self.foregroundColor(Color.theme.foreground)
            .fontDesign(.rounded)
            .font(.system(size: 40))
            .fontWeight(.heavy)
    }
    
    func titleTextStyle() -> some View {
        self.foregroundColor(Color.theme.foreground)
            .fontDesign(.rounded)
            .font(.title)
            .bold()
    }
    
    func mediumTitleTextStyle() -> some View {
        self.foregroundColor(Color.theme.foreground)
            .fontDesign(.rounded)
            .font(.title2)
            .bold()
    }
    
    func smallTitleTextStyle() -> some View {
        self.foregroundColor(Color.theme.foreground)
            .fontDesign(.rounded)
            .font(.title3)
            .bold()
    }
    
    func headlineTextStyle() -> some View {
        self.foregroundColor(Color.theme.secondary)
            .fontDesign(.rounded)
            .font(.headline)
    }
    
    func captionTextStyle() -> some View {
        self.foregroundColor(Color.theme.secondary)
            .fontDesign(.rounded)
            .font(.caption)
    }
}

/// Font styles used across the app.
extension Font {
    
    static var largeTitle: Font {
        return Font.system(.largeTitle, design: .rounded, weight: .heavy)
    }
    
    static var title: Font {
        return Font.system(.title, design: .rounded, weight: .bold)
    }
    
    static var title2: Font {
        return Font.system(.title2, design: .rounded, weight: .bold)
    }
    
    static var title3: Font {
        return Font.system(.title3, design: .rounded, weight: .bold)
    }
    
    static var headline: Font {
        return Font.system(.headline, design: .rounded, weight: .bold)
    }
    
    static var subheadline: Font {
        return Font.system(.subheadline, design: .rounded, weight: .bold)
    }
    
    static var body: Font {
        return Font.system(.body, design: .rounded, weight: .regular)
    }
    
    static var caption: Font {
        return Font.system(.caption, design: .rounded, weight: .regular)
    }
}

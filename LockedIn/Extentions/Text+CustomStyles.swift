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

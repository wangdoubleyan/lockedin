//
//  BackgroundView.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 3/22/24.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        Color.theme.background
            .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
}

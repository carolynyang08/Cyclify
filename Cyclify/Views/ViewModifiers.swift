//
//  ViewModifiers.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/23/25.
//

import SwiftUI

struct BlackBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            content
        }
    }
}

extension View {
    func blackBackground() -> some View {
        modifier(BlackBackgroundModifier())
    }
}

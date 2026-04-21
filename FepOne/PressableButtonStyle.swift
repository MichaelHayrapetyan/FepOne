//
//  PressableButtonStyle.swift
//  FepOne
//

import SwiftUI

/// A reusable button style that gives a tactile press feel:
/// the label scales down on press and springs back on release.
struct PressableButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.88

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5),
                       value: configuration.isPressed)
    }
}

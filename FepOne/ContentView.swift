//
//  ContentView.swift
//  FepOne
//
//  Created by Michael Hayrapetyan on 24.01.26.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var now = Date()
    @State private var is24Hour = false
    @State private var isPressed = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var formatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = is24Hour ? "HH:mm" : "hh:mm"
        return f
    }

    var body: some View {
        Text(formatter.string(from: now))
            .font(.system(size: 72, weight: .bold, design: .monospaced))
            .padding(32)
            .background(.black).opacity(0.75)
            .foregroundStyle(.green)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
            .animation(.easeInOut(duration: 0.25), value: is24Hour)
            .contentTransition(.numericText())
            .onTapGesture {
                isPressed = true
                withAnimation(.easeInOut(duration: 0.25)) {
                    is24Hour.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    isPressed = false
                }
            }
            .onReceive(timer) { input in
                now = input
            }
    }
}

#Preview {
    ContentView()
}

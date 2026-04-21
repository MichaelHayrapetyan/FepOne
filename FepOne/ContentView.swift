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
    @State private var showingAddCity = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @StateObject private var store = CityStore()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var formatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = is24Hour ? "HH:mm" : "hh:mm"
        return f
    }

    private func rowFormatter(for timeZone: TimeZone) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = is24Hour ? "HH:mm" : "hh:mm a"
        f.timeZone = timeZone
        return f
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                clockDisplay
                cityList
            }
            .padding(.top, 16)
            .navigationTitle("World Clock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    themeButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showingAddCity) {
                AddCityView(store: store)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onReceive(timer) { now = $0 }
    }

    // MARK: - Clock

    private var clockDisplay: some View {
        Text(formatter.string(from: now))
            .font(.system(size: 72, weight: .bold, design: .monospaced))
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(white: 0.08))
                    .shadow(color: .green.opacity(0.35), radius: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.green.opacity(0.6), lineWidth: 1)
            )
            .foregroundStyle(.green)
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
    }

    // MARK: - City list

    @ViewBuilder
    private var cityList: some View {
        if store.cities.isEmpty {
            Spacer()
            Text("No cities yet — tap + to add one")
                .foregroundStyle(.secondary)
                .font(.callout)
            Spacer()
        } else {
            List {
                ForEach(store.cities) { city in
                    cityRow(city)
                }
                .onDelete { store.remove(at: $0) }
            }
            .listStyle(.plain)
        }
    }

    private func cityRow(_ city: WorldCity) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(city.name)
                    .font(.body)
                let region = WorldCity.regionName(for: city.timeZoneID)
                if !region.isEmpty {
                    Text(region)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(rowFormatter(for: city.timeZone).string(from: now))
                .font(.system(.title3, design: .monospaced))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        .padding(.vertical, 4)
    }

    // MARK: - Buttons

    private var themeButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                isDarkMode.toggle()
            }
        } label: {
            Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                .font(.title3)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var addButton: some View {
        Button {
            showingAddCity = true
        } label: {
            Image(systemName: "plus")
                .font(.title3)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    ContentView()
}

//
//  WorldClock.swift
//  FepOne
//

import SwiftUI
import Combine

// MARK: - Model

struct WorldCity: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var timeZoneID: String

    var timeZone: TimeZone {
        TimeZone(identifier: timeZoneID) ?? .current
    }

    /// Pretty city name pulled from the end of the TZ identifier.
    static func displayName(for timeZoneID: String) -> String {
        let tail = timeZoneID.split(separator: "/").last.map(String.init) ?? timeZoneID
        return tail.replacingOccurrences(of: "_", with: " ")
    }

    /// Region prefix (e.g. "America", "Europe") for secondary text.
    static func regionName(for timeZoneID: String) -> String {
        let parts = timeZoneID.split(separator: "/")
        guard parts.count > 1 else { return "" }
        return parts.dropLast().joined(separator: "/").replacingOccurrences(of: "_", with: " ")
    }
}

// MARK: - Store

@MainActor
final class CityStore: ObservableObject {
    @Published var cities: [WorldCity] {
        didSet { persist() }
    }

    private let storageKey = "cities.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([WorldCity].self, from: data) {
            self.cities = decoded
        } else {
            // Seed so the list isn't empty on first launch.
            self.cities = [
                WorldCity(name: WorldCity.displayName(for: "America/New_York"),
                          timeZoneID: "America/New_York"),
                WorldCity(name: WorldCity.displayName(for: "Europe/London"),
                          timeZoneID: "Europe/London"),
                WorldCity(name: WorldCity.displayName(for: "Asia/Tokyo"),
                          timeZoneID: "Asia/Tokyo"),
            ]
        }
    }

    func add(timeZoneID: String) {
        guard TimeZone(identifier: timeZoneID) != nil,
              !cities.contains(where: { $0.timeZoneID == timeZoneID }) else { return }
        cities.append(WorldCity(name: WorldCity.displayName(for: timeZoneID),
                                timeZoneID: timeZoneID))
    }

    func remove(at offsets: IndexSet) {
        cities.remove(atOffsets: offsets)
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(cities) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

// MARK: - Add City Sheet

struct AddCityView: View {
    @ObservedObject var store: CityStore
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private var allIdentifiers: [String] {
        TimeZone.knownTimeZoneIdentifiers.sorted()
    }

    private var filtered: [String] {
        let existing = Set(store.cities.map(\.timeZoneID))
        let pool = allIdentifiers.filter { !existing.contains($0) }
        guard !query.isEmpty else { return pool }
        return pool.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            List(filtered, id: \.self) { id in
                Button {
                    store.add(timeZoneID: id)
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(WorldCity.displayName(for: id))
                            .foregroundStyle(.primary)
                        let region = WorldCity.regionName(for: id)
                        if !region.isEmpty {
                            Text(region)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $query, prompt: "Search cities")
            .navigationTitle("Add city")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

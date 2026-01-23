//
//  SharedTimerStore.swift
//  RandomTimer
//
//  Created by Kirstyn Plummer on 1/23/26.
//


import Foundation
import Combine

@MainActor
final class SharedTimerStore: ObservableObject {
    static let suiteName = "group.com.kirstynplummer.randomtimer" // <- change this
    private static let key = "shared.timer.state.v1"

    static let shared = SharedTimerStore()

    @Published private(set) var state: SharedTimerState = .empty

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        guard let d = UserDefaults(suiteName: Self.suiteName) else {
            fatalError("App Group not configured: \(Self.suiteName)")
        }
        defaults = d
        load()
    }

    func load() {
        guard let data = defaults.data(forKey: Self.key),
              let decoded = try? decoder.decode(SharedTimerState.self, from: data) else {
            state = .empty
            return
        }
        state = decoded
    }

    func save(_ newState: SharedTimerState) {
        state = newState
        if let data = try? encoder.encode(newState) {
            defaults.set(data, forKey: Self.key)
        }
    }

    func clear() {
        defaults.removeObject(forKey: Self.key)
        state = .empty
    }
}

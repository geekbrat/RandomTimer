//
//  SharedTimerState.swift
//  RandomTimer
//
//  Created by Kirstyn Plummer on 1/23/26.
//

import Foundation

struct SharedTimerState: Codable, Equatable {
    var minSeconds: Int
    var maxSeconds: Int

    var startDate: Date?
    var endDate: Date?
    var totalSeconds: Int

    var isRunning: Bool
    var isAlarming: Bool

    var updatedAt: Date

    static let empty = SharedTimerState(
        minSeconds: 300,
        maxSeconds: 900,
        startDate: nil,
        endDate: nil,
        totalSeconds: 0,
        isRunning: false,
        isAlarming: false,
        updatedAt: .now
    )
}

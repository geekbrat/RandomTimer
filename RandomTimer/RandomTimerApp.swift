//
//  RandomTimerApp.swift
//  RandomTimer
//
//  Created by Kirstyn Plummer on 1/23/26.
//

import SwiftUI


@MainActor
extension TimerModel {
    static func live() -> TimerModel {
        TimerModel(alarm: .shared)
    }
}

@main
struct RandomTimerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await AlarmService.shared.requestNotificationPermission()
                }
        }
    }
}

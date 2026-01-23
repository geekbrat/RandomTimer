//
//  ContentView.swift
//  RandomTimerWatchOS Watch App
//
//  Created by Kirstyn Plummer on 1/23/26.
//

import SwiftUI

struct WatchContentView: View {
    @StateObject private var model = TimerModel(alarm: AlarmService.shared)
    
    var body: some View {
        VStack(spacing: 10) {
            Text(model.isAlarming ? "TIME!" : format(model.remainingSeconds))
                .font(.system(.title, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.6)
            
            
            if model.isAlarming {
                Button("Acknowledge") { model.acknowledgeAlarm() }
                    .buttonStyle(.borderedProminent)
            } else {
                Button(model.isRunning ? "Pause" : (model.endDate == nil ? "Start" : "Resume")) {
                    if model.isRunning {
                        model.pause()
                    } else if model.endDate == nil {
                        model.startNewRandomTimer()
                    } else {
                        model.resume()
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Stop") { model.stopTimer() }
                    .buttonStyle(.bordered)
                ProgressView(value: model.progress)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 6)
        .task {
            await AlarmService.shared.requestNotificationPermission()
        }
        .task {
            model.applySharedState(SharedTimerStore.shared.state)
        }
    }


    private func format(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

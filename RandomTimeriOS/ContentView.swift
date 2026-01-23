//
//  ContentView.swift
//  RandomTimeriOS
//
//  Created by Kirstyn Plummer on 1/23/26.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var model = TimerModel(alarm: AlarmService.shared)

    // Pull shared state updates (phone ↔ watch) via App Group store
    @StateObject private var store = SharedTimerStore.shared

    @State private var showingAbout = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
            Text(model.isAlarming ? "⏰ TIME!" : format(model.remainingSeconds))
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .padding(.top, 8)

            ProgressView(value: model.progress)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) {
                Stepper(
                    "Min: \(pretty(model.minSeconds))",
                    value: $model.minSeconds,
                    in: 5...max(5, model.maxSeconds),
                    step: 5
                )

                Stepper(
                    "Max: \(pretty(model.maxSeconds))",
                    value: $model.maxSeconds,
                    in: model.minSeconds...7200,
                    step: 5
                )
            }
            .padding(.horizontal)

            HStack(spacing: 12) {
                Button("Start Random") { model.startNewRandomTimer() }
                    .buttonStyle(.borderedProminent)

                if model.isRunning {
                    Button("Pause") { model.pause() }
                        .buttonStyle(.bordered)
                } else if model.endDate != nil && !model.isAlarming {
                    Button("Resume") { model.resume() }
                        .buttonStyle(.bordered)
                }

                Button("Stop") { model.stopTimer() }
                    .buttonStyle(.bordered)
            }
            .padding(.top, 4)

            if model.isAlarming {
                Button("Acknowledge") { model.acknowledgeAlarm() }
                    .font(.title3.weight(.semibold))
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 6)
            }

            Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("Random Timer")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button { showingSettings = true } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button { showingAbout = true } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                NavigationStack {
                    SettingsView()
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") { showingSettings = false }
                            }
                        }
                }
            }
            .sheet(isPresented: $showingAbout) {
                NavigationStack {
                    AboutView()
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") { showingAbout = false }
                            }
                        }
                }
            }
            .task {
            // Permissions for local notifications
            await AlarmService.shared.requestNotificationPermission()

            // Load & apply the latest shared state (e.g., if watch started timer)
            model.applySharedState(store.state)
        }
            .onReceive(store.$state) { newState in
            // Keep the phone UI/model in sync with updates coming from watch
            model.applySharedState(newState)
            }
        }
    }

    // MARK: - Formatting

    private func format(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }

    private func pretty(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60

        if h > 0 {
            if s == 0 {
                return "\(h)h \(m)m"
            } else {
                return "\(h)h \(m)m \(s)s"
            }
        } else if m > 0 {
            if s == 0 {
                return "\(m)m"
            } else {
                return "\(m)m \(s)s"
            }
        } else {
            return "\(s)s"
        }
    }
}

#Preview {
    ContentView()
}

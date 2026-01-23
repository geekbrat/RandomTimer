import SwiftUI

struct ContentView: View {
    @StateObject private var model = TimerModel(alarm: AlarmService.shared)

    @State private var showingAbout = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Text(model.isAlarming ? "⏰ TIME!" : format(model.remainingSeconds))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .monospacedDigit()

                ProgressView(value: model.progress)

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
                .frame(maxWidth: 420)

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

                if model.isAlarming {
                    Button("Acknowledge") { model.acknowledgeAlarm() }
                        .font(.title3.weight(.semibold))
                        .buttonStyle(.borderedProminent)
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
                .frame(minWidth: 420, minHeight: 520)
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
                .frame(minWidth: 460, minHeight: 600)
            }
            .task {
                await AlarmService.shared.requestNotificationPermission()
            }
        }
    }

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
            return s == 0 ? "\(h)h \(m)m" : "\(h)h \(m)m \(s)s"
        } else if m > 0 {
            return s == 0 ? "\(m)m" : "\(m)m \(s)s"
        } else {
            return "\(s)s"
        }
    }
}

#Preview {
    ContentView()
}

//
//  TimerModel.swift
//  RandomTimer
//
//  Created by Kirstyn Plummer on 1/23/26.
//


import Foundation
import Combine



@MainActor
final class TimerModel: ObservableObject {
    @Published var minSeconds: Int = 300
    @Published var maxSeconds: Int = 900

    @Published private(set) var endDate: Date?
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isAlarming: Bool = false
    
    @Published private(set) var now: Date = .now
    
    @Published private(set) var startDate: Date?
    @Published private(set) var totalSeconds: Int = 0


    private var alarmIsActive = false
    private var didRestore = false
    private var tickTask: Task<Void, Never>?
    private let alarm: AlarmService

    init(alarm: AlarmService) {
        self.alarm = alarm

        // State restoration on launch.
        restoreIfNeeded()
    }

    private func restoreIfNeeded() {
        guard !didRestore else { return }
        didRestore = true

        now = .now

        #if os(iOS) || os(watchOS)
        // Restore from shared App Group state (keeps phone/watch in sync).
        applySharedState(store.state)

        if let end = endDate {
            now = .now
            if now >= end {
                // Timer elapsed while app was not running.
                isRunning = false
                stopTicking()
                triggerAlarm()
            } else if isRunning {
                beginTicking()
            }
        }
        #elseif os(macOS)
        // Restore from local user defaults (mac app).
        if let s = LocalTimerStore.load() {
            applyLocalState(s)

            if let end = endDate {
                now = .now
                if now >= end {
                    isRunning = false
                    stopTicking()
                    triggerAlarm()
                } else if isRunning {
                    beginTicking()
                }
            }
        }
        #endif
    }
    
    var progress: Double {
        guard let startDate, let endDate else { return 0 }
        let total = endDate.timeIntervalSince(startDate)
        if total <= 0 { return 0 }
        let remaining = max(0, endDate.timeIntervalSince(now))
        return min(1, max(0, 1 - (remaining / total)))
    }

    var remainingSeconds: Int {
        guard let endDate else { return 0 }
        return max(0, Int(endDate.timeIntervalSince(now).rounded(.down)))
    }

   
#if os(iOS) || os(watchOS)
    
    private let store = SharedTimerStore.shared
    private var connectivity: ConnectivityService {
        ConnectivityService.shared
    }
    
    func applySharedState(_ s: SharedTimerState) {
        minSeconds = s.minSeconds
        maxSeconds = s.maxSeconds
        startDate = s.startDate
        endDate = s.endDate
        totalSeconds = s.totalSeconds
        isRunning = s.isRunning
        isAlarming = s.isAlarming

        now = .now

        // Ensure ticking is correct
        if isRunning {
            beginTicking()
        } else {
            stopTicking()
        }

        // If state says alarming, ensure loop is running (idempotent)
        if isAlarming && !alarmIsActive {
            alarmIsActive = true
            alarm.startAlarmLoop()
        }
        if !isAlarming {
            alarmIsActive = false
            alarm.stopAlarmLoop()
        }
    }
    
    private func publishSharedState() {
        let s = SharedTimerState(
            minSeconds: minSeconds,
            maxSeconds: maxSeconds,
            startDate: startDate,
            endDate: endDate,
            totalSeconds: totalSeconds,
            isRunning: isRunning,
            isAlarming: isAlarming,
            updatedAt: .now
        )
        store.save(s)
        connectivity.push(state: s)
    }
    #endif

    #if os(macOS)
    private func applyLocalState(_ s: SharedTimerState) {
        minSeconds = s.minSeconds
        maxSeconds = s.maxSeconds
        startDate = s.startDate
        endDate = s.endDate
        totalSeconds = s.totalSeconds
        isRunning = s.isRunning
        isAlarming = s.isAlarming
        now = .now

        if isRunning {
            beginTicking()
        } else {
            stopTicking()
        }

        if isAlarming && !alarmIsActive {
            alarmIsActive = true
            alarm.startAlarmLoop()
        }
        if !isAlarming {
            alarmIsActive = false
            alarm.stopAlarmLoop()
        }
    }

    private func publishLocalState() {
        let s = SharedTimerState(
            minSeconds: minSeconds,
            maxSeconds: maxSeconds,
            startDate: startDate,
            endDate: endDate,
            totalSeconds: totalSeconds,
            isRunning: isRunning,
            isAlarming: isAlarming,
            updatedAt: .now
        )
        LocalTimerStore.save(s)
    }
    #endif
    
    func startNewRandomTimer() {
        Task { await alarm.cancelTimerNotification() }
        stopAlarm()

        let duration = Int.random(in: minSeconds...maxSeconds)
        let start = Date()
        let fire = start.addingTimeInterval(TimeInterval(duration))
        startDate = start
        totalSeconds = duration
        endDate = fire
        isRunning = true

        Task { await alarm.scheduleTimerNotification(fireDate: fire) }
        beginTicking()
        #if os(iOS) || os(watchOS)
        publishSharedState()
        #elseif os(macOS)
        publishLocalState()
        #endif
    }

    func stopTimer() {
        isRunning = false
        endDate = nil
        startDate = nil
        totalSeconds = 0
        stopTicking()
        stopAlarm()
        Task { await alarm.cancelTimerNotification() }
        #if os(iOS) || os(watchOS)
        publishSharedState()
        #elseif os(macOS)
        publishLocalState()
        #endif
    }

    func pause() {
        guard isRunning, let endDate else { return }
        let remaining = max(0, endDate.timeIntervalSinceNow)
        self.endDate = Date().addingTimeInterval(remaining)
        isRunning = false
        stopTicking()
        Task { await alarm.cancelTimerNotification() }
        #if os(iOS) || os(watchOS)
        publishSharedState()
        #elseif os(macOS)
        publishLocalState()
        #endif
        
    }

    func resume() {
        guard !isRunning, endDate != nil, !isAlarming else { return }
        let remaining = TimeInterval(remainingSeconds)
        let fire = Date().addingTimeInterval(remaining)
        endDate = fire
        isRunning = true
        Task { await alarm.scheduleTimerNotification(fireDate: fire) }
        beginTicking()
        #if os(iOS) || os(watchOS)
        publishSharedState()
        #elseif os(macOS)
        publishLocalState()
        #endif
    }

    func acknowledgeAlarm() {
        stopTimer()
    }

    private func beginTicking() {
        stopTicking()
        tickTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 250_000_000)
                tick()
            }
        }
    }

    private func stopTicking() {
        tickTask?.cancel()
        tickTask = nil
    }

    private func tick() {
        now = .now
        guard let endDate else { return }
        if now >= endDate {
            isRunning = false
            stopTicking()
            triggerAlarm()
        }
    }

    private func triggerAlarm() {
        guard !alarmIsActive else { return }
        alarmIsActive = true
        isAlarming = true
        alarm.startAlarmLoop()
        #if os(iOS) || os(watchOS)
        publishSharedState()
        #elseif os(macOS)
        publishLocalState()
        #endif
    }

    private func stopAlarm() {
        alarmIsActive = false
        isAlarming = false
        alarm.stopAlarmLoop()
        #if os(iOS) || os(watchOS)
        publishSharedState()
        #elseif os(macOS)
        publishLocalState()
        #endif
    }
}

#if os(macOS)
private enum LocalTimerStore {
    private static let key = "local.timer.state.v1"

    static func load() -> SharedTimerState? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(SharedTimerState.self, from: data)
    }

    static func save(_ state: SharedTimerState) {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
#endif

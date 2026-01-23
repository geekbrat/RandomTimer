//
//  AlarmService.swift
//  RandomTimer
//
//  Created by Kirstyn Plummer on 1/23/26.
//


import Foundation
import Combine
import UserNotifications
import SwiftUI

#if os(iOS)
import UIKit
#endif

#if canImport(AVFoundation)
import AVFoundation
#endif

#if os(watchOS)
import WatchKit
#endif
@MainActor
final class AlarmService: ObservableObject {
    static let shared = AlarmService()

    // Notification identifier so we can cancel/replace.
    private let notifId = "RandomTimer.Fire"

    // Audio
    #if canImport(AVFoundation) && !os(watchOS)
    private var audioPlayer: AVAudioPlayer?
    #endif

    // Selected alarm sound (shared via Settings)
    @AppStorage(SettingsKeys.alarmSound) private var alarmSoundRaw: String = AlarmSound.classic.rawValue

    private var selectedSound: AlarmSound {
        AlarmSound(rawValue: alarmSoundRaw) ?? .classic
    }

    // Haptics task (watch + optional iOS)
    private var hapticTask: Task<Void, Never>?

    private init() {}

    // MARK: - Permissions

    func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        do {
            _ = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            // If denied or error, app still works; it just won’t notify.
        }
    }

    // MARK: - Notifications

    func scheduleTimerNotification(fireDate: Date) async {
        let center = UNUserNotificationCenter.current()
        await cancelTimerNotification()

        let content = UNMutableNotificationContent()
        content.title = "Random Timer"
        content.body = "Time’s up."
        content.sound = .default

        // Fire exactly at endDate (to the second).
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let request = UNNotificationRequest(identifier: notifId, content: content, trigger: trigger)

        do {
            try await center.add(request)
        } catch {
            // Ignore; app can still alarm in-foreground.
        }
    }

    func cancelTimerNotification() async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notifId])
        center.removeDeliveredNotifications(withIdentifiers: [notifId])
    }

    // MARK: - Alarm start/stop

    func startAlarmLoop() {
        startAudioLoop()
        startHapticsLoop()
    }

    // MARK: - Preview (Settings)

    /// Plays the selected alarm sound without starting the haptics loop.
    func startSoundPreview() {
        startAudioLoop()
    }

    func stopSoundPreview() {
        stopAudioLoop()
    }

    func stopAlarmLoop() {
        stopAudioLoop()
        stopHapticsLoop()
    }

    // MARK: - Audio

    private func startAudioLoop() {
        #if canImport(AVFoundation) && !os(watchOS)
        guard let url = Bundle.main.url(forResource: selectedSound.filename, withExtension: selectedSound.fileExtension)
                ?? Bundle.main.url(forResource: "alarm", withExtension: "wav")
                ?? Bundle.main.url(forResource: "alarm", withExtension: "mp3") else {
            return
        }

        do {
            #if os(iOS)
            let session = AVAudioSession.sharedInstance()
            // Playback category allows sound even in silent mode; user volume still applies.
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)
            #endif

            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1 // infinite loop
            player.prepareToPlay()
            player.play()
            audioPlayer = player
        } catch {
            // If audio fails, notifications/haptics still carry the alert.
        }
        #endif
    }

    private func stopAudioLoop() {
        #if canImport(AVFoundation) && !os(watchOS)
        audioPlayer?.stop()
        audioPlayer = nil

        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false)
        #endif
        #endif
    }

    // MARK: - Haptics

    private func startHapticsLoop() {
        stopHapticsLoop()
        hapticTask = Task {
            while !Task.isCancelled {
                #if os(watchOS)
                WKInterfaceDevice.current().play(.notification)
                #elseif os(iOS)
                // Optional: subtle iOS haptic loop. Comment out if you want audio-only on iPhone.
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
                #endif

                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1s
            }
        }
    }

    private func stopHapticsLoop() {
        hapticTask?.cancel()
        hapticTask = nil
    }
}

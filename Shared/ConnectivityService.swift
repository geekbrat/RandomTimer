//
//  ConnectivityService.swift
//  RandomTimer
//
//  Created by Kirstyn Plummer on 1/23/26.
//


import Foundation

#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

@MainActor
final class ConnectivityService: NSObject {
    static let shared = ConnectivityService()

    private override init() {
        super.init()
        #if canImport(WatchConnectivity)
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        #endif
    }

    func push(state: SharedTimerState) {
        #if canImport(WatchConnectivity)
        guard WCSession.default.activationState == .activated else { return }
        if let data = try? JSONEncoder().encode(state) {
            try? WCSession.default.updateApplicationContext(["state": data])
        }
        #endif
    }
}

#if canImport(WatchConnectivity)
extension ConnectivityService: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    // These two are iOS-only; watchOS does not use them.
    #if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String : Any]
    ) {
        guard let data = applicationContext["state"] as? Data,
              let decoded = try? JSONDecoder().decode(SharedTimerState.self, from: data)
        else { return }

        Task { @MainActor [decoded] in
            SharedTimerStore.shared.save(decoded)
        }
    }
}
#endif

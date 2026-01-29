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
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        #endif
    }

    func push(state: SharedTimerState) {
        #if canImport(WatchConnectivity)
        let session = WCSession.default
        guard session.activationState == .activated else { return }

        #if os(iOS)
        guard session.isPaired, session.isWatchAppInstalled else { return }
        #endif

        guard let data = try? JSONEncoder().encode(state) else { return }
        try? session.updateApplicationContext(["state": data])
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

    #if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String : Any]
    ) {
        guard let data = applicationContext["state"] as? Data else { return }

        Task { @MainActor [data] in
            guard let decoded = try? JSONDecoder().decode(SharedTimerState.self, from: data) else { return }
            SharedTimerStore.shared.save(decoded)
        }
    }
}
#endif

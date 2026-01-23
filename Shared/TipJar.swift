#if canImport(StoreKit) && !os(watchOS)
import Foundation
import StoreKit

@MainActor
final class TipJar: ObservableObject {
    static let shared = TipJar()

    // Update these to match App Store Connect product IDs.
    let productIDs: [String] = [
        "com.kirstynplummer.randomtimer.tip.small",
        "com.kirstynplummer.randomtimer.tip.medium",
        "com.kirstynplummer.randomtimer.tip.large"
    ]

    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var lastPurchaseMessage: String?

    private var updatesTask: Task<Void, Never>?

    private init() {
        listenForTransactionUpdates()
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let fetched = try await Product.products(for: productIDs)
            products = productIDs.compactMap { id in fetched.first(where: { $0.id == id }) }
        } catch {
            products = []
            lastPurchaseMessage = "Couldn’t load support options. Please try again."
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                lastPurchaseMessage = "Thank you for supporting development! ❤️"
            case .userCancelled:
                lastPurchaseMessage = nil
            case .pending:
                lastPurchaseMessage = "Purchase pending approval."
            @unknown default:
                lastPurchaseMessage = "Purchase not completed."
            }
        } catch {
            lastPurchaseMessage = "Purchase failed. Please try again."
        }
    }

    func syncPurchases() async {
        do {
            try await AppStore.sync()
            lastPurchaseMessage = "Synced with the App Store."
        } catch {
            lastPurchaseMessage = "Couldn’t sync purchases."
        }
    }

    private func listenForTransactionUpdates() {
        updatesTask?.cancel()
        updatesTask = Task {
            for await update in Transaction.updates {
                do {
                    let transaction = try checkVerified(update)
                    await transaction.finish()
                } catch {
                    // Ignore unverified transactions
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw StoreKitError.notEntitled
        }
    }
}
#endif

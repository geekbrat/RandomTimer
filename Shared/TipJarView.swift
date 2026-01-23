#if canImport(StoreKit) && !os(watchOS)
import SwiftUI
import StoreKit

struct TipJarView: View {
    @StateObject private var tipJar = TipJar.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support is optional and never required to use the app.")
                .foregroundStyle(.secondary)

            if tipJar.isLoading {
                ProgressView()
            } else if tipJar.products.isEmpty {
                Text("Tip options are unavailable right now.")
                    .foregroundStyle(.secondary)

                Button {
                    Task { await tipJar.loadProducts() }
                } label: {
                    Label("Try Again", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
            } else {
                ForEach(tipJar.products, id: \.id) { product in
                    Button {
                        Task { await tipJar.purchase(product) }
                    } label: {
                        HStack {
                            Text(product.displayName)
                            Spacer()
                            Text(product.displayPrice)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }

                Button {
                    Task { await tipJar.syncPurchases() }
                } label: {
                    Label("Sync Purchases", systemImage: "arrow.triangle.2.circlepath")
                }
                .buttonStyle(.bordered)
            }

            if let msg = tipJar.lastPurchaseMessage {
                Text(msg)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .task { await tipJar.loadProducts() }
    }
}

#endif
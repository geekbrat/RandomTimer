#if os(iOS) || os(macOS)
import SwiftUI

struct AboutView: View {
    // Only enable for non-store macOS builds:
    // macOS target -> Other Swift Flags -> -DALLOW_EXTERNAL_GIFT_LINK
    private var allowExternalGiftLink: Bool {
        #if os(macOS)
        #if ALLOW_EXTERNAL_GIFT_LINK
        return true
        #else
        return false
        #endif
        #else
        return false
        #endif
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                GroupBox {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Random Timer is a deliberately simple tool designed to interrupt predictability.")
                        Text("Instead of a fixed interval, it alerts you at a random moment within a range you choose. That unpredictability can help with focus breaks, habit disruption, accessibility cues, and any workflow that benefits from time prompts you can’t anticipate.")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } label: {
                    Label("About Random Timer", systemImage: "info.circle")
                }

                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("If you enjoy Random Timer and want to help support continued development, you can support the developer.")

                        #if canImport(StoreKit) && !os(watchOS)
                        TipJarView()
                        #else
                        Text("Support options may appear here in the future.")
                            .foregroundStyle(.secondary)
                        #endif

                        if allowExternalGiftLink {
                            Divider().padding(.vertical, 6)
                            Text("Prefer an external option?")
                                .font(.subheadline.weight(.semibold))

                            Link(destination: URL(string: "https://paypal.com/replummer")!) {
                                Label("Send a Gift via PayPal", systemImage: "gift")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } label: {
                    Label("Support the Developer", systemImage: "heart")
                }

                GroupBox {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Random Timer runs locally and avoids unnecessary data collection. No accounts, no ads, and no tracking.")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } label: {
                    Label("Privacy", systemImage: "hand.raised")
                }

                footer
            }
            .padding()
        }
        .navigationTitle("About")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "timer")
                .font(.system(size: 34, weight: .semibold))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("Random Timer")
                    .font(.title2.weight(.bold))
                Text(platformSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var platformSubtitle: String {
        #if os(iOS)
        return "iOS App Store Edition"
        #elseif os(macOS)
        return allowExternalGiftLink ? "macOS (Direct Download Edition)" : "macOS App Store Edition"
        #else
        return "Edition"
        #endif
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 6) {
            Divider().padding(.top, 4)
            Text("© 2026 Kirstyn Piper Plummer")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("All rights reserved.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#endif

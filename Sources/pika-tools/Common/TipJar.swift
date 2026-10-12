#if APPSTORE
import StoreKit
import SwiftUI

@Observable @MainActor
final class TipJar {
    static let shared = TipJar()

    enum State { case loading, ready, unavailable }

    static let ids = ["small", "medium", "large"].map { "com.pesotchi.pika-tools.appstore.tip.\($0)" }

    private(set) var state = State.loading
    private(set) var products: [Product] = []
    private(set) var thanked = false
    private(set) var failed = false
    private(set) var buying = false
    private var started = false

    func start() {
        guard !started else { return }
        started = true
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result { await transaction.finish() }
            }
        }
        Task { await load() }
    }

    func load() async {
        state = .loading
        let found = (try? await Product.products(for: Self.ids)) ?? []
        products = found.sorted { (Self.ids.firstIndex(of: $0.id) ?? 0) < (Self.ids.firstIndex(of: $1.id) ?? 0) }
        state = products.isEmpty ? .unavailable : .ready
    }

    func buy(_ product: Product) async {
        buying = true
        failed = false
        defer { buying = false }
        do {
            switch try await product.purchase() {
            case .success(.verified(let transaction)):
                await transaction.finish()
                thanked = true
            case .success:
                failed = true
            default:
                break
            }
        } catch {
            failed = true
        }
    }

    static func name(_ id: String) -> Text {
        switch id {
        case ids[0]: Text("Small tip")
        case ids[1]: Text("Medium tip")
        default: Text("Large tip")
        }
    }
}

struct TipJarSection: View {
    @Bindable private var jar = TipJar.shared

    // No tip products in App Store Connect yet (or the store is unreachable):
    // show nothing rather than a section that can't do anything.
    var body: some View {
        if jar.state != .unavailable || jar.thanked {
            Section {
                LabeledContent {
                    EmptyView()
                } label: {
                    RowLabel(Text("Say thanks"), Text("Optional tip. It unlocks nothing."))
                }
                .settingAnchor(String(localized: "Say thanks"))
                if jar.thanked {
                    Label("Thank you! It means a lot.", systemImage: "heart.fill")
                        .foregroundStyle(.pink)
                } else {
                    switch jar.state {
                    case .loading:
                        ProgressView().controlSize(.small).frame(maxWidth: .infinity)
                    case .unavailable:
                        EmptyView()
                    case .ready:
                        HStack(spacing: 8) {
                            ForEach(jar.products, id: \.id) { product in
                                Button {
                                    Task { await jar.buy(product) }
                                } label: {
                                    VStack(spacing: 2) {
                                        TipJar.name(product.id)
                                        Text(verbatim: product.displayPrice).foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.large)
                            }
                        }
                        .disabled(jar.buying)
                        if jar.failed {
                            Text("The tip did not go through.").font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
#endif

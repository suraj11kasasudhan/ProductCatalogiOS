import Foundation

@MainActor
final class EnquiryViewModel {
    enum State {
        case editing
        case sending
        case sent(String)
        case failed(String)
    }

    let product: Product
    private let api: CatalogueServing
    private(set) var state: State = .editing { didSet { onChange?() } }
    var onChange: (() -> Void)?

    init(product: Product, api: CatalogueServing) {
        self.product = product
        self.api = api
    }

    var isSending: Bool { if case .sending = state { return true }; return false }
    var isSent: Bool { if case .sent = state { return true }; return false }
    var errorMessage: String? { if case .failed(let message) = state { return message }; return nil }

    func submit(_ draft: EnquiryDraft) async {
        guard !Task.isCancelled else { return }
        // Keep duplicate taps from producing duplicate emails within this screen.
        switch state {
        case .sending, .sent: return
        case .editing, .failed: break
        }
        do {
            let request = try draft.request(productID: product.id)
            state = .sending
            let confirmation = try await api.enquire(request)
            state = .sent(confirmation.message)
        } catch {
            // A cancelled POST may already have reached the server; do not retry automatically.
            state = .failed(Task.isCancelled || error is CancellationError
                ? "Sending was interrupted. Your enquiry may have been sent. Check before submitting again."
                : error.localizedDescription)
        }
    }
}

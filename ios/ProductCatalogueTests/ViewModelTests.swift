import XCTest
@testable import ProductCatalogue

final class ViewModelTests: XCTestCase {
    @MainActor
    func testHomeLoadsFeaturedProductsAndCategories() async throws {
        let api = StubCatalogueAPI()
        api.products = [try sampleProduct()]
        let model = CatalogueViewModel(mode: .home, api: api)
        await model.load()
        guard case .loaded(let content) = model.state else { return XCTFail("Expected loaded home") }
        XCTAssertEqual(content.categories, api.categoryNames)
        XCTAssertEqual(content.sections.first?.products, api.products)
    }

    @MainActor
    func testSearchTrimsTermAndEmptySearchMakesNoRequest() async throws {
        let api = StubCatalogueAPI()
        api.products = [try sampleProduct()]
        let model = CatalogueViewModel(mode: .search, api: api)
        await model.load(query: "   ")
        XCTAssertTrue(api.searchTerms.isEmpty)
        XCTAssertEqual(model.query, "")
        await model.load(query: " cotton ")
        XCTAssertEqual(api.searchTerms, ["cotton"])
        XCTAssertEqual(model.query, "cotton")
        guard case .loaded(let content) = model.state else { return XCTFail("Expected results") }
        XCTAssertEqual(content.sections.first?.products.count, 1)
    }

    @MainActor
    func testSourceFailureBecomesRetryableScreenState() async {
        let api = StubCatalogueAPI()
        api.failure = APIError.rejected(status: 502, message: "Catalogue unavailable.")
        let model = CatalogueViewModel(mode: .home, api: api)
        await model.load()
        guard case .failed(let message) = model.state else { return XCTFail("Expected failure") }
        XCTAssertEqual(message, "Catalogue unavailable.")
        api.failure = nil
        await model.load()
        guard case .loaded = model.state else { return XCTFail("Retry should succeed") }
    }

    @MainActor
    func testProductDetailsFetchByID() async throws {
        let api = StubCatalogueAPI()
        api.products = [try sampleProduct()]
        let model = ProductDetailViewModel(productID: 1, api: api)
        await model.load()
        guard case .loaded(let product) = model.state else { return XCTFail("Expected details") }
        XCTAssertEqual(product.id, 1)
    }

    @MainActor
    func testInvalidEnquiryDoesNotCallBackend() async throws {
        let api = StubCatalogueAPI()
        let model = EnquiryViewModel(product: try sampleProduct(), api: api)
        await model.submit(EnquiryDraft(name: "Customer", email: "bad", message: "Hello"))
        XCTAssertTrue(api.submissions.isEmpty)
        guard case .failed = model.state else { return XCTFail("Expected validation message") }
    }

    @MainActor
    func testEnquiryConfirmsOnlyAfterBackendSuccessAndDoesNotResend() async throws {
        let api = StubCatalogueAPI()
        let model = EnquiryViewModel(product: try sampleProduct(), api: api)
        let draft = EnquiryDraft(name: " Customer ", email: "customer@example.test", phone: " ", message: " Hello ")
        await model.submit(draft)
        guard case .sent(let message) = model.state else { return XCTFail("Expected confirmation") }
        XCTAssertEqual(message, api.confirmation.message)
        XCTAssertEqual(api.submissions.first?.name, "Customer")
        XCTAssertNil(api.submissions.first?.phone)
        await model.submit(draft)
        XCTAssertEqual(api.submissions.count, 1)
    }

    @MainActor
    func testEmailFailureKeepsEnquiryRetryable() async throws {
        let api = StubCatalogueAPI()
        api.failure = APIError.rejected(status: 502, message: "Email could not be sent.")
        let model = EnquiryViewModel(product: try sampleProduct(), api: api)
        let draft = EnquiryDraft(name: "Customer", email: "customer@example.test", message: "Hello")
        await model.submit(draft)
        guard case .failed = model.state else { return XCTFail("Do not thank customer after failure") }
        api.failure = nil
        await model.submit(draft)
        guard case .sent = model.state else { return XCTFail("Retry should succeed") }
    }

    @MainActor
    func testOlderSearchCannotOverwriteNewerSearch() async {
        let api = StubCatalogueAPI()
        let started = expectation(description: "First search started")
        var pending: CheckedContinuation<[Product], Error>?
        api.searchHandler = { query in
            if query == "old" {
                return try await withCheckedThrowingContinuation { continuation in
                    pending = continuation
                    started.fulfill()
                }
            }
            return []
        }
        let model = CatalogueViewModel(mode: .search, api: api)
        let first = Task { await model.load(query: "old") }
        await fulfillment(of: [started], timeout: 1)
        await model.load(query: "new")
        pending?.resume(throwing: APIError.unavailable)
        await first.value
        guard case .loaded(let content) = model.state else {
            return XCTFail("An older failure must not replace the current results")
        }
        XCTAssertTrue(content.sections.first?.products.isEmpty == true)
    }

    @MainActor
    func testFormPresentationTracksFailureAndSuccessfulRetry() async throws {
        let api = StubCatalogueAPI()
        api.failure = APIError.unavailable
        let model = EnquiryViewModel(product: try sampleProduct(), api: api)
        let draft = EnquiryDraft(name: "Customer", email: "c@example.test", message: "Hello")
        await model.submit(draft)
        XCTAssertFalse(model.isSending)
        XCTAssertFalse(model.isSent)
        XCTAssertNotNil(model.errorMessage)
        api.failure = nil
        await model.submit(draft)
        XCTAssertFalse(model.isSending)
        XCTAssertTrue(model.isSent)
        XCTAssertNil(model.errorMessage)
    }

    @MainActor
    func testAlreadyCancelledSearchDoesNotInvalidateActiveSearch() async throws {
        let api = StubCatalogueAPI()
        let product = try sampleProduct()
        let started = expectation(description: "Search pending")
        var pending: CheckedContinuation<[Product], Error>?
        api.searchHandler = { _ in
            try await withCheckedThrowingContinuation { continuation in
                pending = continuation
                started.fulfill()
            }
        }
        let model = CatalogueViewModel(mode: .search, api: api)
        let active = Task { await model.load(query: "cotton") }
        await fulfillment(of: [started], timeout: 1)
        let cancelled = Task { await model.load(query: "discarded") }
        cancelled.cancel()
        await cancelled.value
        pending?.resume(returning: [product])
        await active.value
        guard case .loaded(let content) = model.state else { return XCTFail("Active result was discarded") }
        XCTAssertEqual(content.sections.first?.products, [product])
        XCTAssertEqual(api.searchTerms, ["cotton"])
        XCTAssertEqual(model.query, "cotton")
    }

    @MainActor
    func testAlreadyCancelledDetailLoadDoesNotInvalidateActiveLoad() async throws {
        let api = StubCatalogueAPI()
        let product = try sampleProduct()
        let started = expectation(description: "Details pending")
        var pending: CheckedContinuation<Product, Error>?
        api.productHandler = { _ in
            try await withCheckedThrowingContinuation { continuation in
                pending = continuation
                started.fulfill()
            }
        }
        let model = ProductDetailViewModel(productID: 1, api: api)
        let active = Task { await model.load() }
        await fulfillment(of: [started], timeout: 1)
        let cancelled = Task { await model.load() }
        cancelled.cancel()
        await cancelled.value
        pending?.resume(returning: product)
        await active.value
        guard case .loaded(let loaded) = model.state else { return XCTFail("Active result was discarded") }
        XCTAssertEqual(loaded, product)
    }

    @MainActor
    func testInterruptedEnquiryUnlocksFormAndWarnsAboutUncertainDelivery() async throws {
        let api = StubCatalogueAPI()
        api.enquiryHandler = { _ in throw CancellationError() }
        let model = EnquiryViewModel(product: try sampleProduct(), api: api)
        await model.submit(EnquiryDraft(name: "Customer", email: "c@example.test", message: "Hello"))
        XCTAssertFalse(model.isSending)
        XCTAssertFalse(model.isSent)
        XCTAssertTrue(model.errorMessage?.contains("may have been sent") == true)
        XCTAssertEqual(api.submissions.count, 1)
    }

    @MainActor
    func testConfirmedEnquiryIsNotLostWhenServiceReturnsAfterCancellation() async throws {
        let api = StubCatalogueAPI()
        let started = expectation(description: "Enquiry pending")
        var pending: CheckedContinuation<Confirmation, Error>?
        api.enquiryHandler = { _ in
            try await withCheckedThrowingContinuation { continuation in
                pending = continuation
                started.fulfill()
            }
        }
        let model = EnquiryViewModel(product: try sampleProduct(), api: api)
        let submission = Task {
            await model.submit(EnquiryDraft(name: "Customer", email: "c@example.test", message: "Hello"))
        }
        await fulfillment(of: [started], timeout: 1)
        submission.cancel()
        pending?.resume(returning: api.confirmation)
        await submission.value
        XCTAssertTrue(model.isSent)
        XCTAssertFalse(model.isSending)
        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(api.submissions.count, 1)
    }

    func testDraftRejectsInvalidNamePhoneAndMessage() {
        XCTAssertThrowsError(try EnquiryDraft(name: "Two\nLines", email: "c@example.test", message: "Hello").request(productID: 1))
        XCTAssertThrowsError(try EnquiryDraft(name: "Customer", email: "c@example.test", phone: "letters", message: "Hello").request(productID: 1))
        XCTAssertThrowsError(try EnquiryDraft(name: "Customer", email: "c@example.test", message: " ").request(productID: 1))
    }
}

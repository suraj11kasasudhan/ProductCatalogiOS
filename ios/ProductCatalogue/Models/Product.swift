import Foundation

struct Product: Decodable, Equatable, Sendable {
    struct Rating: Decodable, Equatable, Sendable {
        let value: Double
        let count: Int
    }

    let id: Int
    let title: String
    let description: String
    let price: Double
    let imageUrl: URL
    let category: String
    let rating: Rating

    var displayCategory: String {
        category.replacingOccurrences(of: "-", with: " ").uppercased()
    }

    // The source does not declare a currency, so do not invent one.
    var displayPrice: String {
        price.formatted(.number.precision(.fractionLength(2)))
    }
}

struct ProductSection: Equatable {
    let title: String
    let products: [Product]
}

struct CatalogueContent: Equatable {
    static let empty = CatalogueContent(categories: [], sections: [])

    let categories: [String]
    let sections: [ProductSection]
}

struct EnquiryRequest: Encodable, Equatable, Sendable {
    let productId: Int
    let name: String
    let email: String
    let phone: String?
    let message: String
}

struct Confirmation: Decodable, Sendable {
    let message: String
}

// Backend response envelopes shared by the catalogue service.
struct ProductsResponse: Decodable { let products: [Product] }
struct CategoriesResponse: Decodable { let categories: [String] }
struct ProductResponse: Decodable { let product: Product }
struct CategoryResponse: Decodable { let featured: [Product]; let products: [Product] }

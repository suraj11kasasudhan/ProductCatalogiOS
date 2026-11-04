import UIKit
import XCTest
@testable import ProductCatalogue

final class ControllerTests: XCTestCase {
    @MainActor
    func testFactoryRoutesCategoryAndDetailWithInjectedService() {
        let factory = CatalogueScreenFactory(service: StubCatalogueAPI())
        let home = factory.catalogue(mode: .home)
        let navigation = UINavigationController(rootViewController: home)
        home.onSelectCategory?("beauty")
        XCTAssertEqual(navigation.viewControllers.count, 2)
        guard let category = navigation.topViewController as? CatalogueViewController else {
            return XCTFail("Expected category screen")
        }
        category.onSelectProduct?(1)
        XCTAssertEqual(navigation.viewControllers.count, 3)
        XCTAssertTrue(navigation.topViewController is ProductDetailViewController)
    }
}

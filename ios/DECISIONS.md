# Architecture and implementation decisions

## Project context and AI authorship

According to the project author, the initial design and implementation of both the iOS frontend and Node.js backend took approximately four hours in total. All code was written using AI, with the author providing requirements, design direction, execution feedback, and approval. This includes application code, tests, project configuration, refactoring, and documentation. The four-hour estimate is author-reported, not a measured agent runtime, and does not establish that later deployment troubleshooting, revisions, or verification were completed within that window.

The iOS app is maintained on main in ProductCatalogiOS. The backend remains in suraj11kasasudhan/ProductCatalogBackend on feat/catalogue-backend. Separating repositories allows the app and hosted service to evolve and be reviewed independently.

## Why UIKit and MVVM

UIKit and MVVM were the user's requested approach. Programmatic screen views own layout/rendering; small controllers bind view-model state, coordinate tasks, and emit navigation events. View models own main-actor loading and submission state. Keeping these responsibilities separate makes UI styling independent of transport behavior and lets state logic run against deterministic stubs.

System UIKit and URLSession avoid third-party runtime dependencies. The checked-in Xcode project opens directly in Xcode 16+, targets iOS 16+, and uses Swift 5 language mode. A dependency-free Python generator is the source of truth for project references, scheme and Info.plists.

## Dependency injection and testability

- CatalogueViewModel, ProductDetailViewModel and EnquiryViewModel accept CatalogueServing through their initializers.
- CatalogueAPI accepts NetworkManaging; tests can replace transport without URLSession.
- NetworkManager accepts URLSession; protocol-stub tests validate real request encoding, status handling and decoding offline.
- Controllers accept view models. CatalogueScreenFactory injects the shared service and creates navigation destinations.
- Product and response models have no UIKit dependency. Reusable screen views and CatalogueStyle centralize layout components and palette choices without introducing a framework.

Keep the existing composition root small; there is no need to change AppDelegate or SceneDelegate for model/service/controller-only refactors. Shared image caching currently remains an internal view helper using URLSession.shared; it is not claimed to have an independently injected or tested image-transport boundary.

## Why DummyJSON replaced Fake Store

Fake Store was the original required provider. Requests from the Render-hosted backend returned HTTP 403 with server identified as Cloudflare, cf-mitigated: challenge, and an HTML response instead of JSON. The API worked in the author's browser, but a server HTTP client cannot complete that browser challenge. Changing Render regions did not resolve it. These observations confirm a Cloudflare challenge; they do not prove the exact firewall rule or a blanket ban on all Render addresses.

The user then explicitly approved switching to another free product API. The backend now uses https://dummyjson.com and maps its response into the existing product contract. The iOS app still requests only our backend for product metadata, and only downloads images from backend-provided URLs. This is a deliberate departure from the original Fake Store requirement and should be disclosed in any assignment review.

DummyJSON requests use /products?limit=0 so local category/search operations cover the complete catalogue. Thumbnails map to imageUrl, numeric rating maps to rating.value, and supplied review entries determine rating.count. Product IDs and categories changed with the source. No cached fake dataset is substituted as a production fallback.

## UI and product behavior

The author selected a blush pink theme after reviewing simpler layouts. Product grids adapt to screen width and accessibility text sizes; category chips scroll horizontally. Details use a large image panel and a fixed enquiry action. Baby pink surfaces, rose controls, plum text, and a deep rose dark palette share CatalogueStyle. Selected text/button color pairs were checked for contrast; this is not a full accessibility audit.

The backend controls the five featured products and category groups. Search runs on keyboard submission. The client displays numeric prices without inventing a currency missing from the contract. There are no account, payment, or checkout features.

Enquiry success requires backend confirmation. Validation and duplicate-tap prevention are local conveniences; the backend remains authoritative. Interrupted submissions warn that delivery may already have occurred and are never retried automatically. Durable storage, idempotency and final mailbox delivery remain backend concerns.

## Hosting and validation limits

Debug and Release default to https://productcatalogbackend-1.onrender.com/api. Debug supports a scheme override; Release requires HTTPS. API timeouts allow the free hosted service time to wake, but free-tier availability is not a production SLA. Production enquiry email still needs separate provider configuration.

The test target contains 28 XCTest methods, including injected service/transport tests and factory navigation coverage. Syntax, project references, scheme/plists, repeatable generation, and whitespace can be checked on Linux. Only Xcode/macOS CI can establish an iOS build and XCTest result; do not infer success from source inspection or the test count. Check the workflow result for the exact commit. Simulator screenshots supplied by the author are visual evidence, not proof of every manual integration or accessibility check.

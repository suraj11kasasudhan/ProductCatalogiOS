# ProductCatalogiOS

A UIKit + MVVM catalogue app with a blush pink theme, adaptive product cards, horizontal category browsing, search, product details, and product enquiries.

This repository contains the standalone iOS client. The Node.js backend is maintained separately on [`feat/catalogue-backend`](https://github.com/suraj11kasasudhan/ProductCatalogBackend/tree/feat/catalogue-backend). The hosted backend uses DummyJSON and exposes the product contract consumed by the app.


<img width="430" height="963" alt="Screenshot 2026-11-03 at 9 15 47 PM" src="https://github.com/user-attachments/assets/1efb12d3-1812-443a-9032-5f3850f42863" />
<img width="433" height="965" alt="Screenshot 2026-11-03 at 9 15 58 PM" src="https://github.com/user-attachments/assets/c4a35996-0dfc-410f-ac24-3686f99beccc" />
<img width="432" height="965" alt="Screenshot 2026-11-03 at 9 16 06 PM" src="https://github.com/user-attachments/assets/7abd925f-5772-4c34-9e59-92954024f607" />
<img width="438" height="962" alt="Screenshot 2026-11-03 at 9 16 15 PM" src="https://github.com/user-attachments/assets/958cd7a0-801f-4659-bb92-315d95c205ff" />
<img width="434" height="965" alt="Screenshot 2026-11-03 at 9 16 25 PM" src="https://github.com/user-attachments/assets/752711bb-d39a-43f1-bfd7-ec63292ed715" />


## Run the app

Requires **Xcode 16+**, **macOS**, and an iOS 16+ simulator or device. No third-party iOS dependencies or project generation are required.

1. Clone this repository:

   ```sh
   git clone https://github.com/suraj11kasasudhan/ProductCatalogiOS.git
   cd ProductCatalogiOS
   open ios/ProductCatalogue.xcodeproj
   ```
2. Select the **ProductCatalogue** scheme and an available iPhone simulator.
3. Press **Run**.

Both Debug and Release default to the live backend:

```text
https://productcatalogbackend-1.onrender.com/api
```

If an older scheme defines `CATALOGUE_API_BASE_URL`, remove it or update it to this address, then stop and run again. Render's free service can take around a minute to wake after inactivity; retry if the first request fails.

## App screens

| Screen | Functionality |
| --- | --- |
| **Catalogue** | Browse featured products and open a product category from the horizontal category chips. |
| **Category** | Explore products in a selected category with images, prices, and ratings. |
| **Product Details** | View a product’s image, description, price, and rating, then open its enquiry form. |
| **Enquiry** | Enter your name, email, optional phone number, and message to enquire about the selected product. |
| **Search** | Find products by name or description using the search field. |

The app uses baby pink backgrounds, rose accents, plum text, and a matching dark theme. The product grid adapts to screen width and accessibility text sizes. Enquiry confirmation requires backend email acceptance; browsing does not establish email delivery.

All product metadata comes through the backend. Product images use backend-provided URLs. No currency is invented when the backend supplies only a numeric price.

## Code structure

| Folder | Responsibility |
| --- | --- |
| `App` | App lifecycle, dependency wiring, and screen navigation |
| `Models` | Product responses, catalogue modes, and enquiry validation |
| `Networking` | API configuration, endpoints, requests, transport, and error mapping |
| `Services` | Catalogue service contract and response mapping |
| `ViewModels` | Screen state, async loading, and enquiry submission |
| `Views` | Screen layout, rendering, reusable components, and small binding controllers |

Controllers own cancellable tasks and forward navigation events. View models depend on protocols; superseded loads cannot overwrite newer results. Styling is centralized in `CatalogueStyle`.

## Tests and validation

Run **Command-U** in Xcode. The test target contains **25 XCTest methods** covering loading and retry states, stale search responses, enquiry validation and duplicate prevention, endpoint encoding, response decoding, cancellation, and HTTP errors. Stubbed API tests need neither an external product API nor SMTP.

Swift syntax, Xcode project references, scheme/plist structure, repeatable project generation, and selected text/button contrast pairs have been checked in the Linux workspace. These checks do not establish an Xcode build, XCTest pass, or complete visual/accessibility review. The included GitHub Actions workflow runs the iOS build and tests on macOS for pushes and pull requests to `main`; inspect its result before treating the app as build-verified.

The user has confirmed that the hosted catalogue returns product data. Production enquiry email still requires separate SMTP/provider configuration; browsing does not verify email delivery.

See [the iOS guide](ios/README.md) for local backend setup, API overrides, test commands, and the manual integration checklist.

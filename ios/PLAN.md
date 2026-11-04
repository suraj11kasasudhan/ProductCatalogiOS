# iOS client maintenance

The standalone UIKit client lives on main in suraj11kasasudhan/ProductCatalogiOS. The backend remains in suraj11kasasudhan/ProductCatalogBackend on feat/catalogue-backend.

1. Keep controllers focused on binding, tasks, and navigation; screen views own layout and rendering.
2. Preserve the public backend response contract, cancellation, stale-load protection, validation, and retry behavior.
3. Maintain the live HTTPS configuration, adaptive blush theme, accessibility text sizes, and dark mode.
4. Regenerate the checked-in Xcode project after adding or removing Swift files; keep its 28 XCTest methods and macOS CI workflow in sync.
5. Verify build and XCTest results on macOS, and manually review browsing, search, details, enquiries, keyboard layout, and accessibility. Linux syntax/project checks alone do not establish runtime readiness.

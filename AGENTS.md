# Working on ProductCatalogiOS

## Scope and architecture

- Keep refactors small and focused on the requested behavior. Avoid new frameworks, base controllers, generic coordinators, or protocols without a concrete testing/reuse need.
- Preserve AppDelegate and SceneDelegate during view-model, networking, model, and controller refactors. App lifecycle changes belong in a task that needs them.
- This task already has an isolated checkout. Use it; do not create a Git worktree unless explicitly requested.
- View controllers bind state, own cancellable tasks, and forward navigation events. Screen views own UIKit layout and rendering.
- View models stay on the main actor and accept CatalogueServing. CatalogueAPI accepts NetworkManaging; NetworkManager accepts URLSession. Construct production dependencies at the existing composition root.
- Keep models independent of UIKit. Share formatting only when it removes real duplication. Preserve backend response envelopes and avoid direct product-provider calls from the app.
- Retain cancellation/stale-response protection and enquiry duplicate prevention. Never automatically retry enquiry POSTs: delivery may have occurred before a connection was lost.

## Backend and configuration

- The backend is maintained separately in suraj11kasasudhan/ProductCatalogBackend on feat/catalogue-backend.
- The default iOS API base URL is https://productcatalogbackend-1.onrender.com/api. Debug scheme overrides are supported.
- DummyJSON supplies product data through the backend. Fake Store was replaced after Render requests received Cloudflare browser challenges (HTTP 403 and cf-mitigated: challenge).
- Never add credentials to the app, repository, documentation, or logs. Email-provider configuration belongs on the backend.

## Validation and documentation

- Read README.md, ios/README.md, ios/DECISIONS.md, and ios/AI_USAGE.md for current decisions and limitations.
- Keep Xcode project settings and source references in sync via python3 ios/generate_project.py after source-file additions/removals. Verify repeatable generation and git diff --check.
- Run the ProductCatalogue scheme's XCTest target on an available iOS simulator using Xcode 16+ or macOS CI. Keep tests offline using injected services, network managers, and URLProtocol stubs.
- Linux syntax parsing and project checks are useful but do not establish compilation or test success. Report passed, failed, pending, skipped, and unrun checks accurately.
- Record only observed CI results for the matching commit. Preserve user screenshots and unrelated changes when updating documentation or integrating remote commits.
- The author reports approximately four hours for the initial frontend/backend design and implementation and that all code was written using AI. Keep that attribution transparent; do not invent a measured timeline or claim a human hand-coded implementation.

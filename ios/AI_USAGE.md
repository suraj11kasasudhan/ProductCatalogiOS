# AI authorship and development process

All code for the iOS frontend and Node.js backend was written using AI. OpenAI Codex generated application code, tests, project configuration, documentation, and subsequent refactors. The project author supplied requirements and design choices, ran local simulator/browser checks, provided screenshots/logs, and authorized changes. No parallel agents were used in this session.

The author reports approximately four hours for the initial frontend/backend design and implementation combined. This is an author-provided estimate, not a measured activity log, and does not imply that all later revisions, deployment diagnosis, or test verification occurred within that period.

Key human-directed decisions were UIKit + MVVM, backend-owned product data, a separate public iOS repository, smaller screen controllers, initializer-based dependency injection, and the blush pink theme. Fake Store was replaced with DummyJSON only after Render logs confirmed Cloudflare browser challenges and the author approved a provider change. See DECISIONS.md for the rationale and requirement tradeoff.

Review retained cancellation and stale-response protection, enquiry duplicate prevention and uncertain-delivery handling, and reusable views rather than adding broad architecture abstractions. Unit tests use stub services, injected network managers and URLProtocol; controller routing is tested through an injected screen factory.

The Linux workspace cannot build UIKit or execute iOS XCTest. Syntax and project validation are not test-pass evidence. Record the macOS CI or local Xcode outcome for the matching commit before claiming unit tests passed. All AI-generated work remains subject to human review and ownership.

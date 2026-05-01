# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

SwiftUI iOS/iPad app (`wctech.rmProApp`, bundle `rmProApp`) that is a custom client for the **RentManager** property management REST API (`https://trieq.api.rentmanager.com/`). Targets iOS 26+ / macOS 26+, Swift 5.0, iPhone + iPad (and Mac via Designed-for-iPad). Two real properties are managed: **Haven Lake Estates** (`propertyID == 3`) and **Pembroke Park Lakes** (`propertyID == 12`); a third pseudo-property (`propertyID == 8`) is the account context historically used for loan creation.

Active workflows in the current build:
1. Browse residents with filters (Haven/Pembroke, Delinquent, Fire Protection Group, Prospectus A/B-Dry/B-Lake, Loans).
2. Generate rent-increase mailing labels (Avery 5160) + a filled USPS PS Form 3877 firm mailing book — PDFs written to the user's documents directory.

The loan-creation flow (3-request `Unit` → `Lease` → `Loan`+`Credit`+`Charge` transaction) was cut from the UI in Phase 0 of the networking rebuild; the `RMLoan` model and read paths still exist, but `NewResidentDetail` / `LoanFormSheet` are gone.

## Build / test / run

Xcode project (no SwiftPM manifest, no CocoaPods). Open `rmProApp.xcodeproj` in Xcode, or use `xcodebuild`:

```bash
# Build the app
xcodebuild build -project rmProApp.xcodeproj -scheme rmProApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Run the test bundle (uses the rmProAppTests scheme — NOT rmProApp)
xcodebuild test -project rmProApp.xcodeproj -scheme rmProAppTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Single test
xcodebuild test -project rmProApp.xcodeproj -scheme rmProAppTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:rmProAppTests/<ClassName>/<testMethodName>
```

There are two schemes: `rmProApp` (app target only) and `rmProAppTests` (host + test bundle, configured for the test action). Running `xcodebuild test -scheme rmProApp` fails with *"Scheme rmProApp is not currently configured for the test action"*.

**CI is currently misconfigured.** `.github/workflows/tests.yml` runs `xcodebuild test -scheme rmProApp …`, which has no test action — every CI run fails the moment it tries to discover tests. Fix is to change the workflow's `-scheme` from `rmProApp` to `rmProAppTests`. Until then, CI is not actually validating anything; rely on local `xcodebuild test` against the right scheme.

Running the app requires valid RentManager credentials; they're saved to the iOS Keychain on first successful login.

## Architecture

### Authentication lifecycle (`rmProAppApp` → `TokenManager` → `KeychainService` → root view switch)

- On launch, `rmProAppApp.init` fires `TokenManager.shared.initializeAuthentication()`. `TokenManager` is `@MainActor`, owns `@Published isAuthenticated / isAuthenticating / authenticationError`.
- `KeychainService` stores credentials under service `com.rmProApp.api` using `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`. If present → auto-refresh token; otherwise → `LoginView`; if authenticated → `RootView`.
- API tokens from `/Authentication/AuthorizeUser/` are treated as expiring after 15 minutes; a Combine timer refreshes every 13 minutes via `refreshToken()`. Every API call reads `await TokenManager.shared.token` and sends it as the `X-RM12Api-ApiToken` header (set inside `RMAPIClient.makeURLRequest`).

### Networking layer (`rmProApp/Networking/Core/`)

The whole networking layer was rebuilt in Phase 1. Old types referenced in older notes (`RentManagerAPIClient`, `URLBuilder`) **no longer exist** — don't go looking for them.

- **`RMAPIClient.shared`** — single entry point. `func send<R: RMRequest>(_ request: R) async throws -> R.Response`. Builds the URL from the request, attaches the bearer token, runs through `RequestCoalescer` (de-duplicates concurrent identical GETs by URL string), checks status, then decodes.
- **`RMRequest` protocol** — every endpoint declares its `path`, `method`, `queryItems`, `body`, and `associatedtype Response: Decodable`. Concrete examples: `GetTenantsRequest` (returns `[RMTenant]`), `GetUnitsRequest` (`[RMUnit]`), `GetUserDefinedFieldsRequest` (`[RMUserDefinedValue]`), `GetTenantDetailRequest`, etc.
- **`RMQuery`** namespace is the only sanctioned way to build query items: `embeds(_:)`, `fields(_:)`, `filters(_:)`, `pageSize(_:)`. The filter serialization is `key,operation,value;…`.
- **`RMFilter`** — `struct RMFilter { key, operation, value }`. RentManager's filter operators are `eq`, `ne`, `lt`, `gt`, `ge`, `le`, plus a few others — **`gte`/`lteq`/etc. are rejected by the API**. Use `ge` for ≥ (this trap bit us in Phase 2; the comment in `SyncCoordinator.deltaFilter` calls it out).
- **`RMAPIError`** — typed errors. `.decoding(error, rawBody:)` includes the truncated raw body in `errorDescription` so future decode failures self-explain. Status codes 401/403/404/429 have dedicated cases; other 4xx → `.client`, 5xx → `.server`.

RentManager's `embeds` (eager-loaded relations) and `fields` (projection) are modeled as enum sets per entity (`TenantEmbeds` / `TenantFields` in `Networking/Parameters/TenantParams.swift`, similarly `UnitEmbedOption` / `UnitFieldOption`). Use the curated presets at the bottom of `TenantParams.swift` (`fullEmbeds`, `simpleEmbeds`, `baseEmbeds`, `bareEmbeds`, `leaseEmbeds`, `contactsEmbeds`, `loanEmbeds`, `udfEmbeds`, `addressEmbeds`, `transactionsEmbeds`) rather than hand-assembling embed lists; the app's performance depends on asking for only what each screen needs.

#### One important RentManager API quirk

When a query matches **zero rows** (e.g. a delta filter with no updates since `lastSyncDate`), the API returns **HTTP 200 with an empty response body**. `JSONDecoder` can't parse empty data. `RMAPIClient.send` coerces empty/whitespace-only bodies to `"[]"` before decoding so collection-typed responses round-trip cleanly. Non-collection request types still surface the decode error (correctly — empty body is a real problem there).

### Persistence + delta sync (`Networking/Sync/`, `Networking/Repositories/`)

This is the layer most likely to bite you if you miss it. There's a real on-disk SwiftData store, full/delta sync per entity, and a documented design rule about which fields persist.

- **Container wiring.** `rmProAppApp` attaches an explicit `.modelContainer(for: [RMTenant.self, RMUnit.self, RMLease.self, RMLoan.self, RMContact.self, RMPhoneNumber.self, RMUserDefinedValue.self, WCLeaseTenant.self, WCTransaction.self])` on the WindowGroup. Without that explicit list, SwiftUI hands back a default scratch context that "accepts" inserts but doesn't persist anything across launches — a bug we hit twice; the explicit container is load-bearing.
- **`SwiftDataManager.shared`** — generic CRUD over any `PersistentModel`. **Must be wired before first use:** `RootView.initializeStartupData` calls `SwiftDataManager.shared.setModelContext(modelContext)` in its `.task`. Calling any method before that throws `SwiftDataError.contextNotSet`.
- **`SyncCoordinator.shared`** — actor that owns per-entity `lastSyncDate` in `UserDefaults` (key derived from each `SyncableEntity`'s `lastSyncDateKey`). `deltaFilter(for:)` returns `RMFilter(key: "UpdateDate", operation: "ge", value: <iso>)` when there's a prior sync, or `nil` for first-run / forced-full. ISO formatter uses `withInternetDateTime` — emits a `Z` UTC suffix that RentManager accepts.
- **Repositories** — one actor per syncable entity, all in `Networking/Repositories/`:
  - `TenantRepository` — `syncBase(forceRefresh:)` (delta or full) + `syncFull(forceRefresh:)` (base + 5 concurrent section-hydrate fetches: leases, contacts, addresses, loans, UDFs).
  - `UnitRepository` — `syncUnits(_ preset: .basic | .full, forceRefresh:)`. Two embed/field tiers share one code path.
  - `UDFRepository` — `syncUDFs(forceRefresh:)`.
  - `TransactionRepository` — merges charges + payments + payment-reversals into `[WCTransaction]` for resident detail.
  - All four follow the same shape: hydrate from SwiftData → apply delta filter → fetch via `RMAPIClient` → merge or replace cache → persist to SwiftData → `markSynced`. **`markSynced` only runs after a successful fetch** (the catch path early-returns the existing cache); a transient API error does not advance the sync cursor.
- **`TenantDataManager.shared`** — `@Observable @MainActor` orchestrator on top of `TenantRepository` + `RMDataManager`. Owns `allTenants: [RMTenant]` and `allUnitTenants: [WCLeaseTenant]` for the views to read. 5-minute in-memory cache (`cacheTimeout = 300s`) gates repeat `fetchTenants(...)` calls.
- **`RMDataManager.shared`** — older facade that fronts unit + UDF loads (delegates to `UnitRepository` / `UDFRepository`).

#### The `@Transient` rule on `@Model` classes

Nine types are `@Model`-persisted: `RMTenant`, `RMUnit`, `RMLease`, `RMLoan`, `RMContact`, `RMPhoneNumber`, `RMUserDefinedValue`, `WCLeaseTenant`, `WCTransaction`. Their **scalar fields persist; cross-`@Model` relationships are marked `@Transient`** (20 properties total across `RMTenant`, `RMUnit`, `RMLease`, `RMContact`, `WCLeaseTenant`).

The reason: SwiftData refuses to materialize the schema if a to-many relationship between two `@Model` types lacks an explicit inverse. The design intent (documented on `TenantRepository.hydrateSections`) is *"section fetches are in-memory only — they don't re-persist through SwiftData. The base rows are the persistence surface."* Every session re-hydrates relationships from the API.

If you add a new property to one of these `@Model` classes:
- **Scalar/value type** (`Int?`, `String?`, `Decimal?`, `Bool?`, plain Codable struct) → goes through normal SwiftData persistence.
- **Reference to another `@Model` type** (`RMLease?`, `[RMContact]?`, etc.) → must be marked `@Transient` with a default value, e.g. `@Transient var leases: [RMLease]? = nil`.

#### The `description`-collision trap

`@Model` classes cannot transitively reach a Codable struct with a property literally named `description` — SwiftData's macro reflects through their fields and asserts *"Unable to have an Attribute named description"* (the name collides with `CustomStringConvertible.description`). Two structs in this codebase had this and were renamed to `descriptionText`: `RMChargeType` and `RMAddressType` (in `RMAddress.swift`). The `CodingKey` still maps `"Description"` from JSON, so the wire format is unchanged. Don't reintroduce a Swift property called `description` on any Codable struct that's reachable from an `@Model` class.

### Model naming conventions (`rmProApp/Models/`)

- **`RM*` types** mirror RentManager API entities (`RMTenant`, `RMLease`, `RMUnit`, `RMAddress`, `RMContact`, `RMLoan`, `RMCharge`, `RMPayment`, `RMUserDefinedValue`, …). They are `Codable` with `CodingKeys` translating PascalCase JSON (`"FirstName"`) to camelCase Swift, and use manual `init(from:)` / `encode(to:)` so every field is optional — the server omits anything not requested via `fields`.
- **`WC*` types** (`WCLeaseTenant`, `WCRentIncreaseTenant`, `WCTransaction`) are composed/denormalized views:
  - `WCLeaseTenant` flattens one `RMTenant` × one `RMLease` into a single row, so a tenant with N active leases produces N rows. This is what resident list/detail screens consume.
  - `WCRentIncreaseTenant` is a label-oriented projection (unitName, street, box, city, state, zip, contacts) built in `TenantDataManager.buildRentIncreaseTenants()`.
  - `WCTransaction` is the merged charges/payments/reversals stream used by `ResidentDetailViewModel.buildTransactions` (covered by tests in `MailingsTests.swift`).

### Navigation (`rmProApp/App/`)

Two-shape shell driven by horizontal size class (rebuilt in Phase 4):

- `RootView` is the entry point after auth. Holds three `NavigationPath`s (one per section) so they survive size-class changes (rotation, split-screen).
- **Compact width** (iPhone): `TabView` with `ResidentsTab` / `MailingsTab` / `SettingsTab`.
- **Regular width** (iPad, wide split): `NavigationSplitView` with a sidebar list selecting the same three sections.
- Each section view (e.g. `ResidentsTab`) owns its own `NavigationStack(path:)` and its own destination enum (e.g. `ResidentsDestination.residentDetail(WCLeaseTenant)`). Add a new screen by extending the section's destination enum and the `navigationDestination` switch, **not** by adding a global enum case.
- `SettingsTab` is currently a "Coming soon" placeholder; its `SettingsDestination` enum has no cases.
- The full-width primary action button is `PrimaryButton` (in `DesignSystem/`); it replaces the older `HomeButton` from before Phase 4c.

## Domain quirks (easy to get wrong)

- **Haven vs Pembroke address formatting.** Haven addresses (`propertyID == 3`) are stored as a two-line string `"<street>\r\n<box>"`. Label/PS3877 code splits on `"\r\n"` and emits `<street>` + `"Box <box>"`. Pembroke addresses are single-line. When touching `LabelManager`, `PS3877FormManager`, or `TenantDataManager.buildRentIncreaseTenants`, preserve this split — breaking it silently puts the box number in the middle of someone's address. Covered by `MailingsTests.swift` (3 cases).
- **Fire Protection Group is a UDF.** `userDefinedFieldID == 67` (for units) and `64` (tenants) with name `"HEI- Fire Protection Approved 2026"` drive the red-text styling in `LabelManager` and the Fire Protection filter in `ResidentsHomeView`. The year is in the name string — it will need updating annually.
- **Hardcoded RentManager IDs.** Any historical loan-creation code (`ChargeTypeID`s 15/17/16/38, `UnitTypeID: 6`, `propertyID: 8` as the loan account context) corresponds to specific RentManager configuration for this tenant — do not assume they generalize to other RentManager installations.
- **The `gte` trap.** When adding date/numeric range filters, use `ge`/`le`, not `gte`/`lte`. The API rejects the latter outright.

## Repo gotchas

- **Misnamed folder:** `rmProApp/Assets/` is **source code** (`EncodeDecodeHelpers.swift`, `SwiftUIAssets.swift`), not an asset catalog. The real asset catalog is `Assets.xcassets/`.
- **`rmProApp/Views/Units/UnitsView.swift`** is an orphan stub from before the Phase 4 shell — not wired into any tab or destination. Either wire it or delete it; it's not load-bearing.
- **CI uses `macos-latest`** (`.github/workflows/tests.yml`). Deployment target is iOS 26 / macOS 26, so the runner needs an Xcode that ships the iOS 26 SDK (Xcode 17+). If a runner upgrade drops the iPhone 17 sim, update the destination name. (Independent of the broken-test-scheme problem flagged above.)

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

SwiftUI iOS/iPad app (`wctech.rmProApp`, bundle `rmProApp`) that is a custom client for the **RentManager** property management REST API (`https://trieq.api.rentmanager.com/`). Targets iOS 17.6+, Swift 5.0, iPhone + iPad. Two real properties are managed: **Haven Lake Estates** (`propertyID == 3`) and **Pembroke Park Lakes** (`propertyID == 12`); a third pseudo-property (`propertyID == 8`) is used as the account context for loan creation.

Primary workflows:
1. Generate rent-increase mailing labels (Avery 5160) + a filled USPS PS Form 3877 firm mailing book — PDFs written to the user's documents directory.
2. Browse residents with filters (Haven/Pembroke, Delinquent, Fire Protection Group, Prospectus A/B-Dry/B-Lake, Loans).
3. Create a new loan for a tenant — this is a three-request transaction (Unit create → Lease create → Loan + Credit down-payment + Home-Sales charge).

## Build / test / run

Xcode project (no SwiftPM manifest, no CocoaPods). Open `rmProApp.xcodeproj` in Xcode, or use `xcodebuild`:

```bash
# Build
xcodebuild build -project rmProApp.xcodeproj -scheme rmProApp \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# Full test run (mirrors CI in .github/workflows/tests.yml)
xcodebuild test -project rmProApp.xcodeproj -scheme rmProApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' \
  -enableCodeCoverage YES -resultBundlePath TestResults.xcresult

# Single test
xcodebuild test -project rmProApp.xcodeproj -scheme rmProApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:rmProAppTests/<ClassName>/<testMethodName>
```

**Note:** `rmProAppTests/rmProAppTests.swift` is currently **empty** — there are no tests yet. CI will pass with zero coverage. Running the app requires valid RentManager credentials; they are saved to the iOS Keychain on first successful login.

## Architecture

### Authentication lifecycle (spans `rmProAppApp` → `TokenManager` → `KeychainService` → root view switch)

- On launch, `rmProAppApp.init` fires `TokenManager.shared.initializeAuthentication()`. `TokenManager` is `@MainActor`, owns `@Published isAuthenticated / isAuthenticating / authenticationError`.
- `KeychainService` stores credentials under service `com.rmProApp.api` using `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`. If present → auto-refresh token. If missing → `LoginView`; otherwise → `MainAppView`.
- API tokens from `/Authentication/AuthorizeUser/` are treated as expiring after 15 minutes; a Combine timer refreshes every 13 minutes via `refreshToken()`. Every API call reads `await TokenManager.shared.token` as the `X-RM12Api-ApiToken` header.

### Networking layer (`rmProApp/Networking/Essential API Manager/`)

- `RentManagerAPIClient.shared` — three generic entry points: `request(url:responseType:)` (GET, decodes to `T`), `postRequest(url:body:responseType:)` (POST, decodes response), `postRequest(url:body:)` (POST, returns `Bool` for status-only creates). **Watch out:** the GET path does not check `httpResponse.statusCode` — any non-2xx body that happens to decode will come back as `T`; non-decodable failures silently return `nil`.
- `URLBuilder.shared.buildURL(endpoint:embeds:fields:filters:pageSize:id:)` is the only sanctioned way to construct RentManager URLs. `endpoint` is the `APIEndpoint` enum (`Networking/Parameters/APIEndpointsFilter.swift`), `filters` is `[RMFilter]` serialized as `key,operation,value;...`.
- RentManager's `embeds` (eager-loaded relations) and `fields` (projection) are modeled as `TenantEmbeds` / `TenantFields` enums (and similarly `UnitEmbedOption` / `UnitFieldOption`). Use the curated presets at the bottom of `TenantParams.swift` (`fullEmbeds`, `simpleEmbeds`, `baseEmbeds`, `bareEmbeds`, `leaseEmbeds`, `contactsEmbeds`, `loanEmbeds`, `udfEmbeds`, `addressEmbeds`, `transactionsEmbeds`) rather than hand-assembling embed lists; the app's performance depends on asking for only what each screen needs.

### Data orchestration layer (`rmProApp/Networking/RM Data Manager/`)

- `TenantDataManager.shared` — **the** tenant source of truth. `@MainActor` + `@Published` lists consumed everywhere via `@EnvironmentObject` (injected in `MainAppView`). `fetchTenants(forceRefresh:)` does a base fetch, then runs UDFs / leases / contacts / addresses / loans / units in a single `TaskGroup` and merges each section back into the snapshot in `mergeTenant` keyed by `tenantID`. 5-minute in-memory cache gates repeat calls.
- `RMDataManager.shared` — units + UDFs. Has two unit loads: `loadUnitsWithBasicData()` (minimal embeds) and `loadUnits()` (full embeds including `CurrentOccupants`, `PrimaryAddress`, `UserDefinedValues`). UDFs use a SwiftData cache with a per-row `isStale()` check driven by `lastSyncDate` + `updateFrequency`; `loadUDFsOnStartup()` returns the cached set when fresh, otherwise pulls the API.
- `SwiftDataManager.shared` — generic CRUD over any `PersistentModel`. **Must be wired up before first use:** `MainAppView.initializeStartupData()` calls `SwiftDataManager.shared.setModelContext(modelContext)` in `.onAppear`. Calling any method before that throws `SwiftDataError.contextNotSet`.
- `TenantTransactionsManager.shared.processTransactions(tenant:)` merges charges + payments + payment-reversals into a single `WCTransaction` stream for the resident-detail UI.

### Model naming conventions (`rmProApp/Models/`)

- `RM*` types mirror RentManager API entities (`RMTenant`, `RMLease`, `RMUnit`, `RMAddress`, `RMContact`, `RMLoan`, `RMCharge`, `RMPayment`, `RMUserDefinedValue`, …). They are `Codable` with `CodingKeys` translating PascalCase JSON (`"FirstName"`) to camelCase Swift, and use manual `init(from:)` / `encode(to:)` so every field is optional — the server omits anything not requested via `fields`.
- `WC*` types (`WCLeaseTenant`, `WCRentIncreaseTenant`, `WCTransaction`) are the author's composed/denormalized views:
  - `WCLeaseTenant` flattens one `RMTenant` × one `RMLease` into a single row, so a tenant with N active leases produces N rows — this is what resident list/detail screens consume.
  - `WCRentIncreaseTenant` is a label-oriented projection (unitName, street, box, city, state, zip, contacts) built in `TenantDataManager.buildRentIncreaseTenants()`.
- Several models are `@Model` (SwiftData-persisted): `RMTenant`, `RMLease`, `RMLoan`, `RMUserDefinedValue`, `WCLeaseTenant`. The rest are plain `struct`s or non-persistent classes.

### Navigation

- `MainAppView` owns the sole `NavigationStack` bound to a single `NavigationPath`. Every destination is a case in `AppDestination` (see bottom of `MainAppView.swift`) — add a new screen by extending that enum and the `navigationDestination` switch.
- Every view that navigates takes `@Binding var navigationPath: NavigationPath`. Use the `HomeButton(title:destination:)` helper in `Assets/SwiftUIAssets.swift` for the standard full-width blue action button.

## Domain quirks (easy to get wrong)

- **Haven vs Pembroke address formatting.** Haven addresses (`propertyID == 3`) are stored as a two-line string `"<street>\r\n<box>"`. Label/PS3877 code splits on `"\r\n"` and emits `<street>` + `"Box <box>"`. Pembroke addresses are single-line. When touching `LabelManager`, `PS3877FormManager`, or `TenantDataManager.buildRentIncreaseTenants`, preserve this split — breaking it silently puts the box number in the middle of someone's address.
- **Loan creation is three requests, not one.** `NewResidentDetail.createNewLoan()` POSTs to `/Loans`, then `/Credits` (the down-payment, `ChargeTypeID: 15`), then `/Charges` (Home Sales, `ChargeTypeID: 17`). All three target `propertyID: 8`. Hardcoded `ChargeTypeID`s (15, 17, 16, 38) and `UnitTypeID: 6` in the `Create*Request` structs correspond to specific RentManager configuration for this tenant — do not assume they generalize to other RentManager installations.
- **Fire Protection Group is a UDF.** `userDefinedFieldID == 67` (for units) and `64` (tenants) with name `"HEI- Fire Protection Approved 2026"` drive the red-text styling in `LabelManager` and the Fire Protection filter in `ResidentsHomeView`. The year is in the name string — it will need to be updated annually.
- **"Legacy ContentView" is intentional.** `AppDestination.contentView` → `ContentView` is labeled "Labels & PS3877 (Legacy ContentView)" in `RentIncreaseNoticeBuilder`; it's the older label-generation path being migrated to the newer builder. Both still work and are reachable from `HomeView`.
- **`TenantDataManager.updateFireProtectionGroup(...)` is marked `// TODO: Need to fix Function`** — it hand-builds a JSON string with hardcoded IDs and never awaits the `URLSession` task. Don't use it as a reference for new POSTs; copy `createNewLoan`'s pattern (typed `Encodable` body + `RentManagerAPIClient.postRequest`) instead.

## Repo gotchas

- **Duplicate file on disk:** `rmProApp/Date+Extensions.swift` and `rmProApp/Extensions/Date+Extensions.swift` contain identical content. Only `Date+Extensions.swift` (file ref `E1F5077E2EB2B51E002A3F2E` in `project.pbxproj`) is in the Xcode target — editing the `Extensions/` copy changes nothing. Consolidate before adding new extensions.
- **Misnamed folder:** `rmProApp/Assets/` is **source code** (`EncodeDecodeHelpers.swift`, `SwiftUIAssets.swift`), not an asset catalog. The real asset catalog is `Assets.xcassets/`.
- **`TODO:` comments in `TenantDataManager` and model files describe intentional future work** (dashboard filters, SwiftData-based delta sync of tenant data — see the bottom half of `Notes` at the repo root for the plan). They are not bugs to chase unless specifically asked.
- **CI pins `macos-latest` + `Xcode_15.0.app` + iOS 17.0 simulator** (`.github/workflows/tests.yml`) while the project's deployment target is iOS 17.6. Local builds on newer Xcode should still succeed; if CI fails after an Xcode upgrade, bump the runner's `xcode-select` path and the simulator OS string together.

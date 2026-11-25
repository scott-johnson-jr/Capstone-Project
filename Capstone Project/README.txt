# Capstone Project

iOS application for managing employees, inventory, orders, and dashboard analytics for the BootcampCentral / AdventureWorks system.

## Supported Versions

*   **iOS:** iOS 26.5+
*   **Xcode:** Xcode 16+ / 26+ (matching iOS 26.5 SDK)
*   **Dependencies:** No external Swift Package Manager packages or third-party frameworks
*   **Devices:** iPhone

## Setup

1.  Clone the repository:
    ```bash
    git clone [https://github.com/scott-johnson-jr/Capstone-Project.git](https://github.com/scott-johnson-jr/Capstone-Project.git)
    cd Capstone-Project
    ```
2.  Open `Capstone Project/Capstone Project.xcodeproj` in Xcode.
3.  Select an iPhone simulator in the scheme bar and press `Cmd + R` to build and run.

## Configuration

*   **Backend API:** `APIClient` connects to `https://api.bootcampcentral.com` via `URLSession` and `async/await` (`Accept: application/json`), and default remote repository keys in `RepositoryInjectionKeys.swift` point to `https://api.bootcampcentral.com/api`.
*   **Auth Endpoint:** `AuthService.shared` targets `https://api.bootcampcentral.com/api/Login/refresh` (`POST` with `Bearer` token header and JSON `refreshToken` body).
*   **Environment & Secrets:** API base URLs are defined in Swift source rather than external `.xcconfig` files or environment variables; no third-party API keys or external package dependencies are configured.
*   **Repository Notes:** Check `.gitignore` coverage (rename `gitignore.txt` to `.gitignore` if Git is not already ignoring build/local artifacts) and verify which project folder/files are actively compiled in `Capstone Project/Capstone Project.xcodeproj`.

## Credentials Procedure

*   **Sign-In & Token Refresh:** `AuthViewModel` (`@Observable`) manages `login(loginId:password:)`, `refreshToken()`, and `logout()` state (`isLoggedIn`, `userName`, `errorMessage`, `isLoading`) using `AuthService.shared`.
*   **Test / Demo Credentials:** Sign in with team-provided `loginId` and password credentials; never commit real credentials, tokens, or secrets to Git.
*   **Keychain Storage:** `KeychainHelper` wraps `Security` framework generic password operations (`save`, `read`, `delete`). Confirm token persistence and Keychain cleanup during `logout()`.

## Architecture Summary

*   **Pattern:** SwiftUI + MVVM with `@Observable` view models and SwiftUI `EnvironmentKey` dependency injection (`RepositoryInjectionKeys.swift`).
*   **Project Structure (`Capstone Project/`):**
    *   `Application` — App lifecycle and environment wiring
    *   `CacheBox` — Local caching / cache utilities
    *   `Data` — Networking client (`APIClient`) and data layer support
    *   `Models` — Domain and response models
    *   `Repositories` — Remote and local repositories (`RepositoryProtocol`, `InventoryRepository`, `DashboardRepository`, `SavedProductsRepository`, `BrowsingHistoryRepository`, etc.)
    *   `Services` — Auth and service helpers (`AuthService`, `KeychainHelper`, etc.)
    *   `Views` — SwiftUI screens and UI components
    *   Top-level app files: `Capstone_ProjectApp.swift`, `ContentView.swift`, and `Assets.xcassets`

## Testing

The project uses the Swift `Testing` framework for unit tests (`APIClientTests`, `InventoryRepositoryTests`, `InventoryFetchResultTests`, `Capstone_ProjectTests`) and `XCTest` for UI/launch tests (`Capstone_ProjectUITests`, `Capstone_ProjectUITestsLaunchTests`).

*   **Run in Xcode:** Press `Cmd + U` to run the test suite.
*   **Run via CLI:**
    ```bash
    xcodebuild test \
      -project "Capstone Project/Capstone Project.xcodeproj" \
      -scheme "Capstone Project" \
      -destination 'platform=iOS Simulator,name=iPhone 16'
    ```

See [TEST_REPORT.md](TEST_REPORT.md) for coverage priorities, current test scope, and unresolved defects.

## Known Limitations

*   **No Known Runtime Defects Reported:** No active runtime bugs were reported during local testing.
*   **Test Coverage Gaps:** Automated unit tests cover `APIClient` responses and `InventoryRepository` Core Data cache fallback (`URLError`), alongside basic launch/performance UI tests; ViewModels, other repositories, `KeychainHelper`, and end-to-end feature workflows still lack dedicated tests, and `InventoryFetchResult` cache assertions appear in both `Capstone_ProjectTests` and `InventoryFetchResultTests`.
*   **Auth & Session Cleanup:** `AuthViewModel.logout()` resets in-memory session properties (`isLoggedIn`, `userName`) without yet clearing stored Keychain entries, and `AuthService` / `AuthViewModel` method signatures should be verified end-to-end.
*   **Networking & Configuration:** API base URLs are hardcoded in source rather than parameterized per environment, `APIClient.get` does not currently attach an `Authorization` header, and `urlBase` values across repositories (`https://api.bootcampcentral.com/api`) vs. `APIClient` (`/api/...` paths) should be verified against live endpoints.
*   **Repository Layout:** Stray files/folders outside `Capstone Project/` in the repository should be reviewed so contributors know which folder is the active Xcode project.

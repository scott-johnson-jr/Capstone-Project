import Foundation
import Observation

@Observable
class AuthViewModel {
    var isLoggedIn = false
    var userName: String?
    var errorMessage: String?
    var isLoading = false
    
    private let auth = AuthService.shared
    
    func login(loginId: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let result = try await auth.login(loginId: loginId, password: password)
            isLoggedIn = result.success
            userName = result.userName
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func refreshToken() async {
        do {
            let result = try await auth.refresh()
            userName = result.userName
            isLoggedIn = true
        } catch {
            errorMessage = "Session expired. Please log in again."
            isLoggedIn = false
        }
    }
    
    func logout() {
        isLoggedIn = false
        userName = nil
        // Clear Keychain here if you added it
    }
}

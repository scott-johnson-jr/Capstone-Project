
import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authStatus: AuthStatus
    
    @State private var loginId = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Login ID", text: $loginId)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityLabel("Login ID")
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .accessibilityLabel("Password")
                }
                
                if let errorMessage {
                    Section {
                        Label {
                            Text(errorMessage)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle")
                        }
                        .foregroundStyle(.red)
                        .accessibilityAddTraits(.updatesFrequently)
                    }
                }
                
                Section {
                    Button(action: login) {
                        HStack {
                            Spacer()
                            
                            if isLoading {
                                ProgressView("Logging in...")
                            } else {
                                Text("Log In")
                            }
                            
                            Spacer()
                        }
                    }
                    .disabled(
                        loginId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        password.isEmpty ||
                        isLoading
                    )
                    .accessibilityHint("Signs in using your login ID and password")
                }
            }
            .navigationTitle("Log In")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @MainActor
    private func login() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            defer {
                isLoading = false
            }
            
            do {
                _ = try await AuthManager.shared.login(
                    loginId: loginId,
                    password: password
                )
                
                password = ""
                authStatus.setLoggedIn(true)
            } catch let error as URLError {
                switch error.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    errorMessage = "No internet connection. Check your connection and try again."
                    
                case .timedOut:
                    errorMessage = "The login request timed out. Please try again."
                    
                case .cannotFindHost, .cannotConnectToHost:
                    errorMessage = "Unable to reach the server. Please try again later."
                    
                default:
                    errorMessage = "A connection error occurred. Please try again."
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthStatus())
}


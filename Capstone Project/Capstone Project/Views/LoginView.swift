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
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Log In")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(loginId.isEmpty || password.isEmpty || isLoading)
                }
            }
            .navigationTitle("Log In")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func login() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let result = try await AuthManager.shared.login(loginId: loginId, password: password)
                authStatus.updateLoginStatus(
                    success: true,
                    authToken: result.accessToken,
                    refreshToken: result.refreshToken)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    LoginView().environmentObject(AuthStatus())
}

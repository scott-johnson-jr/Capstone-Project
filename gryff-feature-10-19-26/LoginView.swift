import SwiftUI

struct LoginView: View {
    @State private var loginId = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isLoggedIn = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Login ID", text: $loginId)
                        .textContentType(.username)
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
            .navigationDestination(isPresented: $isLoggedIn) {
                Text("Logged in as \(loginId)")
                    .navigationTitle("Home")
            }
        }
    }

    private func login() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                _ = try await AuthManager.shared.login(loginId: loginId, password: password)
                isLoggedIn = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
}

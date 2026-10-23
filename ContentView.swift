import SwiftUI

struct ContentView: View {
    @State private var viewModel = AuthViewModel()
    @State private var loginId = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            if viewModel.isLoggedIn {
                VStack(spacing: 20) {
                    Text("Welcome, \(viewModel.userName ?? "User")")
                        .font(.title)
                    
                    Button("Refresh Token") {
                        Task { await viewModel.refreshToken() }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Logout") {
                        viewModel.logout()
                    }
                    .buttonStyle(.bordered)
                }
                .navigationTitle("Home")
            } else {
                Form {
                    TextField("Login ID", text: $loginId)
                        .textContentType(.username)
                        .autocorrectionDisabled()
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                    
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button("Login") {
                            Task {
                                await viewModel.login(loginId: loginId, password: password)
                            }
                        }
                        .disabled(loginId.isEmpty || password.isEmpty)
                    }
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
                .navigationTitle("Login")
            }
        }
    }
}

#Preview {
    ContentView()
}

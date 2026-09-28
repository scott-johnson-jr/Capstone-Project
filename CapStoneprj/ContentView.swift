import SwiftUI

struct ContentView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var loginFailed = false
    @FocusState private var focusedField: Field?

    enum Field {
        case username, password
    }

    private let validCredentials: [String: String] = [
        "admin": "password123",
        "user": "welcome1",
        "test": "test123",
        "guest": "guest"
    ]

    var body: some View {
        Group {
            if isLoggedIn {
                welcomeView
            } else {
                loginForm
            }
        }
        .animation(.easeInOut, value: isLoggedIn)
    }

    private var loginForm: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Sign In")
                .font(.largeTitle.bold())

            VStack(spacing: 16) {
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .username)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit { attemptLogin() }

                if loginFailed {
                    Text("Incorrect username or password")
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Button(action: attemptLogin) {
                    Text("Log In")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(username.isEmpty || password.isEmpty)
            }
            .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 4) {
                Text("Accepted logins")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("admin / password123")
                Text("user / welcome1")
                Text("test / test123")
                Text("guest / guest")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var welcomeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 70))
                .foregroundStyle(.green)

            Text("Welcome, \(username)!")
                .font(.title.bold())

            Text("You have successfully logged in.")
                .foregroundStyle(.secondary)

            Button("Log Out") {
                isLoggedIn = false
                username = ""
                password = ""
                loginFailed = false
            }
            .buttonStyle(.bordered)
            .padding(.top, 20)
        }
    }

    private func attemptLogin() {
        focusedField = nil

        let key = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let enteredPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        if let expected = validCredentials[key], expected == enteredPassword {
            loginFailed = false
            isLoggedIn = true
        } else {
            loginFailed = true
        }
    }
}

#Preview {
    ContentView()
}

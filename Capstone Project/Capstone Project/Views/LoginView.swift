import SwiftUI

struct LoginView: View {
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
        // NOTE: Wrapped in ScrollView to ensure adaptability across orientations and extreme Dynamic Type sizes without clipping
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60, weight: .regular)) // baseline larger size
                    .dynamicTypeSize(DynamicTypeSize.accessibility3) // caps growth at extreme text sizes
                    .foregroundStyle(.blue)

                Text("Sign In")
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader) // NOTE: Identifies the title as a screen header for VoiceOver

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
                        // NOTE: Added a warning icon alongside the red color so error information
                        // does not depend on color alone (Color Independence requirement).
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .accessibilityHidden(true)
                            Text("Incorrect username or password")
                        }
                        .font(.caption)
                        .foregroundStyle(.red)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Error: Incorrect username or password")
                    }

                    Button(action: attemptLogin) {
                        Text("Log In")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(username.isEmpty || password.isEmpty)
                    .frame(minHeight: 44) // NOTE: Ensures minimum 44pt touch target height requirement
                }
                .padding(.horizontal, 32)

                Spacer(minLength: 40)
            }
            .padding()
        }
    }

    private var welcomeView: some View {
        // NOTE: Wrapped in ScrollView for landscape orientation and large Dynamic Type adaptability
        ScrollView {
            VStack(spacing: 20) {
                Spacer(minLength: 40)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 70))
                    .dynamicTypeSize(DynamicTypeSize.accessibility3) // caps growth at extreme text sizes
                    .foregroundStyle(.green)

                Text("Welcome, \(username)!")
                    .font(.title.bold())
                    .accessibilityAddTraits(.isHeader) // NOTE: Identifies welcome title as a header for VoiceOver

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
                .frame(minHeight: 44) // NOTE: Ensures minimum 44pt touch target requirement for logout button

                Spacer(minLength: 40)
            }
            .padding()
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
    LoginView()
}

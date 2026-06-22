import SwiftUI

struct CustomerLoginView: View {
    @EnvironmentObject private var authViewModel: CustomerAuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("CustomerPrimaryDark"), Color("CustomerPrimary")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Image(systemName: "shippingbox.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.white)

                    Text("TEMBUS")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)

                    Text("Kirim Lebih Mudah, Lebih Cepat")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(.top, 60)

                Spacer()

                VStack(spacing: 20) {
                    Text("Masuk ke Akun")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Email
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(Color("CustomerPrimary"))
                            TextField("email@kamu.com", text: $email)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Password
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(Color("CustomerPrimary"))
                            if isPasswordVisible {
                                TextField("Masukkan password", text: $password)
                            } else {
                                SecureField("Masukkan password", text: $password)
                            }
                            Button { isPasswordVisible.toggle() } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if let error = authViewModel.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption).foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task { await authViewModel.login(email: email, password: password) }
                    } label: {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Masuk").font(.body.bold())
                            }
                        }
                        .frame(maxWidth: .infinity).padding()
                        .background(Color("CustomerPrimary"))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
                    .opacity((email.isEmpty || password.isEmpty) ? 0.6 : 1)

                    Button("Belum punya akun? Daftar") { /* TODO: navigate to register */ }
                        .font(.subheadline).foregroundStyle(Color("CustomerPrimary"))
                }
                .padding(24)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.15), radius: 20, y: -5)
            }
        }
    }
}

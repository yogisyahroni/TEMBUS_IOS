import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var phone: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Image("bg_courier_login")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    // Logo area
                    VStack(spacing: 8) {
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.white)

                        Text("TEMBUS Kurir")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)

                        Text("Mitra Pengiriman Terpercaya")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.top, 60)

                    Spacer()

                    // Form card
                    VStack(spacing: 20) {
                        Text("Masuk ke Akun")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Phone field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Nomor HP")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)

                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundStyle(Color("Primary"))
                                TextField("08xxxxxxxxxx", text: $phone)
                                    .keyboardType(.phonePad)
                                    .autocorrectionDisabled()
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Password field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)

                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(Color("Primary"))
                                if isPasswordVisible {
                                    TextField("Masukkan password", text: $password)
                                } else {
                                    SecureField("Masukkan password", text: $password)
                                }
                                Button {
                                    isPasswordVisible.toggle()
                                } label: {
                                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Error message
                        if let error = authViewModel.errorMessage {
                            Label(error, systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Login button
                        Button {
                            Task {
                                await authViewModel.login(phone: phone, password: password)
                            }
                        } label: {
                            HStack {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Masuk")
                                        .font(.body.bold())
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Primary"))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(authViewModel.isLoading || phone.isEmpty || password.isEmpty)
                        .opacity((phone.isEmpty || password.isEmpty) ? 0.6 : 1)
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.15), radius: 20, y: -5)
                }
            }
        }
    }
}

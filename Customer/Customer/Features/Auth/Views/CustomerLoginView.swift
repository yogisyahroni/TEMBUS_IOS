import SwiftUI
import GoogleSignInSwift

struct CustomerLoginView: View {
    @EnvironmentObject private var authViewModel: CustomerAuthViewModel

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
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 8)

                    if let error = authViewModel.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption).foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                    }

                    if authViewModel.isLoading {
                        ProgressView().tint(Color("CustomerPrimary"))
                            .padding()
                    } else {
                        GoogleSignInButton(scheme: .light, style: .wide, state: .normal) {
                            Task {
                                await authViewModel.loginWithGoogle()
                            }
                        }
                        .frame(height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Text("Dengan masuk, Anda menyetujui Syarat dan Ketentuan layanan.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(24)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.15), radius: 20, y: -5)
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $authViewModel.isOTPRequired) {
            CustomerOTPView()
                .environmentObject(authViewModel)
                // Disable interactive dismiss so they must verify or cancel properly
                .interactiveDismissDisabled()
        }
    }
}

#Preview {
    CustomerLoginView()
        .environmentObject(CustomerAuthViewModel())
}

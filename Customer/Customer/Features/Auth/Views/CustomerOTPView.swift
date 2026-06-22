import SwiftUI

struct CustomerOTPView: View {
    @EnvironmentObject private var authViewModel: CustomerAuthViewModel
    @State private var otpCode: String = ""
    @FocusState private var isKeyboardShowing: Bool

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color("CustomerPrimary"))
                .padding(.top, 40)

            VStack(spacing: 8) {
                Text("Verifikasi Keamanan")
                    .font(.title2.bold())
                Text("Masukkan kode OTP yang dikirimkan ke nomor WhatsApp / SMS Anda.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // OTP Input
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    OTPTextBox(index: index, text: $otpCode)
                }
            }
            .padding(.top, 16)
            .background(
                TextField("", text: $otpCode)
                    .keyboardType(.numberPad)
                    .focused($isKeyboardShowing)
                    .opacity(0)
                    .onChange(of: otpCode) { newValue in
                        if newValue.count > 6 {
                            otpCode = String(newValue.prefix(6))
                        }
                    }
            )
            .onTapGesture {
                isKeyboardShowing = true
            }

            if let error = authViewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
            }

            Button {
                Task {
                    await authViewModel.verifyOTP(code: otpCode)
                }
            } label: {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Verifikasi").font(.body.bold())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("CustomerPrimary"))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(authViewModel.isLoading || otpCode.count < 6)
            .opacity((otpCode.count < 6) ? 0.6 : 1)
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Button("Kirim Ulang OTP") {
                Task {
                    await authViewModel.resendOTP()
                }
            }
            .font(.footnote.bold())
            .foregroundStyle(Color("CustomerPrimary"))
            .padding(.top, 8)
            .disabled(authViewModel.isLoading)

            Spacer()
        }
        .onAppear {
            isKeyboardShowing = true
        }
    }
}

struct OTPTextBox: View {
    let index: Int
    @Binding var text: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color("CustomerPrimary") : Color.gray.opacity(0.3), lineWidth: 2)
                .frame(width: 48, height: 56)
                .background(Color(.secondarySystemBackground).cornerRadius(12))

            if index < text.count {
                let charIndex = text.index(text.startIndex, offsetBy: index)
                Text(String(text[charIndex]))
                    .font(.title2.bold())
            }
        }
    }

    private var isFocused: Bool {
        text.count == index || (text.count == 6 && index == 5)
    }
}

#Preview {
    CustomerOTPView()
        .environmentObject(CustomerAuthViewModel())
}

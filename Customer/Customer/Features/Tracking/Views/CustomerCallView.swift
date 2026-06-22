import SwiftUI

struct CustomerCallView: View {
    let orderId: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color("PrimaryDark")
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Caller Info
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Text("Kurir (Order #\(orderId.prefix(6)))")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    
                    Text("Panggilan Berlangsung...")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Spacer()
                
                // End Call
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "phone.down.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .padding(.bottom, 60)
            }
        }
    }
}

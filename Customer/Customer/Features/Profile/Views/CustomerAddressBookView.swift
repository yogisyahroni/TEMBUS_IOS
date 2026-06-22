import SwiftUI

struct CustomerAddressBookView: View {
    @State private var addresses: [SavedAddress] = [
        SavedAddress(id: "1", label: "Rumah", detail: "Jl. Merdeka No. 10, Jakarta Pusat", icon: "house.fill"),
        SavedAddress(id: "2", label: "Kantor", detail: "Gedung Cyber, Jl. Sudirman", icon: "building.2.fill")
    ]
    
    var body: some View {
        List {
            ForEach(addresses) { address in
                HStack(spacing: 16) {
                    Image(systemName: address.icon)
                        .foregroundStyle(Color("CustomerPrimary"))
                        .font(.title3)
                        .frame(width: 40, height: 40)
                        .background(Color("CustomerPrimary").opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(address.label)
                            .font(.headline)
                        Text(address.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: deleteAddress)
        }
        .navigationTitle("Buku Alamat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Tambah alamat baru
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private func deleteAddress(at offsets: IndexSet) {
        addresses.remove(atOffsets: offsets)
    }
}

struct SavedAddress: Identifiable {
    let id: String
    let label: String
    let detail: String
    let icon: String
}

#Preview {
    NavigationStack {
        CustomerAddressBookView()
    }
}

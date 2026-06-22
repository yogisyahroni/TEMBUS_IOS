# TEMBUS iOS

Repository iOS untuk aplikasi **TEMBUS** — platform pengiriman yang menghubungkan kurir dan pelanggan.

## Struktur Project

```
TEMBUS_IOS/
├── Courier/                     ← App iOS untuk Kurir (id.tembus.courier)
│   ├── Courier.xcodeproj/
│   └── Courier/
│       ├── App/                 ← Entry point, RootView, MainTabView
│       ├── Core/
│       │   ├── Network/         ← APIClient, APIConfig, Models
│       │   └── Storage/         ← TokenStorage (Keychain)
│       ├── Features/
│       │   ├── Auth/            ← Login
│       │   ├── Home/            ← Dashboard, duty toggle
│       │   ├── Orders/          ← List & Detail order
│       │   ├── Inbox/           ← Notifikasi in-app
│       │   └── Profile/         ← Profil & logout
│       └── Resources/           ← Assets, Info.plist
│
└── Customer/                    ← App iOS untuk Pelanggan (id.tembus.customer)
    ├── Customer.xcodeproj/
    └── Customer/
        ├── App/                 ← Entry point, CustomerRootView, MainTabView
        ├── Core/
        │   ├── Network/         ← CustomerModels, API config
        │   └── Storage/         ← CustomerTokenStorage (Keychain)
        ├── Features/
        │   ├── Auth/            ← Login
        │   ├── Orders/          ← Pesan kirim, riwayat
        │   ├── Tracking/        ← Lacak paket
        │   └── Profile/         ← Profil & logout
        └── Resources/           ← Assets, Info.plist
```

## CI/CD — GitHub Actions

| App      | Trigger                         | Action                          |
|----------|---------------------------------|---------------------------------|
| Courier  | Push ke `Courier/**`            | Build simulator → TestFlight    |
| Customer | Push ke `Customer/**`           | Build simulator → TestFlight    |

> **Path filter**: perubahan di `Courier/` **tidak** akan memicu build `Customer/` dan sebaliknya.

## Requirements

- Xcode 15.4+
- iOS 17.0+ deployment target
- Swift 5.9+

## GitHub Secrets yang Dibutuhkan

### Shared
| Secret | Deskripsi |
|---|---|
| `APPLE_TEAM_ID` | Apple Developer Team ID |
| `KEYCHAIN_PASSWORD` | Password keychain sementara CI |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID dari App Store Connect |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID dari App Store Connect |
| `APP_STORE_CONNECT_API_KEY_BASE64` | File `.p8` di-encode base64 |

### Courier App
| Secret | Deskripsi |
|---|---|
| `COURIER_CERTIFICATE_BASE64` | Signing certificate `.p12` base64 |
| `COURIER_P12_PASSWORD` | Password file `.p12` |
| `COURIER_PROVISIONING_PROFILE_BASE64` | Provisioning profile base64 |

### Customer App
| Secret | Deskripsi |
|---|---|
| `CUSTOMER_CERTIFICATE_BASE64` | Signing certificate `.p12` base64 |
| `CUSTOMER_P12_PASSWORD` | Password file `.p12` |
| `CUSTOMER_PROVISIONING_PROFILE_BASE64` | Provisioning profile base64 |

## Bundle Identifiers

| App      | Bundle ID           |
|----------|---------------------|
| Courier  | `id.tembus.courier` |
| Customer | `id.tembus.customer`|

## Setup Local Development

```bash
# Clone repo
git clone https://github.com/yogisyahroni/TEMBUS_IOS.git

# Buka Courier app
open Courier/Courier.xcodeproj

# Buka Customer app
open Customer/Customer.xcodeproj
```

> **Catatan:** Set `DEVELOPMENT_TEAM` di Build Settings dengan Apple Developer Team ID kamu sebelum build ke device.

## Menginstal Dependensi Swift Package Manager (SPM)

Aplikasi Courier menggunakan *3rd-party SDK* berikut yang harus di-*resolve* via Xcode:
- `Socket.IO-Client-Swift` (Real-time events).
- `StreamWebRTC` (Audio Calling).
- `TomTomSDK` (Maps & Routing).
- `GoogleMLKit/FaceDetection` (Vision Liveness).

**Cara Instalasi:**
1. Buka `Courier/Courier.xcodeproj` menggunakan Xcode.
2. Pada menu bar, pilih **File** > **Add Package Dependencies...**
3. Masukkan URL package berikut:
   - `https://github.com/socketio/socket.io-client-swift`
   - `https://github.com/tomtom-international/tomtom-sdk-spm-ios.git`
- Module: `TomTomSDKMapDisplay`, `TomTomSDKRouting`

### Google Sign-In SDK (Khusus Aplikasi Customer)
- **URL**: `https://github.com/google/GoogleSignIn-iOS.git`
- **Dependency Rule**: Up to Next Major Version (7.0.0 atau terbaru)
- **Modules**:
  - `GoogleSignIn`
  - `GoogleSignInSwift`

---

## 3. Menjalankan Aplikasi
4. Klik **Add Package** dan pastikan semua library terpasang di *Target Courier*.

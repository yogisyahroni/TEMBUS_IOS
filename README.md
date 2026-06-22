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

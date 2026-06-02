# PayWalletLite 🏦
**Secure Mobile & Offline Payments — by Paylogic**

## ✅ Run in 3 commands

```bash
cd paywallet_lite
flutter pub get
flutter run
```

Works on Android emulator, iOS simulator, and Chrome (`flutter run -d chrome`).

---

## 🔑 Demo credentials

| Field     | Value              |
|-----------|--------------------|
| Phone     | +221 77 123 4567   |
| Password  | Demo1234!          |
| **PIN**   | **1 2 3 4 5 6**   |

Or tap the **biometric button** to skip PIN.

---

## 📱 App flow

```
Splash (animated logo)
  → Language selection  🇬🇧 English / 🇫🇷 Français
    → Sign in  (or Sign up)
      → PIN  (1 2 3 4 5 6)
        → Home
            ├─ [Home tab]     Balance card, quick actions, transactions
            ├─ [Wallet tab]   Token list + Security settings
            ├─ [Scan tab]     QR scanner viewfinder → Receive flow
            └─ [More tab]     Transfer, History, Sync, Settings
```

---

## 🗺 Screen map

| Screen | Route |
|--------|-------|
| Splash | `/` |
| Language | `/language` |
| Sign in | `/login` |
| Sign up | `/register` |
| PIN | `/pin` |
| Home (tabs) | `/home` |
| Send money | `/transfer` |
| NFC wait | `/nfc-wait` |
| BLE wait | `/ble-wait` |
| Confirm transfer | `/confirm` |
| Transfer success | `/success` |
| QR scanner | `/scan` |
| Receive wait | `/rx-wait` |
| Receive confirm | `/rx-confirm` |
| Transaction history | `/history` |
| Transaction detail | `/tx-detail` |
| Settings | `/settings` |
| Sync status | `/sync` |

---

## 🎨 Brand colors (from logo)

| Token | Hex | Usage |
|-------|-----|-------|
| Teal | `#1BA8C8` | Primary actions, wallet gradient |
| Gold | `#F5A623` | Accent, clasp, continue button |
| Navy | `#1A3A5C` | Headings, gradient start |

---

## 📦 Only 1 external dependency

`go_router` for navigation. No state management library, no build_runner, no codegen.
`flutter pub get` takes ~10 seconds.


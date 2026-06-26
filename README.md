# Fuel Credit Merchant App

Flutter mobile app for fuel station merchants — login, sell fuel via QR/purchase ID, manage branches and sellers, view transactions, and request settlements.

**Production API:** `https://fuel-lending-app.onrender.com/api/v1`

## Install on Android

Release APK:

```
build/app/outputs/flutter-apk/app-release.apk
```

### Sideload

1. Copy `app-release.apk` to your phone.
2. Open the file and install (allow unknown sources if prompted).
3. Open **Fuel Credit Merchant**.

### USB install

```bash
flutter install --release
```

## Install on iPhone

```bash
cd ios && pod install && cd ..
flutter run --release
```

## Run in development

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://fuel-lending-app.onrender.com/api/v1
```

## Build release APK

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://fuel-lending-app.onrender.com/api/v1
```

## Test flow

1. **Login** with merchant admin or seller credentials.
2. **Sell fuel** — generate QR or accept purchase ID from customer.
3. **View transactions** on the dashboard.
4. **Manage** branches and invite sellers (admin).
5. **Request settlement** for collected sales.

# API Integration Guide

## 1) Configure Base URL

Set API base URL at build time:

```bash
flutter run --dart-define=API_BASE_URL=https://your-api-host.com
```

Fallback is `https://api.example.com` in `api_config.dart`.

## 2) Implemented Layers

- `ApiClient` (`GET`/`POST`) with `ApiResult<T>` and typed `ApiError`.
- Auth bearer token interceptor via `TokenStorage` (`shared_preferences`).
- Feature repositories:
  - `AuthRepository`
  - `DashboardRepository`
  - `FuelSaleRepository`
  - `SettlementRepository`

## 3) Endpoints Map

See `api_endpoints.dart`.

Current expected contracts:
- `POST /v1/auth/login` -> `{ accessToken, merchantName }`
- `POST /v1/fuel-sales/qr` -> `{ qrCode, reference }`
- `POST /v1/fuel-sales` -> `{ transactionId, status }`
- `POST /v1/settlements/request` -> `{ referenceId, status }`

## 4) Wired UI Flows

- Login screen calls `AuthRepository.login`.
- Fuel Sale page calls QR generation and payment creation.
- Settlement payout modal calls settlement request API.

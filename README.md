<div align="center">

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=32&duration=3000&pause=1000&color=0E7C86&center=true&vCenter=true&width=600&lines=PALMS+%E2%80%93+Parallel+Assembly+Line;Management+System;Built+with+Flutter+%2B+Spring+Boot" alt="Typing SVG" />

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows%20%7C%20Web-0E7C86?style=for-the-badge)](#)
[![License](https://img.shields.io/badge/License-Proprietary-23282D?style=for-the-badge)](#)

**A real-time factory floor MES app for garment manufacturing — built for supervisors, operators, and management on one screen.**

</div>

---

## What is PALMS?

**PALMS** (Parallel Assembly Line Management System) is the mobile/desktop client for a full Manufacturing Execution System built for garment factories. It replaces paper tracking sheets and spreadsheets on the shop floor with live, role-aware screens for production entry, attendance, stock, and AI-generated management reports.

This repository is the **Flutter frontend** — a single codebase shipping to Android, Windows desktop, and Web.

## Highlights

- 🏭 **Role-differentiated dashboards** — Factory Managers, HR Managers, IE Analysts, Production Supervisors, and Operators each see only what's relevant to their job.
- ⚡ **Zero data-entry for Operators** — Supervisors log all production centrally; operators just see their own numbers.
- 📊 **Live operations suite** — Operator allocation, station attendance status, 4-tier stock availability, daily stock position, and WIP/bundle tracking, all in real time.
- 🤖 **AI-generated reports** — One tap generates a full, board-ready PDF report (Production, Stock, Attendance, or Worker Performance) narrated by Claude from real, aggregated factory data — never fabricated numbers.
- 🎨 **Steel & Teal design system** — a clean, professional visual language (Fraunces + Manrope, light-grey canvas, teal accent) built for factory-floor legibility, not just aesthetics.
- 🔐 **Activity-based access control** — every screen and action is gated server-side by role, not just hidden in the UI.

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State | Native `StatefulWidget` + service-layer singletons |
| Networking | `http` package against a Spring Boot REST API |
| Auth | JWT bearer tokens, persisted via `shared_preferences` |
| PDF Viewing | `printing` package |
| Fonts | Google Fonts — Fraunces (display), Manrope (body) |
| Targets | Android, Windows Desktop, Web |

## Project Structure

```
lib/
├── activities/        # Screens, grouped by feature (operations/, reports/, ...)
├── components/        # Reusable UI (toasts, dialogs, cards)
├── models/            # Typed API response models
├── services/          # API clients (one per backend domain)
└── utils/             # Theme tokens, formatting helpers, API config
```

## Getting Started

```bash
flutter pub get
flutter run -d <device-id>
```

Point the app at your backend by editing:

```dart
// lib/utils/api_config.dart
static const String baseUrl = "http://<your-backend-host>:8080";
```

## Related

- **Backend** — [MES-Backend](https://github.com/PremSaiBollamoni/MES-Backend) (Spring Boot 3 + MySQL, Flyway-managed schema, Claude-powered reporting engine)

---

<div align="center">

Built by **Prem Sai** — a production factory-floor system, not a demo.

</div>

# CareGo Healthcare Platform

> **Care + Go** — Indonesian on-demand healthcare services platform.  
> Garuda Hacks Hackathon Entry.

---

## 🏗️ Architecture

```
carego-garuda_hacks/
├── backend/            → Encore.ts microservice backend (TypeScript)
├── flutter-app/        → Flutter mobile app (Dart, Android)
├── frontend/           → Public landing page (Vite + React)
├── admin-frontend/     → Admin dashboard (Vite + React)
└── docs/               → Shared documentation & API contracts
```

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Encore.ts (TypeScript), PostgreSQL 15 |
| Mobile | Flutter SDK ≥3.0 (Dart), Android |
| Web Frontend | Vite + React 19 + TailwindCSS 4 |
| Admin Dashboard | Vite + React 19 + TailwindCSS 4 |
| OTP Delivery | WAHA (WhatsApp HTTP API, Docker) |
| Auth | bcryptjs + custom session tokens |

## 🚀 Quick Start

### Prerequisites

| Software | Version |
|----------|---------|
| Node.js | v20+ |
| Bun | v1.0+ |
| Encore CLI | v1.54+ |
| Flutter SDK | ≥3.0 <4.0 |
| Android Studio | Latest |
| Docker Desktop | Latest |
| Git | Latest |

### Run Locally

```bash
# Clone
git clone https://github.com/Shiki-12/carego-garuda_hacks.git
cd carego-garuda_hacks

# Backend (Terminal 1)
cd backend && npm install && encore run

# Frontend Web (Terminal 2)
cd frontend && bun install && bun run dev

# Admin Dashboard (Terminal 3)
cd admin-frontend && bun install && bun run dev --port 5174

# Flutter App (Terminal 4 — with device/emulator connected)
cd flutter-app && flutter pub get && flutter run
```

## 👥 Development Workflow

This project uses a **distributed development model** — two developers working on separate machines, coordinating via GitHub.

### Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Stable, deployable code (merged PRs only) |
| `develop` | Integration branch |
| `feature/backend-*` | Backend features (Dev A) |
| `feature/flutter-*` | Flutter features (Dev B) |
| `feature/frontend-*` | Web frontend features (Dev B) |
| `fix/*` | Bug fixes (either dev) |

### Commit Convention

```
Backend: Add caregiver listing endpoint
Flutter: Build ambulance booking screen
Frontend: Update hero section
Admin: Add recommendation CRUD
Fix: Resolve OTP expiry bug
docs: Update API contract
chore: Update dependencies
```

### Before Starting Work

```bash
git checkout develop
git pull origin develop
```

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [API Contract](docs/API_CONTRACT.md) | Single source of truth for all backend endpoints |
| [Migration Log](docs/MIGRATION_LOG.md) | Database migration history |
| [Ownership](docs/OWNERSHIP.md) | Module ownership per developer |
| [Workflow](docs/WORKFLOW.md) | Git workflow and conflict prevention |

## 📄 License

This project is developed for the Garuda Hacks hackathon.

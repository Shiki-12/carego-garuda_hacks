# Milestone 1 — Backend Foundation & Auth Service

## Current State Assessment

> [!IMPORTANT]
> **Critical Discovery:** The documentation describes many features as "✅ Complete" (auth, user, ambulance, admin services, full Flutter app), but the **actual codebase tells a very different story.** The repository contains:
> - Only **placeholder `.gitkeep` files** in every backend service directory (auth, user, ambulance, admin, caregiver, rental, app)
> - **No actual service code** exists — no `encore.service.ts`, no `api.ts` files in any service
> - Only **5 of 8** documented migrations exist (missing migrations 6, 7, 8)
> - The Flutter app contains only a `README.md` — **no Dart source code**
> - The `develop` branch has staged/uncommitted scaffold files but no real implementation
> - A single commit `76944d3` on `main` ("first commit") — essentially a fresh repo

The documentation reflects a **prior implementation** that either existed in a different repository or was lost. We are effectively starting from **Phase 1 of implementation** despite having comprehensive documentation.

---

## Objective

Scaffold the Encore.ts backend infrastructure and implement the **Auth Service** — the foundational dependency for every other feature. This includes:

1. Commit existing staged migrations and DB config to `develop`
2. Add missing migrations (6, 7, 8)
3. Scaffold all 7 backend services with `encore.service.ts` files
4. Fully implement the Auth service (`api.ts`) with all 9 endpoints
5. Implement the App service (`api.ts`) — simple, no dependencies

---

## Prerequisites

| Prerequisite | Status |
|---|---|
| Repository exists with `develop` branch | ✅ |
| `docs-Main/` is complete (SSOT) | ✅ |
| Database schema documented in SRS-11 | ✅ |
| API contract documented in `endpoints.md` | ✅ |
| Encore.ts + bcryptjs dependencies in `package.json` | ✅ |
| `db/db.ts` exists with SQLDatabase config | ✅ (untracked) |
| Migrations 1-5 exist | ✅ (untracked) |
| Node.js, Encore CLI installed | ⚠️ Required on dev machines |

---

## Scope

### In Scope
- Commit all existing untracked backend files
- Create missing migrations 6, 7, 8 (photo_url, demo users, fix passwords)
- Scaffold `encore.service.ts` for all 7 services
- Full Auth service: register, login, OTP, Google OAuth, session management
- App service: version check endpoint
- WAHA config for WhatsApp OTP

### Out of Scope
- User service (Milestone 2)
- Ambulance service (Milestone 2)
- Admin service (Milestone 2)
- Flutter app (Milestone 3+)
- Caregiver/Rental services (future milestones)

---

## Developer Assignment

### Developer A — Backend Services & Database
**Responsibility:** All backend infrastructure, database, service scaffolding, auth service

| Task | Files | Priority |
|---|---|---|
| Commit existing untracked files to `develop` | `backend/db/*`, `backend/*.json`, etc. | P0 |
| Create migration `6_add_photo_url.up.sql` | `backend/db/migrations/` | P0 |
| Create migration `7_add_demo_users.up.sql` | `backend/db/migrations/` | P0 |
| Create migration `8_fix_demo_passwords.up.sql` | `backend/db/migrations/` | P0 |
| Scaffold `encore.service.ts` for all 7 services | 7 files across 7 dirs | P0 |
| Create `backend/auth/config.ts` (WAHA secrets) | `backend/auth/config.ts` | P0 |
| Implement `backend/auth/api.ts` (9 endpoints) | `backend/auth/api.ts` | P0 |
| Implement `backend/app/api.ts` (1 endpoint) | `backend/app/api.ts` | P1 |

### Developer B — Flutter App Scaffolding
**Responsibility:** Flutter project initialization and core structure

| Task | Files | Priority |
|---|---|---|
| Run `flutter create` or scaffold `pubspec.yaml` | `flutter-app/` | P0 |
| Create `lib/models/models.dart` | Data classes | P0 |
| Create `lib/services/api_service.dart` (auth methods only) | API client | P0 |
| Create `lib/main.dart` with AuthGate skeleton | Entry point | P1 |

### Why This Division
- **Zero file overlap** — Dev A works only in `backend/`, Dev B works only in `flutter-app/`
- Auth service is the **critical path** — nothing else can work without it
- Flutter scaffolding can happen in parallel with backend auth
- Dev B can start wiring API client methods against the documented contract while Dev A builds the endpoints

---

## Git Strategy

### Branch Structure
```
main (protected, production)
└── develop (integration)
    ├── feature/backend-auth-service     ← Dev A
    └── feature/flutter-scaffold         ← Dev B
```

### Step-by-Step Git Workflow

**Dev A (Backend Auth):**
```bash
git checkout develop
git pull origin develop
git checkout -b feature/backend-auth-service

# ... implement all backend work ...

git add -A
git commit -m "Backend: Scaffold all services and implement auth"
git push origin feature/backend-auth-service

# Create PR → develop (or direct merge if no review required)
git checkout develop
git merge feature/backend-auth-service
git push origin develop
```

**Dev B (Flutter Scaffold):**
```bash
git checkout develop
git pull origin develop
git checkout -b feature/flutter-scaffold

# ... scaffold Flutter app ...

git add -A
git commit -m "Flutter: Scaffold app structure with auth API client"
git push origin feature/flutter-scaffold

# Wait for Dev A to merge first, then:
git checkout develop
git pull origin develop
git merge feature/flutter-scaffold
git push origin develop
```

### Merge Order
1. **Dev A merges first** (backend is the dependency)
2. **Dev B merges second** (Flutter depends on backend contract being established)

### Conflict Prevention
- Dev A only touches `backend/` files
- Dev B only touches `flutter-app/` files
- **Zero overlap** = zero merge conflicts

---

## Implementation

### Phase 1: Missing Migrations (Dev A)

> [!NOTE]
> Migrations 1-5 already exist. We need to create 6, 7, 8 per the documented schema.

---

#### [NEW] `backend/db/migrations/6_add_photo_url.up.sql`

```sql
-- Add photo_url column to users for profile photos (stored as Base64)
ALTER TABLE users ADD COLUMN IF NOT EXISTS photo_url TEXT;
```

---

#### [NEW] `backend/db/migrations/7_add_demo_users.up.sql`

```sql
-- Seed 10 demo patient accounts with Rp 1,000,000 wallets
-- Password for all: password123
-- Bcrypt hash of 'password123' with 10 rounds

INSERT INTO users (name, email, password_hash, role) VALUES
('Demo User 1', 'demo1@carego.id', '$2b$10$rN95H2si4SrS6RgiafGXduEuBmzktWtjQu.KZP5.8u7yg8KQ2bYbG', 'patient'),
('Demo User 2', 'demo2@carego.id', '$2b$10$rN95H2si4SrS6RgiafGXduEuBmzktWtjQu.KZP5.8u7yg8KQ2bYbG', 'patient'),
('Demo User 3', 'demo3@carego.id', '$2b$10$rN95H2si4SrS6RgiafGXduEuBmzktWtjQu.KZP5.8u7yg8KQ2bYbG', 'patient'),
('Demo User 4', 'demo4@carego.id', '$2b$10$rN95H2si4SrS6RgiafGXduEuBmzktWtjQu.KZP5.8u7yg8KQ2bYbG', 'patient'),
('Demo User 5', 'demo5@carego.id', '$2b$10$rN95H2si4SrS6RgiafGXduEuBmzktWtjQu.KZP5.8u7yg8KQ2bYbG', 'patient'),
('Demo User 6', 'demo6@carego.id', '$2b$10$rN95H2si4SrS6RgiafGXduEuBmzktWtjQu.KZP5.8u7yg8KQ2bYbG', 'patient'),
('Demo User 7', 'demo7@carego.id', '$2b$10$rN95H2si4SrS6RgiafGXduEuBmzktWtjQu.KZP5.8u7yg8KQ2bYbG', 'patient'),
('Demo User 8', 'demo8@carego.id', '$2b$10$rN95H2si4SrS6RgiafGXduEuBmzktWtjQu.KZP5.8u7yg8KQ2bYbG', 'patient'),
('Demo User 9', 'demo9@carego.id', '$2b$10$rN95H2si4SrS6RgiafGXduEuBmzktWtjQu.KZP5.8u7yg8KQ2bYbG', 'patient'),
('Demo User 10', 'demo10@carego.id', '$2b$10$rN95H2si4SrS6RgiafGXduEuBmzktWtjQu.KZP5.8u7yg8KQ2bYbG', 'patient')
ON CONFLICT (email) DO NOTHING;

-- Create wallets for demo users with Rp 1,000,000 each
INSERT INTO wallets (user_id, balance)
SELECT id, 1000000 FROM users WHERE email LIKE 'demo%@carego.id'
ON CONFLICT (user_id) DO NOTHING;
```

---

#### [NEW] `backend/db/migrations/8_fix_demo_passwords.up.sql`

```sql
-- Fix demo user passwords to proper bcrypt hash of 'password123'
-- This hash was generated with bcryptjs: bcrypt.hashSync('password123', 10)
UPDATE users SET password_hash = '$2b$10$rN95H2si4SrS6RgiafGXduEuBmzktWtjQu.KZP5.8u7yg8KQ2bYbG'
WHERE email LIKE 'demo%@carego.id';

-- Also fix the original patient password
UPDATE users SET password_hash = '$2b$10$rN95H2si4SrS6RgiafGXduEuBmzktWtjQu.KZP5.8u7yg8KQ2bYbG'
WHERE email = 'patient@carego.id';
```

---

### Phase 2: Service Scaffolding (Dev A)

Every Encore.ts service needs an `encore.service.ts` registration file.

#### [NEW] Service Registration Files (7 files)

| Service | File Path |
|---|---|
| auth | `backend/auth/encore.service.ts` |
| user | `backend/user/encore.service.ts` |
| ambulance | `backend/ambulance/encore.service.ts` |
| admin | `backend/admin/encore.service.ts` |
| caregiver | `backend/caregiver/encore.service.ts` |
| rental | `backend/rental/encore.service.ts` |
| app | `backend/app/encore.service.ts` |

Each follows the same pattern:
```typescript
import { Service } from "encore.dev/service";
export default new Service("service_name");
```

---

### Phase 3: Auth Service Implementation (Dev A)

#### [NEW] `backend/auth/config.ts`

WAHA secrets configuration for WhatsApp OTP delivery.

#### [NEW] `backend/auth/api.ts`

Full implementation of all 9 auth endpoints per [SRS-01](file:///c:/Coding/carego-garuda_hacks/docs-Main/srs/SRS_01_Authentication.md) and [endpoints.md](file:///c:/Coding/carego-garuda_hacks/docs-Main/api/endpoints.md):

| # | Endpoint | Method | Description |
|---|---|---|---|
| 1 | `/auth/register` | POST | Direct registration (no OTP) |
| 2 | `/auth/register-send-otp` | POST | Send OTP for registration |
| 3 | `/auth/register-verify-otp` | POST | Verify OTP + create account |
| 4 | `/auth/login` | POST | Email/password login |
| 5 | `/auth/send-otp` | POST | Send OTP for login |
| 6 | `/auth/verify-otp` | POST | Verify OTP + login |
| 7 | `/auth/google` | POST | Google OAuth login/register |
| 8 | `/auth/me` | POST | Validate session token |
| 9 | `/auth/logout` | POST | Invalidate session |

**Key implementation details:**
- Passwords hashed with `bcryptjs` (10 rounds)
- Session tokens: 64 random hex characters
- Sessions expire after 7 days
- OTP codes: 6 digits, expire after 5 minutes
- WAHA integration for WhatsApp OTP (with fallback to console.log)
- Activity logging for all auth events
- All error messages in Bahasa Indonesia

---

### Phase 4: App Service Implementation (Dev A)

#### [NEW] `backend/app/api.ts`

Single endpoint `GET /app/version` returning static version info.

---

### Phase 5: Flutter Scaffold (Dev B)

#### [NEW] Flutter project files

Dev B initializes the Flutter project and creates:

| File | Purpose |
|---|---|
| `flutter-app/pubspec.yaml` | Dependencies declaration |
| `flutter-app/lib/main.dart` | Entry point with AuthGate |
| `flutter-app/lib/models/models.dart` | User, Recommendation data classes |
| `flutter-app/lib/services/api_service.dart` | HTTP client (auth endpoints only) |

---

## Verification Plan

### Automated Tests
```bash
# Backend compilation check
cd backend && npx tsc --noEmit

# Encore local run (tests migrations + service registration)
cd backend && encore run
```

### Manual Verification
1. Start backend with `encore run`
2. Verify all 8 migrations run successfully
3. Test auth endpoints via Encore dev dashboard (http://localhost:9400):
   - `POST /auth/register` with test credentials
   - `POST /auth/login` with seeded admin/patient accounts
   - `POST /auth/me` with returned token
   - `POST /auth/logout` with token
4. Verify `GET /app/version` returns expected JSON
5. Check activity_logs table has entries for auth events

---

## Open Questions

> [!IMPORTANT]
> **Q1:** The bcrypt hash `$2b$10$rN95H2si4SrS6RgiafGXduEuBmzktWtjQu.KZP5.8u7yg8KQ2bYbG` in migrations 5/7 — is this the correct hash for `password123`? The documentation says migration 8 was created specifically to "fix demo passwords," implying the hash in migration 7 might have been wrong. Should I generate a fresh bcrypt hash for `password123` to use in migrations 7 and 8?

> [!IMPORTANT]
> **Q2:** The WAHA secret (`wahaApiKey`) — the docs mention `backend/encore-local.secrets.json` but this file doesn't exist in the repo. Should the auth service fall back to console.log when WAHA is unavailable (as documented), or should we skip WAHA integration entirely for now?

> [!WARNING]
> **Q3:** The documentation states migrations 6, 7, 8 exist, but only 5 are present on disk. The hashes in migration 7 (`$2b$10$rN95H2...`) came from migration 5 (`patient2` seeding). Shall I proceed with creating these 3 missing migrations using the documented specifications, or is there concern they were removed intentionally?

---

## Milestone Report (Preview)

| Metric | Target |
|---|---|
| **Files to Create** | ~15 new files |
| **Files to Modify** | 0 existing files |
| **Migrations Added** | 3 (migrations 6, 7, 8) |
| **Backend Services Scaffolded** | 7 |
| **Auth Endpoints Implemented** | 9 |
| **App Endpoints Implemented** | 1 |
| **Flutter Files Created** | 4 (scaffold only) |
| **Database Tables Affected** | users (add column), wallets (seed data) |
| **Merge Conflicts Expected** | 0 |

---

## Handoff Summary (Preview)

| Field | Value |
|---|---|
| **Project Status** | 🟡 Implementation Starting |
| **Current Milestone** | M1: Backend Foundation & Auth Service |
| **Completed Milestones** | M0: Planning & Documentation ✅ |
| **Next Milestone** | M2: User, Ambulance, Admin Backend Services |
| **Developer A Status** | Assigned: Backend auth service + scaffolding |
| **Developer B Status** | Assigned: Flutter project scaffold |
| **Current Branches** | `develop` (active), `main` (protected) |
| **Pending Merge** | None yet |
| **Blocking Issues** | Need bcrypt hash verification (Q1) |
| **Estimated Progress** | 5% (planning done, implementation starting) |

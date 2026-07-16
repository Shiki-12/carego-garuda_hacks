# Backend — Encore.ts Microservice API

> **Owner: Dev A**  
> This entire directory is owned by the backend developer.

## Setup

```bash
cd backend
npm install
encore run
```

## Structure (to be scaffolded)

```
backend/
├── encore.app              # Encore app config
├── package.json            # Node dependencies
├── tsconfig.json           # TypeScript config (strict, ES2022)
├── docker-compose.yml      # Local dev: Postgres + WAHA
├── db/
│   ├── db.ts               # SQLDatabase("carego") instance
│   └── migrations/         # Sequential SQL migrations
├── auth/                   # Auth service
├── user/                   # User service
├── ambulance/              # Ambulance service
├── admin/                  # Admin service
├── caregiver/              # Caregiver service
├── rental/                 # Rental service
└── app/                    # App version service
```

## Adding a New Service

1. Create directory: `backend/my_service/`
2. Create `encore.service.ts`:
   ```typescript
   import { Service } from "encore.dev/service";
   export default new Service("my_service");
   ```
3. Create `api.ts` with endpoints using `api()` wrapper
4. Run `encore run` to test locally
5. Update `docs/API_CONTRACT.md`
6. Regenerate `client.ts`: `encore gen client --target leap`
7. Push to feature branch → create PR

## Adding a New Migration

1. Create file: `backend/db/migrations/N_description.up.sql`
2. Update `docs/MIGRATION_LOG.md`
3. Restart `encore run` — migration runs automatically
4. **Never modify existing migration files**

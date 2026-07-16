# Migration Log — CareGo Healthcare Platform

> **Dev A is the sole author of all migrations.** Dev B must never create migration files.  
> If Dev B needs a schema change, open a GitHub Issue with label `migration-needed`.

---

## Migration Naming Convention

```
N_description.up.sql
```
- `N` = sequential number (1, 2, 3, ...)
- `description` = snake_case description of what the migration does
- `.up.sql` = Encore migration suffix

## Rules

1. **Never modify existing migration files** — only add new ones.
2. **Always pull latest `develop`** before creating a new migration to get the correct next number.
3. **Document every migration** in this log before pushing.

---

## Migration History

| # | File | Description | Tables Affected | Date | PR |
|---|------|-------------|-----------------|------|----|
| — | *No migrations yet* | — | — | — | — |

---

## Planned Schema (from prototype)

These tables will be created through migrations as features are built:

| Table | Purpose | Expected Migration Phase |
|-------|---------|------------------------|
| `users` | User accounts (patients, admins, providers) | Phase 1 (Auth) |
| `sessions` | Auth session tokens (7-day expiry) | Phase 1 (Auth) |
| `otp_codes` | One-time passwords for verification | Phase 1 (Auth) |
| `wallets` | User wallet balances (IDR) | Phase 1 (Auth) |
| `providers` | Healthcare service providers | Phase 2 (Core) |
| `bookings` | Service bookings with status tracking | Phase 2 (Core) |
| `recommendations` | Featured service cards for home screen | Phase 2 (Core) |
| `activity_logs` | Audit trail for user actions | Phase 2 (Core) |

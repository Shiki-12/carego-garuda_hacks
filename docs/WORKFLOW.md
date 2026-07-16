# Git Workflow — CareGo Healthcare Platform

> **Distributed Development Guide**  
> Two developers, separate laptops, synchronized via GitHub only.

---

## Branch Structure

```
main              ← Stable, deployable code (PR merge only)
├── develop       ← Integration branch (both devs merge here)
├── feature/backend-*     ← Dev A feature branches
├── feature/flutter-*     ← Dev B feature branches (mobile)
├── feature/frontend-*    ← Dev B feature branches (web)
├── fix/*                 ← Bug fixes (either dev)
└── hotfix/*              ← Urgent production fixes
```

---

## Daily Workflow

### Starting a Work Session

```bash
# Always start by syncing
git checkout develop
git pull origin develop

# Create your feature branch
git checkout -b feature/backend-auth    # Dev A example
git checkout -b feature/flutter-login   # Dev B example
```

### During Development

```bash
# Commit frequently with prefixed messages
git add .
git commit -m "Backend: Add login endpoint with bcrypt"

# Push your branch regularly (backup + visibility)
git push origin feature/backend-auth
```

### Finishing a Feature

```bash
# Sync develop into your branch first
git checkout feature/backend-auth
git pull origin develop
# Resolve any conflicts locally

# Push and create PR
git push origin feature/backend-auth
# Go to GitHub → Create Pull Request → base: develop
```

---

## Commit Message Convention

```
[Component]: [Description]
```

| Prefix | Used by | Example |
|--------|---------|---------|
| `Backend:` | Dev A | `Backend: Add caregiver listing endpoint` |
| `Flutter:` | Dev B | `Flutter: Build ambulance booking screen` |
| `Frontend:` | Dev B | `Frontend: Update landing page hero` |
| `Admin:` | Dev B | `Admin: Add recommendation table view` |
| `Fix:` | Either | `Fix: Resolve OTP expiry timezone issue` |
| `docs:` | Either | `docs: Update API contract for rental service` |
| `chore:` | Either | `chore: Update Flutter dependencies` |

---

## When to Pull

| Situation | Command |
|-----------|---------|
| Starting a new work session | `git checkout develop && git pull` |
| Before creating a new branch | `git checkout develop && git pull` |
| Before creating a migration | Pull + check latest migration number |
| Before editing `api_service.dart` | Pull + read latest `API_CONTRACT.md` |
| Before merging your branch | `git pull origin develop` into your branch |

---

## When to Create a PR

| Condition | Action |
|-----------|--------|
| Backend endpoint is complete + tested locally | Dev A: PR `feature/backend-*` → `develop` |
| Flutter screen is complete + tested on emulator | Dev B: PR `feature/flutter-*` → `develop` |
| Web feature is complete + builds | Dev B: PR `feature/frontend-*` → `develop` |
| Both devs agree a milestone is stable | Merge `develop` → `main` |

---

## Merge Conflict Prevention

### Golden Rules

1. **Never push directly to `main` or `develop`** — always use PRs.
2. **Never edit files in another developer's directory** (see [OWNERSHIP.md](OWNERSHIP.md)).
3. **Pull `develop` before creating a new branch.**
4. **Pull `develop` into your branch before creating a PR.**
5. **Keep commits small and focused** — one logical change per commit.

### High-Risk Conflict Files

| File | Risk | Mitigation |
|------|------|------------|
| `backend/db/migrations/*` | 🔴 Critical | Dev A exclusively |
| `docs/API_CONTRACT.md` | 🟡 Medium | Dev A writes only |
| `flutter-app/lib/services/api_service.dart` | 🟡 Medium | Dev B exclusively |
| `flutter-app/lib/main.dart` | 🟡 Medium | Coordinate nav changes |
| `.gitignore` | 🟢 Low | Append only |

---

## Feature Dependency Protocol

When Dev B needs a backend endpoint that doesn't exist yet:

1. Dev B opens a GitHub Issue with label `backend` describing the endpoint needed.
2. Dev B continues UI work using **mock data** or **hardcoded responses**.
3. Dev A picks up the issue, implements the endpoint, and updates `API_CONTRACT.md`.
4. Dev A merges their PR to `develop`.
5. Dev B pulls `develop`, reads the updated contract, and connects the real endpoint.

When Dev B needs a database schema change:

1. Dev B opens a GitHub Issue with label `migration-needed` and describes the table/column change.
2. **Dev B never creates migration files.**
3. Dev A creates the migration, documents it in `MIGRATION_LOG.md`, and merges.

---

## Release Protocol

```bash
# When ready to release
git checkout develop
git pull origin develop

# Create release PR
# GitHub: New Pull Request → base: main, compare: develop
# Title: "Release: v1.0 - [Milestone Name]"
# Both developers approve

# After merge, tag the release
git checkout main
git pull origin main
git tag v1.0
git push origin v1.0
```

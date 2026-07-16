# Admin Dashboard — CareGo

> **Owner: Dev B**  
> Internal admin panel for user management, recommendations, and activity logs.

## Setup

```bash
cd admin-frontend
bun install
bun run dev --port 5174
```

Runs on `http://localhost:5174`

## Tech Stack

- Vite + React 19
- TailwindCSS 4
- Lucide React icons
- Auto-generated Encore API client (`src/client.ts`)

## Important

- **`src/client.ts` is auto-generated** — never hand-edit it.
- Dev A regenerates it with `encore gen client --target leap` after backend changes.

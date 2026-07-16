# Frontend Web — CareGo Landing Page

> **Owner: Dev B**  
> Public-facing marketing / landing page.

## Setup

```bash
cd frontend
bun install
bun run dev
```

Runs on `http://localhost:5173`

## Tech Stack

- Vite + React 19
- TailwindCSS 4
- Lucide React icons
- Auto-generated Encore API client (`client.ts`)

## Important

- **`client.ts` is auto-generated** — never hand-edit it.
- Dev A regenerates it with `encore gen client --target leap` after backend changes.

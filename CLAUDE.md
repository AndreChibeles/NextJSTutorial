# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Next.js dashboard application following the Next.js Learn Course curriculum. It's an invoice management system (Acme) with user authentication, built with:

- **Framework**: Next.js 15+ with App Router and Turbopack
- **Language**: TypeScript
- **Database**: PostgreSQL with direct SQL queries using the `postgres` npm package (not an ORM)
- **Authentication**: NextAuth (beta 5.0)
- **UI**: React with Tailwind CSS for styling
- **Package Manager**: pnpm (see `pnpm-workspace.yaml`)

## Development Commands

```bash
# Start dev server with Turbopack (faster builds)
pnpm dev

# Build for production
pnpm build

# Start production server
pnpm start
```

The app runs on port 3000 by default. Turbopack is enabled by default for fast iteration.

## Docker & Database Setup

Docker Compose is configured with three services:
- **web**: Next.js dev server (rebuilds on file changes)
- **db**: PostgreSQL 16 (Alpine)
- **pgadmin**: Database admin UI (port 5050)

```bash
# Start all services
docker-compose up

# Connect to database
docker-compose exec db psql -U postgres -d nextjs_db
```

Use `.env.example` as reference for required environment variables (`POSTGRES_URL` must be set for the app to connect).

## Database & Data Access Layer

The app uses **raw SQL with the `postgres` npm package** (not Prisma or other ORMs). Key patterns:

### Database Connection
- File: `app/lib/data.ts`
- Connection initialized with: `postgres(process.env.POSTGRES_URL!, { ssl: 'require' })`
- All database queries are async/await with error handling (catch blocks throw user-friendly errors)

### Data Access
- Query functions exported from `app/lib/data.ts` (e.g., `fetchRevenue()`, `fetchLatestInvoices()`, etc.)
- Type definitions in `app/lib/definitions.ts`
- Helper functions in `app/lib/utils.ts` (e.g., `formatCurrency()`)
- Placeholder seed data in `app/lib/placeholder-data.ts`

### Database Initialization
- Route handler: `app/seed/route.ts`
- Creates UUID extension, tables for users/customers/invoices/revenue
- Hashes passwords with bcrypt before insertion
- Can be triggered via HTTP call or manually

### Query Response Formatting
- Raw database queries return typed data (TypeScript generics: `sql<Type[]>\`...\``)
- Data transformation often happens in memory after fetching (e.g., formatting currency)
- No client-side data fetching—all queries run server-side

## Project Structure

```
app/
├── lib/                 # Data layer & utilities
│   ├── data.ts         # Database queries & connection
│   ├── definitions.ts  # TypeScript type definitions
│   ├── utils.ts        # Helper functions (formatCurrency, etc.)
│   └── placeholder-data.ts  # Seed data
├── ui/                  # React components (organized by domain)
│   ├── dashboard/      # Dashboard widgets (charts, cards, nav)
│   ├── invoices/       # Invoice features (forms, table, pagination)
│   ├── customers/      # Customer features
│   ├── global.css      # Global styles
│   └── *.tsx           # Shared UI components (logo, buttons, search, etc.)
├── seed/               # Database initialization route
├── query/              # Database query/test route
├── layout.tsx          # Root layout (html/body wrapper)
└── page.tsx            # Home page (entry point)
```

No dashboard-specific route folder exists yet—UI components are in `app/ui/` but not wired to a `/dashboard` route at the moment.

## Key Architectural Patterns

1. **Server Components by Default**: All components are React Server Components unless marked `'use client'`
2. **Type-First Development**: TypeScript strict mode is enabled; types guide API contracts between data layer and components
3. **Error Handling**: Database errors are caught and re-thrown as user-friendly messages; no silent failures
4. **Authentication**: Uses NextAuth for session management (config may be in progress)
5. **Styling**: Tailwind CSS with `@tailwindcss/forms` plugin for form styling

## Important Notes

- The app is a learning project from the Next.js curriculum, not a production system
- Database connection requires `POSTGRES_URL` env var; Docker Compose sets this automatically
- Password hashing (bcrypt) is used in the seed route for user creation
- Debouncing utility available via `use-debounce` package for search/input optimization
- Path alias `@/*` resolves to project root for cleaner imports

## Environment Setup

Copy `.env.example` to `.env.local` and update `POSTGRES_URL` if running outside Docker:
```
POSTGRES_URL=postgresql://postgres:postgres@localhost:5432/nextjs_db
```

When using Docker Compose, env vars are injected automatically from `.env` file or `docker-compose.yml`.

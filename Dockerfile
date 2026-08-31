# Stage 1: Base
FROM node:20-alpine AS base

# Install required build tools for native modules
RUN apk add --no-cache libc6-compat python3 make g++

WORKDIR /app

# Copy package files
COPY package.json package-lock.json* pnpm-lock.yaml* ./

# Use npm to install dependencies (simpler than pnpm for Docker)
RUN npm install --production=false

# Copy Prisma schema
COPY prisma ./prisma

# Stage 2: Dev
FROM base AS dev

EXPOSE 3000

CMD ["pnpm", "dev"]

# Stage 3: Builder
FROM base AS builder

COPY . .

# Generate Prisma client
RUN pnpm prisma generate

# Build application
RUN pnpm build

# Stage 4: Runner (Production)
FROM node:20-alpine AS runner

WORKDIR /app

RUN apk add --no-cache libc6-compat

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy necessary files from builder
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/prisma ./prisma

USER nextjs

EXPOSE 3000

ENV NEXT_TELEMETRY_DISABLED=1

CMD ["node", "server.js"]

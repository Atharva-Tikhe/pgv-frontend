# Build stage
FROM node:22-slim AS build

WORKDIR /app

# Install build dependencies
COPY package*.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

# Remove development dependencies
RUN npm prune --omit=dev

# Production stage
FROM node:22-slim

WORKDIR /app

# Copy built application and production dependencies
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules

EXPOSE 3000
ENV NODE_ENV=production
ENV PORT=3000

CMD ["node", "build"]

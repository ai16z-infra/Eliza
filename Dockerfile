# Build stage
FROM node:20-slim AS builder

WORKDIR /app

# Copy only package files first for better caching
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY . .

# Build the TypeScript application
RUN npm run build

# Runtime stage
FROM node:20-slim

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install --production

COPY --from=builder /app/dist ./dist
COPY characters ./characters

ENV PORT=3000 \
    HOST=0.0.0.0 \
    NODE_ENV=production \
    CHARACTERS_PATH="characters/degenspartan.json"

# Use shell form to allow environment variable expansion
CMD node dist/index.js --characters="${CHARACTERS_PATH}"

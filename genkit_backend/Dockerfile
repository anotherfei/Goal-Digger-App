# ─────────────────────────────────────────────────────────────────────────────
# genkit_backend/Dockerfile
#
# Multi-stage build for the Goal Digger Genkit Dart backend.
# Final image is ~30MB and runs on Cloud Run (or any container host).
# ─────────────────────────────────────────────────────────────────────────────

# ── Stage 1: Build ────────────────────────────────────────────────────────────
FROM dart:3.4-sdk AS builder

WORKDIR /app

# Copy dependency manifests first (layer caching)
COPY pubspec.yaml pubspec.lock ./
RUN dart pub get

# Copy source
COPY lib/ lib/

# Compile to native executable (AOT) for fast cold starts
RUN dart compile exe lib/main.dart -o bin/server

# ── Stage 2: Runtime ──────────────────────────────────────────────────────────
FROM debian:bookworm-slim

# Install only CA certs (needed for HTTPS to Google AI APIs)
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/bin/server /app/server

# Cloud Run injects PORT; default to 3400 for local dev
ENV PORT=3400

EXPOSE $PORT

# Health check
HEALTHCHECK --interval=30s --timeout=5s CMD curl -f http://localhost:$PORT/health || exit 1

ENTRYPOINT ["/app/server"]

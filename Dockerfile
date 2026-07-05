# Obsidian Headless — container image
#
# Runs the `ob` CLI (Obsidian Sync / Publish) in a container. Intended for
# running continuous sync as a long-lived service, e.g. on a NAS or home server.
#
# Build:
#   docker build -t obsidian-headless .
#
# The image installs the published npm package by default. To build from the
# local checkout instead, pass --build-arg SOURCE=local.

# Node 22 is the minimum supported runtime (see package.json "engines").
FROM node:22-slim AS base

ARG SOURCE=npm
ARG VERSION=latest

# better-sqlite3 ships prebuilt binaries for common platforms; the slim image
# already has what it needs at runtime. No extra system packages required for
# the published package.

WORKDIR /app

# --- Install from npm (default) ---
FROM base AS build-npm
RUN npm install -g "obsidian-headless@${VERSION}" \
    && npm cache clean --force

# --- Install from the local source tree ---
FROM base AS build-local
COPY package.json pnpm-lock.yaml* ./
COPY cli.js README.md ./
COPY btime ./btime
RUN npm install --omit=dev --no-audit --no-fund \
    && npm install -g . \
    && npm cache clean --force

# --- Final image ---
FROM build-${SOURCE} AS final

# Config/credentials live under $HOME/.config/obsidian and $HOME/.local — mount
# a volume here so login and vault setup persist across container restarts.
ENV HOME=/data
RUN mkdir -p /data && chown -R node:node /data
VOLUME ["/data", "/vault"]

USER node
WORKDIR /vault

# `ob` reads/writes the current working directory as the vault by default.
# Override the command as needed, e.g.:
#   docker run ... obsidian-headless ob sync --continuous
ENTRYPOINT ["ob"]
CMD ["--help"]

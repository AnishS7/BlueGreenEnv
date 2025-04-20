#!/usr/bin/env bash
set -e

# Ensure active_version exists
[ ! -f active_version ] && echo blue > active_version
current=$(<active_version)
next=$([ "$current" = "blue" ] && echo green || echo blue)

echo "🚀 Deploying $next…"

# Remove any existing blue/green container
echo "🛑 Removing existing '$next' container if it exists"
docker rm -f "$next" 2>/dev/null || true

# Build & start the new service
echo "🔨 Building & starting '$next' service"
docker compose up -d --no-deps --build --force-recreate "$next"

# (Skip health‐check or sleep if you removed it)

# Swap Nginx config
echo "🔀 Swapping Nginx to point at '$next'"
cp nginx/"$next".conf nginx/default.conf

# **Tear down old nginx** if present
echo "🛑 Removing existing 'nginx' container if it exists"
docker rm -f nginx 2>/dev/null || true

# Bring up nginx with the new config
docker compose up -d --no-deps nginx

# Reload Nginx inside container (in case it was recreated)
docker exec nginx nginx -s reload

# Record & announce
echo "$next" > active_version
echo "🎉 Traffic is now on '$next'"

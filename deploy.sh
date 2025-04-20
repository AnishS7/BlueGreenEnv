#!/usr/bin/env bash
set -e

# Ensure active_version exists
[ ! -f active_version ] && echo blue > active_version
current=$(<active_version)
next=$([ "$current" = "blue" ] && echo green || echo blue)

echo "🚀 Deploying $next…"

# Force remove any existing container named $next
echo "🛑 Removing existing '$next' container if it exists"
docker rm -f "$next" 2>/dev/null || true

# Build & start the new service, forcing recreation
echo "🔨 Building & starting '$next' service"
docker compose up -d --no-deps --build --force-recreate "$next"

# (Optional) Wait for healthcheck
if docker inspect --format='{{.State.Health.Status}}' "$next" &>/dev/null; then
  echo "⏱️ Waiting for $next to be healthy…"
  until [ "$(docker inspect --format='{{.State.Health.Status}}' "$next")" = healthy ]; do
    echo -n .
    sleep 2
  done
  echo "✅ $next is healthy."
fi

# Swap Nginx
echo "🔀 Swapping Nginx to point at '$next'"
cp nginx/"$next".conf nginx/default.conf
docker compose up -d --no-deps nginx
docker exec nginx nginx -s reload

# Record & announce
echo "$next" > active_version
echo "🎉 Traffic is now on '$next'"

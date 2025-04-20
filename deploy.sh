#!/usr/bin/env bash
set -e

# Ensure active_version exists
[ ! -f active_version ] && echo blue > active_version
current=$(<active_version)
next=$([ "$current" = blue ] && echo green || echo blue)

echo "🚀 Deploying $next..."

# Stop & remove any existing $next container
docker compose stop $next 2>/dev/null || true
docker compose rm -f $next        2>/dev/null || true

# Build & bring up the next service
docker compose up -d --no-deps --build $next

# (Optional) Wait for healthcheck if you have one
if docker inspect --format='{{.State.Health}}' "$next" &>/dev/null; then
  echo "⏱️ Waiting for $next to pass healthcheck..."
  until [ "$(docker inspect --format='{{.State.Health.Status}}' $next)" = healthy ]; do
    echo -n .
    sleep 2
  done
  echo "✅ $next is healthy."
fi

# Swap Nginx config and reload
cp nginx/${next}.conf nginx/default.conf
docker compose up -d --no-deps nginx
docker exec nginx nginx -s reload

# Record & announce
echo $next > active_version
echo "🎉 Traffic is now on $next"

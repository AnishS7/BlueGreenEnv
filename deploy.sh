#!/bin/bash
set -e

# pick next color
[ ! -f active_version ] && echo blue > active_version
current=$(cat active_version)
next=$([ "$current" = blue ] && echo green || echo blue)

echo "🚀 Deploying $next..."
docker compose up -d --no-deps --build $next

# Wait until healthy
echo "⏱️ Waiting for $next to pass healthcheck..."
until [ "$(docker inspect --format='{{.State.Health.Status}}' bluegreenenv_${next}_1)" = healthy ]; do
  echo -n .
  sleep 2
done
echo "✅ $next is healthy."

# Swap Nginx
cp nginx/${next}.conf nginx/default.conf
docker compose up -d --no-deps nginx
docker exec nginx nginx -s reload

echo $next > active_version
echo "🎉 Traffic is now on $next"


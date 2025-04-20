#!/usr/bin/env bash
set -e

# Ensure active_version exists
if [ ! -f active_version ]; then
  echo blue > active_version
fi

current=$(cat active_version)
if [ "$current" = "blue" ]; then
  next="green"
else
  next="blue"
fi

echo "🚀 Deploying $next..."
# Build & force‐recreate the next service
docker compose up -d --no-deps --build --force-recreate $next

# Wait for health (if you’ve added HEALTHCHECKs)
echo "⏱️ Waiting for $next to pass healthcheck..."
until [ "$(docker inspect --format='{{.State.Health.Status}}' ${next})" = healthy ]; do
  echo -n .
  sleep 2
done
echo "✅ $next is healthy."

# Swap Nginx config
cp nginx/${next}.conf nginx/default.conf
docker compose up -d --no-deps nginx
docker exec nginx nginx -s reload

# Record the new active version
echo $next > active_version
echo "🎉 Traffic is now on $next"

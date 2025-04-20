#!/usr/bin/env bash
set -e

# Name of your Docker volume
VOLUME_NAME="state"
MOUNT_PATH="/data"
STATE_FILE="$MOUNT_PATH/active_version"

# 1) Ensure the state file exists (default to “blue”)
docker run --rm -v ${VOLUME_NAME}:${MOUNT_PATH} alpine sh -c "\
  if [ ! -f ${STATE_FILE} ]; then \
    echo blue > ${STATE_FILE}; \
  fi"

# 2) Read current & compute next
current=$(docker run --rm -v ${VOLUME_NAME}:${MOUNT_PATH} alpine cat "${STATE_FILE}")
next=$([ "$current" = "blue" ] && echo green || echo blue)

echo "🚀 Deploying $next…"

# 3) Recreate the next app container
echo "🛑 Removing existing '$next' container if it exists"
docker rm -f "$next" 2>/dev/null || true

echo "🔨 Building & starting '$next' service"
docker compose up -d --no-deps --build --force-recreate "$next"

# 4) Swap Nginx config & recreate nginx
echo "🔀 Swapping Nginx to point at '$next'"
cp nginx/"$next".conf nginx/default.conf

echo "🛑 Removing existing 'nginx' container if it exists"
docker rm -f nginx 2>/dev/null || true

echo "🔨 Recreating nginx with new config"
docker compose up -d --no-deps --force-recreate nginx

# 5) Write the new state back into the volume
echo "$next" | docker run --rm -i -v ${VOLUME_NAME}:${MOUNT_PATH} alpine sh -c "cat > ${STATE_FILE}"

echo "🎉 Traffic is now on '$next' (state persisted in '${VOLUME_NAME}')"

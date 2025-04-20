#!/usr/bin/env bash
set -e

# Ensure active_version exists
[ ! -f active_version ] && echo blue > active_version
current=$(<active_version)
next=$([ "$current" = "blue" ] && echo green || echo blue)

echo "🚀 Deploying $next…"

# Remove any existing $next container
echo "🛑 Removing existing '$next' container if it exists"
docker rm -f "$next" 2>/dev/null || true

# Build & start the new service
echo "🔨 Building & starting '$next' service"
docker compose up -d --no-deps --build --force-recreate "$next"

# Swap Nginx config
echo "🔀 Swapping Nginx to point at '$next'"
cp nginx/"$next".conf nginx/default.conf

# Remove old nginx container
echo "🛑 Removing existing 'nginx' container if it exists"
docker rm -f nginx 2>/dev/null || true

# Bring up nginx with the new config
echo "🔨 Building & starting 'nginx' service"
docker compose up -d --no-deps nginx

# Record & announce
echo "$next" > active_version
echo "📝 active_version is now '$next'"

# Commit & push back to Git
echo "🔨 Committing active_version to Git…"
git config user.email "jenkins@ci.local"
git config user.name  "Jenkins CI"
git add active_version
git commit -m "ci: set active_version to $next"
git push origin main

echo "🎉 Traffic is now on '$next' and active_version pushed to repo!"

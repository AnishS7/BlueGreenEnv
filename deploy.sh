#!/usr/bin/env bash
set -e

# 1) Determine next color
[ ! -f active_version ] && echo blue > active_version
current=$(<active_version)
next=$([ "$current" = "blue" ] && echo green || echo blue)

echo "🚀 Deploying $next…"

# 2) Recreate the next app container
echo "🛑 Removing existing '$next' container if it exists"
docker rm -f "$next" 2>/dev/null || true
echo "🔨 Building & starting '$next' service"
docker compose up -d --no-deps --build --force-recreate "$next"

# 3) Swap Nginx
echo "🔀 Swapping Nginx to point at '$next'"
cp nginx/"$next".conf nginx/default.conf
echo "🛑 Removing existing 'nginx' container if it exists"
docker rm -f nginx 2>/dev/null || true
echo "🔨 Recreating nginx with new config"
docker compose up -d --no-deps --force-recreate nginx

# 4) Record & announce
echo "$next" > active_version
echo "📝 active_version is now '$next'"

# 5) Commit & push back to Git
echo "🔨 Committing active_version to Git…"
git config user.email "jenkins@ci.local"
git config user.name  "Jenkins CI"
git add active_version
git commit -m "ci: set active_version to $next"
git push origin main

echo "🎉 Traffic is now on '$next' and active_version pushed to repo!"

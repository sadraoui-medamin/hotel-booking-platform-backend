# define the script content
$scriptContent = @'
#!/bin/bash

SERVICE_NAME=$1
PORT=$2

if [ -z "$SERVICE_NAME" ] || [ -z "$PORT" ]; then
    echo "Usage: ./create-service.sh <service-name> <port>"
    exit 1
fi

echo "🚀 Creating $SERVICE_NAME on port $PORT..."

cd services

# --- UPDATE: Added --package-manager pnpm to skip prompt ---
npx @nestjs/cli new $SERVICE_NAME --package-manager pnpm
# -----------------------------------------------------------

cd $SERVICE_NAME

# Create .env
cat > .env << ENV
PORT=$PORT
NODE_ENV="development"
REDIS_HOST="localhost"
REDIS_PORT=6379
ENV

echo "✅ Service created! Next steps:"
echo "1. cd services/$SERVICE_NAME"
echo "2. Install dependencies: pnpm install"
echo "3. If using database: npx prisma init"
echo "4. Implement your service logic"
echo "5. Commit: git add . && git commit -m 'Add $SERVICE_NAME'"
'@

# Ensure the directory exists
if (!(Test-Path "scripts")) { New-Item -ItemType Directory -Path "scripts" }

# Write the file (Force overwrites if exists)
Set-Content -Path "scripts/create-service.sh" -Value $scriptContent -Encoding UTF8

# Attempt to set execution permissions (works if git/bash tools are in path)
try { sh -c "chmod +x scripts/create-service.sh" } catch {}

#!/bin/bash

SERVICE_NAME=$1
PORT=$2

if [ -z "$SERVICE_NAME" ] || [ -z "$PORT" ]; then
    echo "Usage: ./create-service.sh <service-name> <port>"
    exit 1
fi

echo "... Creating $SERVICE_NAME on port $PORT..."

cd services
# FIX: Added --package-manager pnpm for silent installation
npx @nestjs/cli new $SERVICE_NAME --package-manager pnpm
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

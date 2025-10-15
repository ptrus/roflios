#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

IMAGE_NAME="docker.io/ptrusr/roflios"
TAG="${1:-latest}"

echo -e "${YELLOW}Building Docker image: ${IMAGE_NAME}:${TAG}${NC}"
docker build -t "${IMAGE_NAME}:${TAG}" .

echo -e "${GREEN}✓ Build successful${NC}"
echo -e "${YELLOW}Pushing to Docker Hub...${NC}"

# Check if logged in to Docker Hub
if ! docker info | grep -q "Username"; then
    echo -e "${RED}Not logged in to Docker Hub. Please run: docker login${NC}"
    exit 1
fi

docker push "${IMAGE_NAME}:${TAG}"

echo -e "${GREEN}✓ Successfully pushed ${IMAGE_NAME}:${TAG}${NC}"

# Also tag and push as latest if a specific tag was provided
if [ "$TAG" != "latest" ]; then
    echo -e "${YELLOW}Also tagging as latest...${NC}"
    docker tag "${IMAGE_NAME}:${TAG}" "${IMAGE_NAME}:latest"
    docker push "${IMAGE_NAME}:latest"
    echo -e "${GREEN}✓ Successfully pushed ${IMAGE_NAME}:latest${NC}"
fi

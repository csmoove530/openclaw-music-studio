#!/bin/bash
# Emergency kill switch for OpenClaw agent
# Usage: ./kill-agent.sh

echo "Stopping OpenClaw containers..."
docker compose -f ~/openclaw-sandbox/openclaw/docker-compose.yml down --remove-orphans

echo "Removing isolated network..."
docker network rm openclaw-isolated 2>/dev/null

echo "Agent terminated."

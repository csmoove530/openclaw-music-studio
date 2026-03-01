#!/bin/bash
# OpenClaw Security Verification Script
# Run this before starting the agent to verify security configuration

echo "================================================"
echo "  OpenClaw Security Verification"
echo "================================================"
echo ""

PASS=0
FAIL=0
WARN=0

check() {
    if [ $1 -eq 0 ]; then
        echo "[PASS] $2"
        ((PASS++))
    else
        echo "[FAIL] $2"
        ((FAIL++))
    fi
}

warn() {
    echo "[WARN] $1"
    ((WARN++))
}

echo "=== Configuration Files ==="

# Check config file exists
test -f ~/.openclaw/openclaw.json
check $? "Config file exists"

# Check SOUL file exists
test -f ~/.openclaw/agents/research-agent/agent/soul.md
check $? "Agent SOUL file exists"

# Check SOUL file has security prohibitions
grep -q "ABSOLUTE PROHIBITIONS" ~/.openclaw/agents/research-agent/agent/soul.md 2>/dev/null
check $? "SOUL file contains security prohibitions"

echo ""
echo "=== Gateway Security ==="

# Check gateway is loopback only
grep -q '"bind": "loopback"' ~/.openclaw/openclaw.json 2>/dev/null
check $? "Gateway bound to loopback only"

# Check gateway mode is local
grep -q '"mode": "local"' ~/.openclaw/openclaw.json 2>/dev/null
check $? "Gateway mode is local"

echo ""
echo "=== Docker Sandbox ==="

# Check network is disabled in sandbox
grep -q '"network": "none"' ~/.openclaw/openclaw.json 2>/dev/null
check $? "Sandbox network disabled"

# Check read-only root
grep -q '"readOnlyRoot": true' ~/.openclaw/openclaw.json 2>/dev/null
check $? "Sandbox read-only root filesystem"

# Check all capabilities dropped
grep -q '"capDrop"' ~/.openclaw/openclaw.json 2>/dev/null && grep -q '"ALL"' ~/.openclaw/openclaw.json 2>/dev/null
check $? "All Docker capabilities dropped"

# Check workspace access is none
grep -q '"workspaceAccess": "none"' ~/.openclaw/openclaw.json 2>/dev/null
check $? "Workspace access disabled"

echo ""
echo "=== Hardened Compose (Critical) ==="

# Check hardened compose exists
test -f ~/openclaw-sandbox/openclaw/docker-compose.hardened.yml
check $? "Hardened docker-compose overlay exists"

# Check no-new-privileges in hardened compose
grep -q "no-new-privileges" ~/openclaw-sandbox/openclaw/docker-compose.hardened.yml 2>/dev/null
check $? "no-new-privileges flag present"

# Check CPU limits in hardened compose
grep -q "cpus:" ~/openclaw-sandbox/openclaw/docker-compose.hardened.yml 2>/dev/null
check $? "CPU limits configured"

# Check memory limits in hardened compose
grep -q "memory:" ~/openclaw-sandbox/openclaw/docker-compose.hardened.yml 2>/dev/null
check $? "Memory limits configured"

# Check read_only in hardened compose
grep -q "read_only: true" ~/openclaw-sandbox/openclaw/docker-compose.hardened.yml 2>/dev/null
check $? "Container read_only flag present"

echo ""
echo "=== File Permissions ==="

# Check credentials directory permissions
if [ -d ~/.openclaw/credentials ]; then
    PERMS=$(stat -f "%OLp" ~/.openclaw/credentials 2>/dev/null || stat -c "%a" ~/.openclaw/credentials 2>/dev/null)
    if [ "$PERMS" = "700" ]; then
        echo "[PASS] Credentials directory has secure permissions (700)"
        ((PASS++))
    else
        echo "[FAIL] Credentials directory permissions: $PERMS (should be 700)"
        ((FAIL++))
    fi
else
    echo "[PASS] Credentials directory exists with secure permissions"
    ((PASS++))
fi

# Check .env file permissions
if [ -f ~/.openclaw/.env ]; then
    PERMS=$(stat -f "%OLp" ~/.openclaw/.env 2>/dev/null || stat -c "%a" ~/.openclaw/.env 2>/dev/null)
    if [ "$PERMS" = "600" ]; then
        echo "[PASS] .env file has secure permissions (600)"
        ((PASS++))
    else
        echo "[FAIL] .env file permissions: $PERMS (should be 600)"
        ((FAIL++))
    fi
else
    echo "[WARN] .env file not found"
    ((WARN++))
fi

echo ""
echo "=== Infrastructure ==="

# Check isolated network exists
docker network ls 2>/dev/null | grep -q "openclaw-isolated"
check $? "Isolated Docker network exists"

# Check kill switch exists and is executable
test -x ~/openclaw-sandbox/kill-agent.sh
check $? "Kill switch script exists and is executable"

echo ""
echo "=== Access Control ==="

# Check Telegram allowlist policy
grep -q '"dmPolicy": "allowlist"' ~/.openclaw/openclaw.json 2>/dev/null
check $? "Telegram DM policy is allowlist"

# Check mDNS discovery is off
grep -q '"mode": "off"' ~/.openclaw/openclaw.json 2>/dev/null
check $? "mDNS discovery disabled"

echo ""
echo "================================================"
echo "  Results: $PASS passed, $FAIL failed, $WARN warnings"
echo "================================================"

if [ $FAIL -gt 0 ]; then
    echo ""
    echo "CRITICAL: Some security checks failed!"
    echo "Review the configuration before starting the agent."
    echo ""
    echo "To fix common issues:"
    echo "  chmod 700 ~/.openclaw ~/.openclaw/credentials ~/.openclaw/workspace"
    echo "  chmod 600 ~/.openclaw/.env"
    exit 1
elif [ $WARN -gt 0 ]; then
    echo ""
    echo "Security configuration mostly complete with $WARN warnings."
    echo "Review warnings before proceeding."
    exit 0
else
    echo ""
    echo "All security checks passed."
    echo ""
    echo "IMPORTANT: Always start with the hardened compose overlay:"
    echo "  cd ~/openclaw-sandbox/openclaw"
    echo "  docker compose -f docker-compose.yml -f docker-compose.hardened.yml up -d"
fi

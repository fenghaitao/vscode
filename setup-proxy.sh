#!/bin/bash

# Proxy configuration for Electron download
# Usage: Provide proxy URL as first argument, or use existing https_proxy env variable
#        Example: source setup-proxy.sh http://proxy.example.com:8080
#        Or:      source setup-proxy.sh  (uses $https_proxy if set)

if [ -z "$1" ]; then
	if [ -n "$https_proxy" ]; then
		PROXY="$https_proxy"
		echo "No proxy argument provided, using existing https_proxy: $PROXY"
	elif [ -n "$HTTPS_PROXY" ]; then
		PROXY="$HTTPS_PROXY"
		echo "No proxy argument provided, using existing HTTPS_PROXY: $PROXY"
	else
		echo "Usage: source $0 <proxy_url>"
		echo "Example: source $0 http://proxy.example.com:8080"
		echo "Or set https_proxy environment variable before sourcing this script"
		return 1 2>/dev/null || exit 1
	fi
else
	PROXY="$1"
fi
echo "Using proxy: $PROXY"

# Standard proxy variables (used by global-agent via @electron/get)
export HTTP_PROXY="$PROXY"
export HTTPS_PROXY="$PROXY"
export http_proxy="$PROXY"
export https_proxy="$PROXY"

# Global Agent specific variables (used by @electron/get)
export GLOBAL_AGENT_HTTP_PROXY="$PROXY"
export GLOBAL_AGENT_HTTPS_PROXY="$PROXY"

# Enable proxy support in @electron/get
export ELECTRON_GET_USE_PROXY=true

# Force global-agent to be used
export GLOBAL_AGENT_FORCE_GLOBAL_AGENT=true

# Disable certificate verification if needed (uncomment if required)
# export NODE_TLS_REJECT_UNAUTHORIZED=0

echo ""
echo "Proxy environment variables set:"
echo "  HTTP_PROXY=$HTTP_PROXY"
echo "  HTTPS_PROXY=$HTTPS_PROXY"
echo "  GLOBAL_AGENT_HTTP_PROXY=$GLOBAL_AGENT_HTTP_PROXY"
echo "  GLOBAL_AGENT_HTTPS_PROXY=$GLOBAL_AGENT_HTTPS_PROXY"
echo "  ELECTRON_GET_USE_PROXY=$ELECTRON_GET_USE_PROXY"
echo ""
echo "Now run: npm install"

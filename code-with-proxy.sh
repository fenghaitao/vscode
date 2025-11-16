#!/bin/bash

# Wrapper script to run VSCode with proxy configuration
# This sets up all necessary proxy environment variables and then runs code.sh
# Usage: Set HTTP_PROXY/HTTPS_PROXY environment variables before running this script
#        Example: HTTP_PROXY=http://proxy.example.com:8080 ./code-with-proxy.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if proxy is already set in environment
if [ -z "${HTTP_PROXY}" ] && [ -z "${HTTPS_PROXY}" ]; then
	echo "Warning: No proxy configured. Set HTTP_PROXY or HTTPS_PROXY environment variables."
	echo "Example: HTTP_PROXY=http://proxy.example.com:8080 $0"
fi

# Use the proxy from environment if set
PROXY="${HTTPS_PROXY:-${HTTP_PROXY}}"

if [ -n "${PROXY}" ]; then
	echo "Using proxy: $PROXY"
fi

# Ensure all proxy variable variants are set (some tools check lowercase, others uppercase)
if [ -n "${PROXY}" ]; then
	export HTTP_PROXY="$PROXY"
	export HTTPS_PROXY="$PROXY"
	export http_proxy="$PROXY"
	export https_proxy="$PROXY"

	# Global Agent specific variables (used by @electron/get)
	export GLOBAL_AGENT_HTTP_PROXY="$PROXY"
	export GLOBAL_AGENT_HTTPS_PROXY="$PROXY"
fi

# Enable proxy support in @electron/get
export ELECTRON_GET_USE_PROXY=true

# Force global-agent to be used
export GLOBAL_AGENT_FORCE_GLOBAL_AGENT=true

# Disable SSL certificate verification (needed for corporate proxies)
export NODE_TLS_REJECT_UNAUTHORIZED=0

# Bootstrap global-agent for Node.js HTTP(S) requests
export NODE_OPTIONS="-r global-agent/bootstrap ${NODE_OPTIONS:-}"

echo "Starting VSCode..."
exec "$SCRIPT_DIR/scripts/code.sh" "$@"

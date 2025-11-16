#!/usr/bin/env bash

set -e

# Get Electron version from package.json
ELECTRON_VERSION=$(node -p "require('./package.json').devDependencies.electron")
PRODUCT_NAME=$(node -p "require('./product.json').applicationName")
PLATFORM=$(node -p "process.platform")
ARCH=$(node -p "process.arch")

echo "Downloading Electron ${ELECTRON_VERSION} for ${PLATFORM}-${ARCH}..."

# Create directory
mkdir -p .build/electron

# Download Electron
ELECTRON_URL="https://github.com/electron/electron/releases/download/v${ELECTRON_VERSION}/electron-v${ELECTRON_VERSION}-${PLATFORM}-${ARCH}.zip"
echo "Downloading from: ${ELECTRON_URL}"

# Use proxy if HTTP_PROXY or HTTPS_PROXY environment variables are set
PROXY_ARGS=""
if [ -n "${HTTP_PROXY}" ] || [ -n "${HTTPS_PROXY}" ]; then
	PROXY_ARGS="-x ${HTTPS_PROXY:-${HTTP_PROXY}}"
	[ -n "${HTTPS_PROXY}" ] && echo "Using proxy: ${HTTPS_PROXY}"
fi

curl -L ${PROXY_ARGS} -o .build/electron/electron.zip "${ELECTRON_URL}"

# Extract
echo "Extracting..."
unzip -q .build/electron/electron.zip -d .build/electron/
rm .build/electron/electron.zip

# Copy electron binary with product name
if [ "${PLATFORM}" = "linux" ]; then
	cp .build/electron/electron .build/electron/${PRODUCT_NAME}
	chmod +x .build/electron/${PRODUCT_NAME}
elif [ "${PLATFORM}" = "darwin" ]; then
	# macOS has different structure
	echo "macOS setup would go here"
fi

# Verify version
if [ -f .build/electron/version ]; then
	DOWNLOADED_VERSION=$(cat .build/electron/version)
	echo "Successfully downloaded Electron ${DOWNLOADED_VERSION}"
else
	echo "Warning: version file not found"
fi

echo "Electron setup complete!"

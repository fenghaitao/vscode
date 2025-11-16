# Proxy configuration for Electron download on Windows
# Usage: . .\setup-proxy.ps1 http://proxy.example.com:8080
#        Or: . .\setup-proxy.ps1  (uses $env:HTTPS_PROXY if set)

param(
    [string]$ProxyUrl
)

if ([string]::IsNullOrEmpty($ProxyUrl)) {
    if ($env:HTTPS_PROXY) {
        $ProxyUrl = $env:HTTPS_PROXY
        Write-Host "No proxy argument provided, using existing HTTPS_PROXY: $ProxyUrl" -ForegroundColor Yellow
    } elseif ($env:https_proxy) {
        $ProxyUrl = $env:https_proxy
        Write-Host "No proxy argument provided, using existing https_proxy: $ProxyUrl" -ForegroundColor Yellow
    } else {
        Write-Host "Usage: . .\setup-proxy.ps1 <proxy_url>" -ForegroundColor Red
        Write-Host "Example: . .\setup-proxy.ps1 http://proxy.example.com:8080" -ForegroundColor Red
        Write-Host "Or set HTTPS_PROXY environment variable before running this script" -ForegroundColor Red
        return
    }
}

Write-Host "Using proxy: $ProxyUrl" -ForegroundColor Green

# Standard proxy variables (used by global-agent via @electron/get)
$env:HTTP_PROXY = $ProxyUrl
$env:HTTPS_PROXY = $ProxyUrl
$env:http_proxy = $ProxyUrl
$env:https_proxy = $ProxyUrl

# Global Agent specific variables (used by @electron/get)
$env:GLOBAL_AGENT_HTTP_PROXY = $ProxyUrl
$env:GLOBAL_AGENT_HTTPS_PROXY = $ProxyUrl

# Enable proxy support in @electron/get
$env:ELECTRON_GET_USE_PROXY = "true"

# Force global-agent to be used
$env:GLOBAL_AGENT_FORCE_GLOBAL_AGENT = "true"

# Disable certificate verification if needed (uncomment if required)
# $env:NODE_TLS_REJECT_UNAUTHORIZED = "0"

Write-Host ""
Write-Host "Proxy environment variables set:" -ForegroundColor Cyan
Write-Host "  HTTP_PROXY=$env:HTTP_PROXY"
Write-Host "  HTTPS_PROXY=$env:HTTPS_PROXY"
Write-Host "  GLOBAL_AGENT_HTTP_PROXY=$env:GLOBAL_AGENT_HTTP_PROXY"
Write-Host "  GLOBAL_AGENT_HTTPS_PROXY=$env:GLOBAL_AGENT_HTTPS_PROXY"
Write-Host "  ELECTRON_GET_USE_PROXY=$env:ELECTRON_GET_USE_PROXY"
Write-Host ""
Write-Host "Now run: npm install" -ForegroundColor Green

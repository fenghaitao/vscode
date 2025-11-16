@echo off
REM Wrapper script to run VSCode with proxy configuration
REM This sets up all necessary proxy environment variables and then runs code.bat
REM Usage: Set HTTP_PROXY/HTTPS_PROXY environment variables before running this script
REM        Example: set HTTP_PROXY=http://proxy.example.com:8080 && code-with-proxy.bat

setlocal

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0

REM Check if proxy is already set in environment
if "%HTTP_PROXY%"=="" if "%HTTPS_PROXY%"=="" (
    echo Warning: No proxy configured. Set HTTP_PROXY or HTTPS_PROXY environment variables.
    echo Example: set HTTP_PROXY=http://proxy.example.com:8080 ^&^& %~nx0
)

REM Use the proxy from environment if set (prefer HTTPS_PROXY)
if not "%HTTPS_PROXY%"=="" (
    set PROXY=%HTTPS_PROXY%
) else if not "%HTTP_PROXY%"=="" (
    set PROXY=%HTTP_PROXY%
)

if not "%PROXY%"=="" (
    echo Using proxy: %PROXY%
)

REM Ensure all proxy variable variants are set (some tools check lowercase, others uppercase)
if not "%PROXY%"=="" (
    set HTTP_PROXY=%PROXY%
    set HTTPS_PROXY=%PROXY%
    set http_proxy=%PROXY%
    set https_proxy=%PROXY%
    
    REM Global Agent specific variables (used by @electron/get)
    set GLOBAL_AGENT_HTTP_PROXY=%PROXY%
    set GLOBAL_AGENT_HTTPS_PROXY=%PROXY%
)

REM Enable proxy support in @electron/get
set ELECTRON_GET_USE_PROXY=true

REM Force global-agent to be used
set GLOBAL_AGENT_FORCE_GLOBAL_AGENT=true

REM Disable SSL certificate verification (needed for corporate proxies)
set NODE_TLS_REJECT_UNAUTHORIZED=0

REM Bootstrap global-agent for Node.js HTTP(S) requests
if "%NODE_OPTIONS%"=="" (
    set NODE_OPTIONS=-r global-agent/bootstrap
) else (
    set NODE_OPTIONS=-r global-agent/bootstrap %NODE_OPTIONS%
)

echo Starting VSCode...
call "%SCRIPT_DIR%scripts\code.bat" %*

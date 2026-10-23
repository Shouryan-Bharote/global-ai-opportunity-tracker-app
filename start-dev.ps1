#!/usr/bin/env pwsh
# ==============================================================================
# TrackIT — Full Dev Stack Startup Script
# ==============================================================================
# Starts all three services in separate terminal windows:
#   1. FastAPI Backend       (port 8000)
#   2. Scraper Scheduler     (daemon)
#   3. Flutter App           (Windows / Android)
#
# Usage (from the "Major Project" folder, or anywhere):
#   .\start-dev.ps1                 # starts everything
#   .\start-dev.ps1 -SkipScraper   # skip the scheduler (no scraping)
#   .\start-dev.ps1 -SkipFlutter   # backend only (no Flutter)
#   .\start-dev.ps1 -Device android # force Android emulator launch
# ==============================================================================

param(
    [switch]$SkipScraper,
    [switch]$SkipFlutter,
    [string]$Device = "windows"   # "windows" | "android" | "web"
)

$ErrorActionPreference = "Stop"

# ── Paths ──────────────────────────────────────────────────────────────────────
$BackendDir  = "D:\My Projects\Major Project\backend\global-ai-opportunity-tracker-backend"
$FrontendDir = "D:\My Projects\Major Project\global-ai-opportunity-tracker-app"
$AdbExe      = "D:\Development\AndroidSdk\platform-tools\adb.exe"

# ── Helpers ────────────────────────────────────────────────────────────────────
function Write-Header($msg) {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "  $msg" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
}

function Open-NewTerminal($title, $workDir, $command) {
    $args = "-NoExit -Command `"Set-Location '$workDir'; $command`""
    Start-Process powershell -ArgumentList $args -WindowStyle Normal
    Write-Host "  OK: $title" -ForegroundColor Green
}

# ── 1. Backend ─────────────────────────────────────────────────────────────────
Write-Header "Starting FastAPI Backend"
Open-NewTerminal `
    "TrackIT API (port 8000)" `
    $BackendDir `
    "Write-Host 'Starting FastAPI backend on 0.0.0.0:8000...' -ForegroundColor Yellow; poetry run uvicorn api.main:app --reload --port 8000 --host 0.0.0.0"

Write-Host "  Waiting 5 seconds for backend to boot..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# ── 2. Scraper Scheduler (optional) ──────────────────────────────────────────
if (-not $SkipScraper) {
    Write-Header "Starting Scraper Scheduler"
    Open-NewTerminal `
        "TrackIT Scheduler (daemon)" `
        $BackendDir `
        "Write-Host 'Starting scraper scheduler...' -ForegroundColor Yellow; poetry run python -m scraper.core.scheduler.job_scheduler --scheduler"
} else {
    Write-Host "  Skipping Scheduler (-SkipScraper)" -ForegroundColor DarkGray
}

# ── 3. Flutter App ─────────────────────────────────────────────────────────────
if (-not $SkipFlutter) {
    Write-Header "Starting Flutter App"

    $flutterTarget = switch ($Device) {
        "android" { "-d emulator" }
        "web"     { "-d chrome" }
        default   { "-d windows" }
    }

    # For physical Android: ensure adb reverse so localhost:8000 reaches PC
    if ($Device -eq "android") {
        if (Test-Path $AdbExe) {
            Write-Host "  Setting up adb reverse..." -ForegroundColor Yellow
            & $AdbExe reverse tcp:8000 tcp:8000 2>$null
            Write-Host "  adb reverse tcp:8000 tcp:8000 done" -ForegroundColor Green
        } else {
            Write-Host "  WARNING: adb not found at $AdbExe" -ForegroundColor Red
            Write-Host "  Physical device cannot reach localhost:8000 without adb reverse!" -ForegroundColor Red
        }
    }

    Open-NewTerminal `
        "TrackIT Flutter ($Device)" `
        $FrontendDir `
        "Write-Host 'Starting Flutter ($Device)...' -ForegroundColor Yellow; flutter run $flutterTarget"
} else {
    Write-Host "  Skipping Flutter (-SkipFlutter)" -ForegroundColor DarkGray
}

# ── Done ───────────────────────────────────────────────────────────────────────
Write-Header "All Services Launched"
Write-Host ""
Write-Host "  Backend API:   http://localhost:8000"
Write-Host "  API Docs:      http://localhost:8000/docs"
Write-Host "  Health Check:  http://localhost:8000/health"
Write-Host ""
Write-Host "  TIP: Pull-to-refresh in the app to get fresh data immediately."
Write-Host "  TIP: Scraper runs automatically at 2:00 AM (cron: 0 2 * * *)."
Write-Host "  TIP: To run a one-off scrape now:"
Write-Host "       poetry run python -m scraper.core.scheduler.job_scheduler"
Write-Host ""

# Remove RAILWAY_TOKEN from all locations

Write-Host "Removing RAILWAY_TOKEN from all locations..." -ForegroundColor Yellow

# 1. Remove from current session
if (Get-Item Env:RAILWAY_TOKEN -ErrorAction SilentlyContinue) {
    Remove-Item Env:RAILWAY_TOKEN -ErrorAction SilentlyContinue
    Write-Host "Removed from current session" -ForegroundColor Green
} else {
    Write-Host "Not in current session" -ForegroundColor Green
}

# 2. Remove from User environment variables
$userToken = [Environment]::GetEnvironmentVariable('RAILWAY_TOKEN', 'User')
if ($userToken) {
    [Environment]::SetEnvironmentVariable('RAILWAY_TOKEN', $null, 'User')
    Write-Host "Removed from User environment variables" -ForegroundColor Green
} else {
    Write-Host "Not in User environment variables" -ForegroundColor Green
}

# 3. Remove from Machine environment variables
try {
    $machineToken = [Environment]::GetEnvironmentVariable('RAILWAY_TOKEN', 'Machine')
    if ($machineToken) {
        [Environment]::SetEnvironmentVariable('RAILWAY_TOKEN', $null, 'Machine')
        Write-Host "Removed from Machine environment variables" -ForegroundColor Green
    }
} catch {
    Write-Host "Could not access Machine scope (requires admin)" -ForegroundColor Yellow
}

# 4. Remove from Windows Registry
try {
    Remove-ItemProperty -Path "HKCU:\Environment" -Name "RAILWAY_TOKEN" -ErrorAction SilentlyContinue
    Write-Host "Removed from Registry" -ForegroundColor Green
} catch {
    Write-Host "Registry key not found or already removed" -ForegroundColor Green
}

# 5. Check Railway config directory
$railwayConfig = "$env:USERPROFILE\.railway"
if (Test-Path $railwayConfig) {
    $configFile = Join-Path $railwayConfig "config.json"
    if (Test-Path $configFile) {
        try {
            $config = Get-Content $configFile -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($config.token) {
                $config.PSObject.Properties.Remove('token')
                $config | ConvertTo-Json | Set-Content $configFile
                Write-Host "Removed from Railway config file" -ForegroundColor Green
            }
        } catch {
            Write-Host "Could not modify Railway config file" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "Token cleanup complete!" -ForegroundColor Green
Write-Host "Please close and reopen your terminal, then run: npx @railway/cli login" -ForegroundColor Cyan

@echo off
echo Removing RAILWAY_TOKEN from current session...
set RAILWAY_TOKEN=
echo Token cleared from this session.
echo.
echo Please run this script in your terminal where you saw the error, then try:
echo   npx @railway/cli login
pause


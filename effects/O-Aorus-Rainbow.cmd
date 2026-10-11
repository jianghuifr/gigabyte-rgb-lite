@echo off
schtasks /Run /TN "GccLiteFx-AorusRainbow" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-AorusRainbow) else (echo OK - AorusRainbow applied)


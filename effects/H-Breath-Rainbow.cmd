@echo off
schtasks /Run /TN "GccLiteFx-BreathRainbow" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-BreathRainbow) else (echo OK - BreathRainbow applied)


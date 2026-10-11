@echo off
schtasks /Run /TN "GccLiteFx-FastCycle" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-FastCycle) else (echo OK - FastCycle applied)


@echo off
schtasks /Run /TN "GccLiteFx-ColCyan" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-ColCyan) else (echo OK - ColCyan applied)


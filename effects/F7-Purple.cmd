@echo off
schtasks /Run /TN "GccLiteFx-ColPurple" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-ColPurple) else (echo OK - ColPurple applied)


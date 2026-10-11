@echo off
schtasks /Run /TN "GccLiteFx-ColWhite" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-ColWhite) else (echo OK - ColWhite applied)


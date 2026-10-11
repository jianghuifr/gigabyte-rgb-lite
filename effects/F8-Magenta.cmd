@echo off
schtasks /Run /TN "GccLiteFx-ColMagenta" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-ColMagenta) else (echo OK - ColMagenta applied)


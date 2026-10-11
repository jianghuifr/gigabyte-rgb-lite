@echo off
schtasks /Run /TN "GccLiteFx-ColYellow" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-ColYellow) else (echo OK - ColYellow applied)


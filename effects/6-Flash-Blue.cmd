@echo off
schtasks /Run /TN "GccLiteFx-Flash" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-Flash) else (echo OK - Flash applied)


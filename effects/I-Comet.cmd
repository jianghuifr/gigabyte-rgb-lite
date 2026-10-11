@echo off
schtasks /Run /TN "GccLiteFx-Comet" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-Comet) else (echo OK - Comet applied)


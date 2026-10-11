@echo off
schtasks /Run /TN "GccLiteFx-Cycle" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-Cycle) else (echo OK - Cycle applied)


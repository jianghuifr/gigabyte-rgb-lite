@echo off
schtasks /Run /TN "GccLiteFx-Dim" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-Dim) else (echo OK - Dim applied)


@echo off
schtasks /Run /TN "GccLiteFx-MemOnly" >nul 2>&1
if errorlevel 1 (echo FAILED: GccLiteFx-MemOnly) else (echo OK - MemOnly applied)


@echo off
Title %~nx0
SetLocal EnableExtensions EnableDelayedExpansion

rem #################################################
rem The script is to be called on DAQ start and stop.
rem #################################################

:CheckComputer
rem if /I not "%ComputerName%" == "demo-daq-pc" goto :EOF

:Main
if /i "%~1" == "pre"  call :PreProcessor
if /i "%~1" == "post" call :PostProcessor
goto :EOF

:PreProcessor
goto :EOF

:PostProcessor
goto :EOF

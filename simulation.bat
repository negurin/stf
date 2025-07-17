@echo off
Title %~nx0
SetLocal EnableExtensions EnableDelayedExpansion

:Main
pushd "%~dp0" && call HardwareOn.bat OFF
popd
exit /b %ERRORLEVEL%
goto :EOF

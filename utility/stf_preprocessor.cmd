@echo off
Title %~nx0
SetLocal EnableExtensions EnableDelayedExpansion

rem ###################################################
rem The script is to be called before DAQ config start.
rem ###################################################

set script=%~nx0
set script=%script:_preprocessor=_processor%

call "%~dp0%script%" pre

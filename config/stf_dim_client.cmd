@echo off
SetLocal EnableExtensions EnableDelayedExpansion

rem ***************************
rem DIM Client config generator
rem ***************************

:Main
call :InitializeVariables
pushd "%~dp0" && call :DIMClient
popd
echo Done.
goto :EOF

:InitializeVariables
set dim_client=%~n0.cfg
set dim_dic=stf_dim_dic.cfg
set dim_ctrl=stf_dim_ctrl.cfg
set dim_tags=stf_dim_tags.cfg
goto :EOF

:DIMClient
call :DeleteFile %dim_client%
call :MakeClient >> %dim_client%
goto :EOF

:MakeClient
type %dim_dic%
type %dim_ctrl%
type %dim_tags%
goto :EOF

:DeleteFile
if "%~1" == "" goto :EOF
if exist "%~1" del /f /q "%~1"
shift & goto :DeleteFile
goto :EOF

@echo off
SetLocal EnableExtensions EnableDelayedExpansion

rem ****************************
rem DIM DIC/DIS config generator
rem ****************************

:Main
call :InitializeVariables
pushd "%~dp0" && call :DIMServices
popd
echo Done.
goto :EOF

:InitializeVariables
set "fname=%~n0"
rem set "fname=%fname:_dim=%"
set diccfg=%fname%_dic.cfg
set discfg=%fname%_dis.cfg
set devmsg=devPostMsg
set "FN=STF"     :: Facility name
set "SS=DIM"      :: Subsystem name
set "FP=%FN:.=/%" :: Facility DIM  path, i.e. FN name with . to / replacement
set "FF=%FN:.=_%" :: Facility file name, i.e. FN name with . to _ replacement
goto :EOF

:DIMServices
call :DeleteFiles %diccfg% %discfg%
call :DIM_DIS  %* >> %discfg%
call :DIM_DIC  %* >> %diccfg%
call :DIM_CTRL %* >> %diccfg%
goto :EOF

:DIM_DIS
unix dimcfg ^
  -n section  "[&%FN%.%SS%.CTRL]" ^
  -n print    DimServerMode = 1 ^
  -n end ^
  -n dis_cmnd %FP%/%SS%/DIMGUICLICK ^
  -n tag      %FN%.%SS%.DIMGUICLICK ^
  -n %devmsg% "&%FN%.%SS%.CTRL @DIMGUICLICK=%%**" ^
  -n end ^
  -n dic_cmnd %FP%/%SS%/DIMGUICLICK ^
  -n tag      %FN%.%SS%.DIMGUICLICK ^
  -n end ^
  -n dis_info %FP%/%SS%/CLOCK ^
  -n tag      %FN%.%SS%.CLOCK ^
  -n end ^
  -n dis_info %FP%/%SS%/SERVID ^
  -n tag      %FN%.%SS%.SERVID ^
  -n end ^
  -n
goto :EOF

:DIM_DIC
unix dimcfg ^
  -n section  "[&%FN%.%SS%.CTRL]" ^
  -n print    DimClientMode = 1 ^
  -n end ^
  -n dic_cmnd %FP%/%SS%/DIMGUICLICK ^
  -n tag      %FN%.%SS%.DIMGUICLICK ^
  -n end ^
  -n dic_info %FP%/%SS%/CLOCK ^
  -n tag      %FN%.%SS%.CLOCK ^
  -n %devmsg% "&%FN%.%SS%.CTRL @DimTagUpdate=%FN%.%SS%.CLOCK" ^
  -n end ^
  -n dic_info %FP%/%SS%/SERVID ^
  -n tag      %FN%.%SS%.SERVID ^
  -n %devmsg% "&%FN%.%SS%.CTRL @DimTagUpdate=%FN%.%SS%.SERVID" ^
  -n end ^
  -n
goto :EOF

:DIM_CTRL
echo.
echo [DataStorage]
echo []
echo.
echo [TagList]
echo []
echo.
echo [^&%FN%.%SS%.CTRL]
echo []
echo.
goto :EOF

:DeleteFiles
if "%~1" == "" goto :EOF
if exist "%~1" del /f /q "%~1"
shift & goto :DeleteFiles
goto :EOF

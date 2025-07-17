@echo off
Title %~nx0
SetLocal EnableExtensions EnableDelayedExpansion

:SetConfigFileList
set cfg=
set cfg=%cfg% config\stf_daq.cfg

pushd "%~dp0\" && call :Replace_hdw_sim "%cfg%" %1
popd
goto :EOF

rem -----------------------------------------------------------------------
rem - Replace _hdw.cfg  to _hdw-.cfg, _sim-.cfg to _sim.cfg  for simulation
rem - Replace _hdw-.cfg to _hdw.cfg,  _sim.cfg  to _sim-.cfg for hardware
rem -----------------------------------------------------------------------
:Replace_hdw_sim
for %%i in ( %~1 ) do (
 if "%~2" == "OFF" (
  type %%i | unix replacestr _hdw.cfg _hdw-.cfg | unix replacestr _sim-.cfg _sim.cfg > %%i.tmp
 ) else (
  type %%i | unix replacestr _hdw-.cfg _hdw.cfg | unix replacestr _sim.cfg _sim-.cfg > %%i.tmp
 )
 move /y %%i.tmp %%i
)
unix true
goto :EOF

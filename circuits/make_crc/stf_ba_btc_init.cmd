@echo off
Title %~nx0
SetLocal EnableExtensions EnableDelayedExpansion

pushd "%~dp0\" && call :Main "%~n0.crc"
popd
goto :EOF

:Main
if "%~1" == "" goto :EOF
set crc=%~1
set /a posx=478
set /a posy=652
set /a xstp=6
call :DeleteFile "%crc%"
call :Generate
echo Done.
sleep 5
goto :EOF

:Generate
for /L %%i in (1, 1, 57) do call :AddSensor %%i >> "%crc%"
goto :EOF

:AddSensor
if "%~1" == "" goto :EOF
set /a numb=%~1 & shift
echo [SensorList]
echo Sensor = STF.BA.BTC.SEC%numb%
echo [STF.BA.BTC.SEC%numb%]
echo Pos = %posx%, %posy%
echo Tag#1 = 0, ..\Bitmaps\stf_ba_inj_st0.bmp
echo Tag#2 = 1, ..\Bitmaps\stf_ba_inj_st1.bmp
echo Tag#3 = 2, ..\Bitmaps\stf_ba_inj_st2.bmp
echo Tag#4 = 3, ..\Bitmaps\stf_ba_inj_st3.bmp
echo Tag#5 = 4, ..\Bitmaps\stf_ba_inj_st4.bmp
echo Hint = STF.BA.BTC.SEC%numb%
echo []
echo.
set /a posx=posx-%xstp%
unix true
goto :EOF

:DeleteFile
if "%~1" == "" goto :EOF
if exist "%~1" unix rm -f "%~1" 
unix true
goto :EOF

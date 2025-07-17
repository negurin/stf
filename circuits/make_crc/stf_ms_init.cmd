@echo off
Title %~nx0
SetLocal EnableExtensions EnableDelayedExpansion

pushd "%~dp0\" && call :Main "%~n0.crc"
popd
goto :EOF

:Main
if "%~1" == "" goto :EOF
set crc=%~1
set /a posx=377
set /a posy=580
set /a step=6
set /a numb=1
call :DeleteFile "%crc%"
call :Generate
echo Done.
sleep 5
goto :EOF

:Generate
for /L %%i in (1, 1, 29) do (
 call :AddSensor %%i >> "%crc%"
 set /a posx=posx-%step%
 set /a numb=numb+1
)

for /L %%i in (1, 1, 38) do (
 call :AddSensor %%i >> "%crc%"
 set /a posy=posy-%step%
 set /a numb=numb+1
)

for /L %%i in (1, 1, 38) do (
 call :AddSensor %%i >> "%crc%"
 set /a posx=posx+%step%
 set /a numb=numb+1
)

for /L %%i in (1, 1, 38) do (
 call :AddSensor %%i >> "%crc%"
 set /a posy=posy+%step%
 set /a numb=numb+1
)

for /L %%i in (1, 1, 9) do (
 call :AddSensor %%i >> "%crc%"
 set /a posx=posx-%step%
 set /a numb=numb+1
)
goto :EOF

:AddSensor
if "%~1" == "" goto :EOF
echo [SensorList]
echo Sensor = STF.MS.SEC%numb%
echo [STF.MS.SEC%numb%]
echo Pos = %posx%, %posy%
echo Tag#1 = 0, ..\Bitmaps\stf_ba_inj_st0.bmp
echo Tag#2 = 1, ..\Bitmaps\stf_ba_inj_st1.bmp
echo Tag#3 = 2, ..\Bitmaps\stf_ba_inj_st2.bmp
echo Tag#4 = 3, ..\Bitmaps\stf_ba_inj_st3.bmp
echo Tag#5 = 4, ..\Bitmaps\stf_ba_inj_st4.bmp
echo Hint = STF.MS.SEC%numb%
echo []
echo.
unix true
goto :EOF

:DeleteFile
if "%~1" == "" goto :EOF
if exist "%~1" unix rm -f "%~1"
unix true
goto :EOF

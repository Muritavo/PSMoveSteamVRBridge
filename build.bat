@echo off
setlocal

::Initialise
set PROJECT_ROOT=%cd%
set BUILD_PROPS_FILE=%PROJECT_ROOT%\build.properties

::Load configuration properties
call :loadBuildProperties || goto handleError

::Generate the project files for PSMoveService
call :generateProjectFiles || goto handleError

::Build driver
call :buildDriver || goto handleError

::Exit batch script
goto exit


::Function loads build properties into local variables
:loadBuildProperties
echo Loading properties from %BUILD_PROPS_FILE%
call :loadBuildProperty "psmoveservice.package.url"  %BUILD_PROPS_FILE% PSM_PACKAGE_URL
call :loadBuildProperty "openvr.package.url" %BUILD_PROPS_FILE% OPENVR_PACKAGE_URL
call :loadBuildProperty "driver.version" %BUILD_PROPS_FILE% DRIVER_VERSION
call :loadBuildProperty "cmake.build.parameters" %BUILD_PROPS_FILE% BUILD_PARAMS
call :loadBuildProperty "build.type" %BUILD_PROPS_FILE% BUILD_TYPE
echo Properties loaded successfully
goto:eof

::Fuction returns a configured build property value for the given key
:loadBuildProperty
set PROP_KEY=%1
set FILE=%2
echo "Loading %PROP_KEY% from %FILE%"
for /f "tokens=2,2 delims==" %%i in ('findstr /i %PROP_KEY% %FILE%') do set %3=%%i
goto:eof

::Function generates project files for the configured ide
:generateProjectFiles
@echo off
IF NOT EXIST %PROJECT_ROOT%\vs_project mkdir %PROJECT_ROOT%\ide
pushd %PROJECT_ROOT%\ide
echo "Rebuilding PSMoveSteamVRBridge Project files..."
echo "Running cmake in %PROJECT_ROOT%"
cmake .. -G "%BUILD_PARAMS%" -DDRIVER_VERSION="%DRIVER_VERSION%" -DPSM_PACKAGE_URL="%PSM_PACKAGE_URL%" -DOPENVR_PACKAGE_URL="%OPENVR_PACKAGE_URL%"
popd
goto:eof

::Function calls the INSTALL cmake target which will build the driver as either debug/release
:buildDriver
cmake --build ide --target INSTALL --config %BUILD_TYPE%
goto:eof

:handleError
echo "BUILD FAILED"
endlocal
exit /b 1
goto:eof

:exit
echo "BUILD SUCCESSFUL"
endlocal
exit /b 0
goto:eof
@echo off
setlocal

:: ============================================================
:: FreeCAD 1.1.4 Portable Installer
:: ============================================================

set "DOWNLOAD_DIR=%USERPROFILE%\Downloads"

set "TARGET_DIR=%DOWNLOAD_DIR%\FreeCAD_1.1.4-Windows-x86_64-py311"
set "FREECAD_DIR=%TARGET_DIR%\FreeCAD_1.1.4-Windows-x86_64-py311"
set "EXE_PATH=%FREECAD_DIR%\FreeCAD.exe"

set "ARCHIVE_FILE=%DOWNLOAD_DIR%\FreeCAD_1.1.4-Windows-x86_64-py311.7z"

set "DESKTOP=%USERPROFILE%\Desktop"
set "SHORTCUT=%DESKTOP%\FreeCAD.lnk"

set "DOWNLOAD_URL=https://github.com/FreeCAD/FreeCAD/releases/download/1.1.4/FreeCAD_1.1.4-Windows-x86_64-py311.7z"


echo.
echo ============================================================
echo              FreeCAD 1.1.4 Portable Setup
echo ============================================================
echo.


:: ============================================================
:: STEP 1 - Is FreeCAD already extracted?
:: ============================================================

echo [1/4] Checking for existing FreeCAD installation...

if exist "%EXE_PATH%" (
    echo [OK] FreeCAD.exe found.
    goto CHECK_SHORTCUT
)

echo [INFO] FreeCAD.exe not found.
echo.


:: ============================================================
:: STEP 2 - Is the downloaded archive already available?
:: ============================================================

echo [2/4] Checking for FreeCAD portable archive...

if exist "%ARCHIVE_FILE%" (
    echo [OK] Archive already exists.
    goto EXTRACT
)

echo [INFO] Archive not found.
echo.
echo Downloading FreeCAD 1.1.4 portable package...
echo.
echo %DOWNLOAD_URL%
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%ARCHIVE_FILE%'"

if errorlevel 1 (
    echo.
    echo [ERROR] Download failed.
    echo The installer will now exit.
    goto END
)

if not exist "%ARCHIVE_FILE%" (
    echo.
    echo [ERROR] Download failed - archive was not created.
    goto END
)

echo.
echo [OK] Download completed.
echo.


:: ============================================================
:: STEP 3 - Extract FreeCAD
:: ============================================================

:EXTRACT

echo [3/4] Extracting FreeCAD portable package...
echo.

if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

:: ------------------------------------------------------------
:: IMPORTANT:
:: The FreeCAD 1.1.4 portable package is a .7z archive.
:: This uses Windows tar.exe to attempt extraction.
:: ------------------------------------------------------------

tar.exe -xf "%ARCHIVE_FILE%" -C "%TARGET_DIR%"

if errorlevel 1 (
    echo.
    echo [ERROR] Extraction failed.
    echo.
    echo The archive has NOT been deleted.
    echo You can run this batch file again after fixing
    echo the extraction problem.
    goto END
)

echo.
echo [OK] Extraction command completed.
echo.


:: ============================================================
:: Verify that FreeCAD.exe really exists
:: ============================================================

if not exist "%EXE_PATH%" (
    echo.
    echo [ERROR] FreeCAD.exe was not found after extraction.
    echo.
    echo The archive has NOT been deleted.
    echo Please check the extracted folder structure.
    goto END
)

echo [OK] FreeCAD.exe confirmed.
echo.


:: ============================================================
:: Delete archive ONLY after successful extraction
:: ============================================================

if exist "%ARCHIVE_FILE%" (
    echo Removing downloaded archive...
    del /q "%ARCHIVE_FILE%"

    if exist "%ARCHIVE_FILE%" (
        echo [WARNING] Could not delete the archive.
    ) else (
        echo [OK] Archive deleted.
    )
)

echo.


:: ============================================================
:: STEP 4 - Check / create Desktop shortcut
:: ============================================================

:CHECK_SHORTCUT

echo [4/4] Checking Desktop shortcut...

if exist "%SHORTCUT%" (
    echo [OK] Desktop shortcut already exists.
    goto SUCCESS
)

echo [INFO] Desktop shortcut not found.
echo [INFO] Creating shortcut...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%SHORTCUT%'); $Shortcut.TargetPath = '%EXE_PATH%'; $Shortcut.WorkingDirectory = '%FREECAD_DIR%'; $Shortcut.IconLocation = '%EXE_PATH%,0'; $Shortcut.Save()"

if errorlevel 1 (
    echo.
    echo [ERROR] Failed to create Desktop shortcut.
    goto END
)

if not exist "%SHORTCUT%" (
    echo.
    echo [ERROR] Shortcut was not created.
    goto END
)

echo [OK] Desktop shortcut created.
echo.


:: ============================================================
:: COMPLETE
:: ============================================================

:SUCCESS

echo.
echo ============================================================
echo [SUCCESS] FreeCAD 1.1.4 setup is complete.
echo ============================================================
echo.
echo FreeCAD:
echo %EXE_PATH%
echo.
echo Shortcut:
echo %SHORTCUT%
echo.

goto END


:: ============================================================
:: ALREADY INSTALLED
:: ============================================================

:END

echo.
pause
endlocal
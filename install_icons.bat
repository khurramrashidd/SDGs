@echo off
REM ---------------------------------------------------------------------------
REM  Installs the Ibtidaa Tech app icons into the generated Android and web
REM  folders. Run this ONCE from the project root, after `flutter create`.
REM
REM    cd /d F:\2026\My_projects\FlutterProject\SDG17\sdg_app
REM    install_icons.bat
REM
REM  Safe to re-run; it overwrites the icons and nothing else.
REM ---------------------------------------------------------------------------

echo.
echo  Installing Ibtidaa Tech icons...
echo.

if not exist "android\app\src\main\res" (
  echo  ERROR: android\app\src\main\res not found.
  echo  Run this from the project root, after flutter create has made the
  echo  android folder.
  exit /b 1
)

set RES=android\app\src\main\res

REM --- Android launcher icons -------------------------------------------------
for %%D in (mdpi hdpi xhdpi xxhdpi xxxhdpi) do (
  if not exist "%RES%\mipmap-%%D" mkdir "%RES%\mipmap-%%D"
  copy /Y "_icons\android\mipmap-%%D\ic_launcher.png" "%RES%\mipmap-%%D\" >nul
)

REM --- Adaptive icon foreground ----------------------------------------------
for %%D in (mdpi hdpi xhdpi xxhdpi xxxhdpi) do (
  if not exist "%RES%\drawable-%%D" mkdir "%RES%\drawable-%%D"
  copy /Y "_icons\android\drawable-%%D\ic_launcher_foreground.png" "%RES%\drawable-%%D\" >nul
)

if not exist "%RES%\mipmap-anydpi-v26" mkdir "%RES%\mipmap-anydpi-v26"
copy /Y "_icons\android\mipmap-anydpi-v26\ic_launcher.xml" "%RES%\mipmap-anydpi-v26\" >nul

if not exist "%RES%\values" mkdir "%RES%\values"
copy /Y "_icons\android\values\ic_launcher_background.xml" "%RES%\values\" >nul

echo  [ok] Android launcher icons

REM --- Web --------------------------------------------------------------------
if not exist "web\icons" mkdir "web\icons"
copy /Y "_icons\web\favicon.ico"          "web\" >nul
copy /Y "_icons\web\apple-touch-icon.png" "web\" >nul
copy /Y "_icons\web\icons\*.png"          "web\icons\" >nul
copy /Y "web_template\index.html"         "web\" >nul
copy /Y "web_template\manifest.json"      "web\" >nul

REM Flutter's default web folder ships a favicon.png that nothing references
REM once index.html points at favicon.ico. Remove it so it cannot be served
REM by mistake.
if exist "web\favicon.png" del /Q "web\favicon.png"

echo  [ok] Web icons, manifest and index.html
echo.
echo  Done. Now run:
echo.
echo      flutter clean
echo      flutter run
echo.

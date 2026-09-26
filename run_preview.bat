@echo off
setlocal
taskkill /F /IM BloomCore.exe 2>nul
timeout /t 1 /nobreak >nul
set PATH=C:\Qt\6.11.1\mingw_64\bin;C:\Qt\Tools\mingw1310_64\bin;C:\Users\smily\ninja-win;%PATH%
set BLOOM_NO_SINGLE_INSTANCE=1
set BLOOM_PREVIEW=1
echo Starting BloomCore in preview mode...
start "" "c:\Users\smily\Bloom_Core\build-mingw\BloomCore.exe" --preview
echo Waiting for QML render and capture...
timeout /t 4 /nobreak >nul
echo Done!

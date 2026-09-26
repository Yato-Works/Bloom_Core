@echo off
setlocal
echo === Building Bloom Core with MinGW + Qt 6 ===
cmake -S . -B build-mingw -G Ninja -DCMAKE_CXX_COMPILER=C:/Qt/Tools/mingw1310_64/bin/g++.exe -DCMAKE_PREFIX_PATH=C:/Qt/6.11.1/mingw_64 -DCMAKE_BUILD_TYPE=Release
if %ERRORLEVEL% neq 0 (
    echo [ERROR] CMake configure failed
    exit /b %ERRORLEVEL%
)
cmake --build build-mingw --config Release
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Build failed
    exit /b %ERRORLEVEL%
)
echo === Build completed successfully! ===

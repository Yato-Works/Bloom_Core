@echo off
setlocal
set PATH=C:\Qt\6.11.1\mingw_64\bin;C:\Qt\Tools\mingw1310_64\bin;%PATH%
cd /d C:\Users\smily\Bloom_Core\build-mingw
set BLOOM_NO_SINGLE_INSTANCE=1
BloomCore.exe %*

@echo on

set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig"
set "GIO_MODULE_DIR="
set "G_MESSAGES_DEBUG=all"

for /f "usebackq tokens=*" %%a in (`pkg-config --cflags libsoup-3.0`) do set "PC_CFLAGS=%%a"
for /f "usebackq tokens=*" %%a in (`pkg-config --msvc-syntax --libs libsoup-3.0`) do set "PC_LIBS=%%a"

ECHO %PC_CFLAGS%
ECHO %PC_LIBS%

%CC% %CFLAGS% %LDFLAGS% %PC_CFLAGS% %PC_LIBS% %RECIPE_DIR%\test.c
if errorlevel 1 exit 1
test
if errorlevel 1 exit 1

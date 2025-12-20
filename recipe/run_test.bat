@echo on

REM hmaarrfk -- 2025/12/19
REM Requires.private and Libs.private
REM Are not meaningful in the context of shared libraries for conda-forge
REM We thus "remove them" outright to avoid
REM burdening the recipe
REM https://github.com/conda-forge/harfbuzz-feedstock/pull/146
REM https://github.com/conda-forge/conda-forge.github.io/issues/1880

setlocal EnableExtensions EnableDelayedExpansion

set "PCDIR=%PREFIX%\Library\lib\pkgconfig"

REM CMD has no in-place edit, so rewrite each file via a temporary file
for /R "%PCDIR%" %%F in (*.pc) do (
    set "TMP=%%F.tmp"
    REM Drop Requires.private and Libs.private lines
    findstr /V /R "^Requires\.private ^Libs\.private" "%%F" > "!TMP!"
    move /Y "!TMP!" "%%F" > nul
)

endlocal

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

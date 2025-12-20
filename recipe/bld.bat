@ECHO ON

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

:: set pkg-config path so that host deps can be found
:: (set as env var so it's used by both meson and during build with g-ir-scanner)
set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig;%BUILD_PREFIX%\Library\lib\pkgconfig"

:: set the path to the modules explicitly, as they won't get found otherwise
set "GIO_MODULE_DIR=%LIBRARY_LIB%\gio\modules"

:: add libintl to linker flags for Windows
set "LDFLAGS=%LDFLAGS% /LIBPATH:%LIBRARY_LIB% intl.lib"

meson ^
    setup builddir ^
    --wrap-mode=nofallback ^
    --buildtype=release ^
    --prefix=%LIBRARY_PREFIX% ^
    --backend=ninja ^
    -Dbrotli=enabled ^
    -Dtests=false ^
    -Dintrospection=enabled ^
    -Dsysprof=disabled
if errorlevel 1 exit 1

ninja -v -C builddir -j %CPU_COUNT%
if errorlevel 1 exit 1

ninja -C builddir install -j %CPU_COUNT%
if errorlevel 1 exit 1

REM gir is broken on windows
REM https://github.com/conda-forge/libsoup-feedstock/issues/46
del %LIBRARY_LIB%\\girepository-1.0\\Soup*.typelib
del %LIBRARY_PREFIX%\share\gir-1.0\Soup*.gir
del %LIBRARY_PREFIX%\bin\*.pdb

REM hmaarrfk -- 2025/12/19
REM Requires.private and Libs.private
REM Are not meaningful in the context of shared libraries for conda-forge
REM We thus "remove them" outright to avoid
REM burdening the recipe
REM https://github.com/conda-forge/harfbuzz-feedstock/pull/146
REM https://github.com/conda-forge/conda-forge.github.io/issues/1880

setlocal EnableExtensions EnableDelayedExpansion

REM CMD has no in-place edit, so rewrite each file via a temporary file
for /R "%PCDIR%" %%F in (*.pc) do (
    set "TMP=%%F.tmp"
    REM Drop Requires.private and Libs.private lines
    findstr /V /R "^Requires\.private ^Libs\.private" "%%F" > "!TMP!"
    move /Y "!TMP!" "%%F" > nul
)

endlocal

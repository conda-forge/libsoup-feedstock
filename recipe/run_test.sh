set -ex

export G_MESSAGES_DEBUG=all

if test "$GIO_MODULE_DIR" != "" ; then
  unset GIO_MODULE_DIR
fi

# Requires.private and Libs.private
# Are not meaningful in the context of shared libraries for conda-forge
# We thus "remove them" outright to avoid
# burdening the recipe
# https://github.com/conda-forge/harfbuzz-feedstock/pull/146
# https://github.com/conda-forge/conda-forge.github.io/issues/1880
find "${PREFIX}/lib/pkgconfig" -type f -name '*.pc' -exec sed -i.bak \
    -e '/^Requires\.private/d' \
    -e '/^Libs\.private/d' \
    {} +

$CC ${LDFLAGS} -o test $RECIPE_DIR/test.c $(pkg-config --cflags --libs libsoup-3.0)
./test

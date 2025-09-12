set -ex

export G_MESSAGES_DEBUG=all

if test "$GIO_MODULE_DIR" != "" ; then
  unset GIO_MODULE_DIR
fi

$CC $(pkg-config --cflags libsoup-3.0) \
    -o test $RECIPE_DIR/test.c \
    ${LDFLAGS} $(pkg-config --libs libsoup-3.0)
./test

PHP_ARG_ENABLE(decimal, whether to enable decimal support,
[  --enable-decimal        Enable decimal support])

PHP_ARG_WITH(libmpdec-path, for libmpdec custom path,
[  --with-libmpdec-path    libmpdec path], no, no)

if test "$PHP_DECIMAL" != "no"; then

    MACHINE_INCLUDES=$($CC -dumpmachine)
    AC_MSG_CHECKING([for libmpdec library in default path])
    for i in $PHP_LIBMPDEC_PATH /usr /usr/local /app/.linuxbrew/Cellar/mpdecimal/4.0.1; do
      if test -r $i/$PHP_LIBDIR/libmpdec.$SHLIB_SUFFIX_NAME || test -r $i/$PHP_LIBDIR/libmpdec.a; then
        LIBMPDEC_DIR=$i/$PHP_LIBDIR
        LIBMPDEC_INC=$i/include
        AC_MSG_RESULT(found in $LIBMPDEC_DIR)
        break
      elif test -r $i/lib64/libmpdec.$SHLIB_SUFFIX_NAME || test -r $i/lib64/libmpdec.a; then
        LIBMPDEC_DIR=$i/lib64
        LIBMPDEC_INC=$i/include
        AC_MSG_RESULT(found in $LIBMPDEC_DIR)
        break
      elif test -r $i/lib/libmpdec.$SHLIB_SUFFIX_NAME || test -r $i/lib/libmpdec.a; then
        LIBMPDEC_DIR=$i/lib
        LIBMPDEC_INC=$i/include
        AC_MSG_RESULT(found in $LIBMPDEC_DIR)
        break
      elif test   -r $i/lib/$MACHINE_INCLUDES/libmpdec.so ; then
        LIBMPDEC_DIR=$i/lib/$MACHINE_INCLUDES
        LIBMPDEC_INC=$i/include/$MACHINE_INCLUDES
        AC_MSG_RESULT(found in $LIBMPDEC_DIR)
        break
      fi
    done


    if test -z "$LIBMPDEC_DIR"; then
      AC_MSG_RESULT([Could not find libmpdec])
      AC_MSG_ERROR([Please reinstall libmpdec])

    else
      AC_MSG_CHECKING([for libmpdec headers in default path])
      if test -r $LIBMPDEC_INC/mpdecimal.h; then
        PHP_ADD_INCLUDE($LIBMPDEC_INC)
        AC_MSG_RESULT(found in $LIBMPDEC_INC)
      else
        AC_MSG_WARN(not found)
      fi
    fi


    PHP_CHECK_LIBRARY(mpdec, mpd_version, [
      PHP_ADD_LIBRARY_WITH_PATH(mpdec, $LIBMPDEC_DIR, DECIMAL_SHARED_LIBADD)
      AC_DEFINE(HAVE_LIBMPDEC, 1, [ ])
    ],[
      AC_MSG_ERROR([Please check your version of libmpdec (2.4+)])
    ],[
      -L$LIBMPDEC_DIR -lm
    ])

    PHP_NEW_EXTENSION(decimal, php_decimal.c, $ext_shared,, -DZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

    PHP_ADD_EXTENSION_DEP(decimal, standard)
    PHP_ADD_EXTENSION_DEP(decimal, spl)
    PHP_ADD_EXTENSION_DEP(decimal, json)
    PHP_SUBST(DECIMAL_SHARED_LIBADD)
fi

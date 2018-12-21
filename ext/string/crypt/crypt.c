#include "ruby.h"
#include "ruby/encoding.h"

#include <errno.h>

#if defined HAVE_STRING_CRYPT_R
# if defined HAVE_STRING_CRYPT_H
# include <crypt.h>
# endif
#elif !defined HAVE_STRING_CRYPT
# include "missing/crypt.h"
# include "missing/crypt.c"
# define HAVE_STRING_CRYPT_R 1
#endif

static void
mustnot_wchar(VALUE str)
{
    rb_encoding *enc = rb_enc_get(str);
    if (rb_enc_mbminlen(enc) > 1) {
	rb_raise(rb_eArgError, "wide char encoding: %s", rb_enc_name(enc));
    }
}

/*
 *  call-seq:
 *     str.crypt(salt_str)   -> new_str
 *
 *  Applies a one-way cryptographic hash to <i>str</i> by invoking the
 *  standard library function <code>crypt(3)</code> with the given
 *  salt string.  While the format and the result are system and
 *  implementation dependent, using a salt matching the regular
 *  expression <code>\A[a-zA-Z0-9./]{2}</code> should work on most
 *  most platforms, but on those platforms it uses insecure DES
 *  encryption, and only the first two characters of the salt string
 *  are significant.
 *
 *  This method is for use in system specific scripts, so if you want
 *  a cross-platform hash function consider using Digest or OpenSSL
 *  instead.
 */

static VALUE
rb_string_crypt(VALUE str, VALUE salt)
{
#ifdef HAVE_STRING_CRYPT_R
    VALUE databuf;
    struct crypt_data *data;
#   define STRING_CRYPT_END() ALLOCV_END(databuf)
#else
    extern char *crypt(const char *, const char *);
#   define STRING_CRYPT_END() (void)0
#endif
    VALUE result;
    const char *s, *saltp;
    char *res;
#ifdef BROKEN_STRING_CRYPT
    char salt_8bit_clean[3];
#endif

    StringValue(salt);
    mustnot_wchar(str);
    mustnot_wchar(salt);
    if (RSTRING_LEN(salt) < 2) {
      short_salt:
	rb_raise(rb_eArgError, "salt too short (need >=2 bytes)");
    }

    s = StringValueCStr(str);
    saltp = RSTRING_PTR(salt);
    if (!saltp[0] || !saltp[1]) goto short_salt;
#ifdef BROKEN_STRING_CRYPT
    if (!ISASCII((unsigned char)saltp[0]) || !ISASCII((unsigned char)saltp[1])) {
	salt_8bit_clean[0] = saltp[0] & 0x7f;
	salt_8bit_clean[1] = saltp[1] & 0x7f;
	salt_8bit_clean[2] = '\0';
	saltp = salt_8bit_clean;
    }
#endif
#ifdef HAVE_STRING_CRYPT_R
    data = ALLOCV(databuf, sizeof(struct crypt_data));
# ifdef HAVE_STRUCT_STRING_CRYPT_DATA_INITIALIZED
    data->initialized = 0;
# endif
    res = crypt_r(s, saltp, data);
#else
    res = crypt(s, saltp);
#endif
    if (!res) {
	int err = errno;
	STRING_CRYPT_END();
	rb_syserr_fail(err, "crypt");
    }
    result = rb_str_new_cstr(res);
    STRING_CRYPT_END();
    FL_SET_RAW(result, OBJ_TAINTED_RAW(str) | OBJ_TAINTED_RAW(salt));
    return result;
}

void Init_crypt(void) {
    rb_eval_string("class String; remove_method(:crypt) if instance_methods(false).include?(:crypt); end");
    rb_define_method(rb_cString, "crypt", rb_string_crypt, 1);
}

require 'mkmf'

if ENV['STRING_CRYPT_FORCE_MISSING'] == '1'
  puts "forcing internal DES-crypt implementation"
else
  if /darwin/ =~ RUBY_PLATFORM && try_run(<<END)
#include <stdio.h>
#include <unistd.h>
#include <string.h>

void
broken_crypt(const char *salt, const char *buf1, const char *buf2)
{
#if 0
    printf("%.2x%.2x: %s -> %s\n", (unsigned char)salt[0], (unsigned char)salt[1],
	   buf1+2, buf2+2);
#endif
}

int
main()
{
    int i;
    char salt[2], buf[256], *s;
    for (i = 0; i < 128*128; i++) {
	salt[0] = 0x80 | (i & 0x7f);
	salt[1] = 0x80 | (i >> 7);
	strcpy(buf, crypt("", salt));
	if (strcmp(buf, s = crypt("", salt))) {
	    broken_crypt(salt, buf, s);
	    return 1;
	}
    }
    salt[0] = salt[1] = ' ';
    strcpy(buf, crypt("", salt));
    salt[0] = salt[1] = 0x80 | ' ';
    if (strcmp(buf, s = crypt("", salt))) {
	broken_crypt(salt, buf, s);
	return 1;
    }
    return 0;
}
END
    $defs << "-DBROKEN_CRYPT"
  end

  if have_header('crypt.h')
    have_struct_member("struct crypt_data", "initialized", "crypt.h")
  end

  have_library('crypt', 'crypt')
  have_func('crypt_r')
  have_func('crypt')
end

# Rename variables so variables from ruby/config.h are not picked up.
if $defs
  $defs.map!{|s| s.sub('CRYPT', 'STRING_CRYPT')}
end

create_makefile 'string/crypt'

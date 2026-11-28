#!/bin/sh
set -eu
cd "$(dirname "$0")/../.."
tmp=$(mktemp -d "${TMPDIR:-/tmp}/spinel-cext-header.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
${CC:-cc} -std=c11 -Wall -Wextra -Werror -fsanitize=undefined -Iinclude test/cext/immediates.c -o "$tmp/immediates"
# what CRuby's ruby.h brings in: a -std=c11 extension reads the clock, its pid and bool (sqlite3)
cat > "$tmp/libc.c" <<'EOF'
#include <ruby.h>
struct deadline { struct timespec at; rb_pid_t owner; bool armed; };
int main(void) {
    struct deadline d;
    d.owner = getpid();
    d.armed = clock_gettime(CLOCK_MONOTONIC, &d.at) == 0;
    return d.armed && d.owner > 0 ? 0 : 1;
}
EOF
${CC:-cc} -std=c11 -Wall -Wextra -Werror -Iinclude "$tmp/libc.c" -o "$tmp/libc"
"$tmp/libc"
# and the C library headers it includes: an extension calls memcpy, calloc, snprintf, isspace and errno with no include of its own (ed25519, lz4-ruby)
cat > "$tmp/clib.c" <<'EOF'
#include <ruby.h>
static int sum(int n, ...) { va_list ap; int t = 0; va_start(ap, n); while (n-- > 0) t += va_arg(ap, int); va_end(ap); return t; }
int main(void) {
    char buf[16], *copy = calloc(4, 1);
    errno = 0;
    memcpy(copy, "ab", 3);
    snprintf(buf, sizeof buf, "%s%d", copy, sum(2, 1, 2));
    free(copy);
    return strcmp(buf, "ab3") == 0 && isspace(' ') && strcasecmp("A", "a") == 0 && errno == 0 ? 0 : 1;
}
EOF
${CC:-cc} -std=c11 -Wall -Wextra -Werror -Iinclude "$tmp/clib.c" -o "$tmp/clib"
"$tmp/clib"
"$tmp/immediates"
for api in RBASIC ROBJECT RSTRUCT; do
    printf '#include <ruby.h>\nint main(void) { return %s(Qnil) != 0; }\n' "$api" > "$tmp/refuse.c"
    if ${CC:-cc} -O2 -Iinclude -c "$tmp/refuse.c" -o "$tmp/refuse.o" > "$tmp/error" 2>&1; then
        echo "cext-header-test: FAIL ($api accepted)"; exit 1
    fi
    grep -q "CRuby object layout is not provided" "$tmp/error"
done
printf '#include <ruby.h>\nint main(void) { return (int)rb_eval_string("1"); }\n' > "$tmp/refuse.c"
if ${CC:-cc} -O2 -Iinclude -c "$tmp/refuse.c" -o "$tmp/refuse.o" > "$tmp/error" 2>&1; then
    echo 'cext-header-test: FAIL (eval accepted)'; exit 1
fi
grep -q 'Ruby eval requires' "$tmp/error"
echo 'cext-header-test: pass'

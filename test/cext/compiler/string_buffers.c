#include <ruby.h>
#include <string.h>

/* lz4-ruby's shape: room for the most it can write, the bytes written through
   RSTRING_PTR, then the String cut to what was written */
static VALUE fill(VALUE self, VALUE count) {
    (void)self;
    long n = NUM2LONG(count);
    VALUE out = rb_str_new(NULL, 0);
    rb_str_resize(out, n + 8);
    char *p = RSTRING_PTR(out);
    for (long i = 0; i < n; i++) p[i] = (char)('a' + i % 26);
    rb_str_resize(out, n);
    return out;
}

static VALUE grow(VALUE self, VALUE text) {
    (void)self;
    rb_str_resize(text, RSTRING_LEN(text) + 2);
    return rb_str_new(RSTRING_PTR(text), RSTRING_LEN(text));
}

/* xorcist's shape: modified in place after rb_str_modify */
static VALUE xor_in_place(VALUE self, VALUE text, VALUE key) {
    (void)self;
    rb_str_modify(text);
    char *p = RSTRING_PTR(text);
    unsigned char k = (unsigned char)NUM2CHR(key);
    for (long i = 0; i < RSTRING_LEN(text); i++) p[i] = (char)(p[i] ^ k);
    return text;
}

static VALUE reserved(VALUE self) {
    (void)self;
    VALUE out = rb_str_buf_new(64);
    return rb_ary_new_from_args(2, rb_funcall(rb_funcall(out, rb_intern("encoding"), 0), rb_intern("to_s"), 0), LONG2NUM(RSTRING_LEN(out)));
}

static VALUE buffered(VALUE self) {
    (void)self;
    VALUE out = rb_str_buf_new(64);
    rb_str_modify_expand(out, 16);
    memcpy(RSTRING_PTR(out), "buffered", 8);
    rb_str_set_len(out, 8);
    return rb_ary_new_from_args(2, out, LONG2NUM(RSTRING_LEN(out)));
}

static VALUE to_uint(VALUE self, VALUE n) { (void)self; return UINT2NUM(NUM2UINT(n)); }
static VALUE to_ushort(VALUE self, VALUE n) { (void)self; return INT2NUM(NUM2USHORT(n)); }
static VALUE to_short(VALUE self, VALUE n) { (void)self; return INT2NUM(NUM2SHORT(n)); }
static VALUE chr(VALUE self, VALUE v) { (void)self; return INT2NUM((unsigned char)NUM2CHR(v)); }
static VALUE quiet(VALUE self) { (void)self; rb_warning("verbose only %d", 1); return Qnil; }

void Init_string_buffers(void) {
    VALUE mod = rb_define_module("Buffers");
    rb_define_module_function(mod, "fill", fill, 1);
    rb_define_module_function(mod, "grow", grow, 1);
    rb_define_module_function(mod, "xor_in_place", xor_in_place, 2);
    rb_define_module_function(mod, "buffered", buffered, 0);
    rb_define_module_function(mod, "reserved", reserved, 0);
    rb_define_module_function(mod, "uint", to_uint, 1);
    rb_define_module_function(mod, "ushort", to_ushort, 1);
    rb_define_module_function(mod, "sshort", to_short, 1);
    rb_define_module_function(mod, "chr", chr, 1);
    rb_define_module_function(mod, "quiet", quiet, 0);
}

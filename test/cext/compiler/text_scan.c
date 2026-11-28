#include <ruby.h>
#include <ruby/encoding.h>
#include <ruby/re.h>
#include <ruby/version.h>

/* fast_blank's and jaro_winkler's shape: a String walked character by
   character between RSTRING_PTR and RSTRING_END */
static VALUE codepoints(VALUE self, VALUE str) {
    (void)self;
    rb_encoding *enc = rb_enc_from_index(ENCODING_GET(str));
    const char *s = RSTRING_PTR(str), *e = RSTRING_END(str);
    VALUE out = rb_ary_new();
    while (s < e) {
        int n;
        unsigned int cc = rb_enc_codepoint_len(s, e, &n, enc);
        rb_ary_push(out, rb_ary_new_from_args(2, ULONG2NUM(cc), INT2NUM(n)));
        s += n;
    }
    return out;
}

static VALUE blank(VALUE self, VALUE str) {
    (void)self;
    rb_encoding *enc = rb_enc_get(str);
    const char *s = RSTRING_PTR(str), *e = RSTRING_END(str);
    while (s < e) {
        int n;
        unsigned int cc = rb_enc_codepoint_len(s, e, &n, enc);
        if (!rb_isspace(cc) && cc != 0) return Qfalse;
        s += n;
    }
    return Qtrue;
}

static VALUE empty_codepoint(VALUE self, VALUE str) {
    (void)self;
    int n;
    return ULONG2NUM(rb_enc_codepoint_len(RSTRING_PTR(str), RSTRING_PTR(str), &n, rb_enc_get(str)));
}

static VALUE widest(VALUE self, VALUE str) {
    (void)self;
    rb_encoding *enc = rb_enc_get(str);
    return rb_ary_new_from_args(2, rb_str_new_cstr(rb_enc_name(enc)), INT2NUM(rb_enc_mbmaxlen(enc)));
}

/* idn-ruby's shape: a C buffer back as UTF-8, and its argument converted with to_s */
static VALUE utf8(VALUE self, VALUE bytes) {
    (void)self;
    VALUE out = rb_enc_str_new(RSTRING_PTR(bytes), RSTRING_LEN(bytes), rb_utf8_encoding());
    return rb_ary_new_from_args(2, out, rb_str_new_cstr(rb_enc_name(rb_enc_get(out))));
}

static VALUE to_s(VALUE self, VALUE value) {
    (void)self;
    return rb_check_convert_type(value, T_STRING, "String", "to_s");
}

static VALUE frozen(VALUE self, VALUE str) {
    (void)self;
    VALUE copy = rb_str_new_frozen(str);
    return rb_ary_new_from_args(4, copy, RTEST(rb_funcall(copy, rb_intern("frozen?"), 0)) ? Qtrue : Qfalse,
        copy == str ? Qtrue : Qfalse, rb_str_new_cstr(rb_enc_name(rb_enc_get(copy))));
}

static VALUE arity(VALUE self, VALUE given, VALUE min, VALUE max) {
    (void)self;
    rb_error_arity(NUM2INT(given), NUM2INT(min), NUM2INT(max));
}

static VALUE api_version(VALUE self) {
    (void)self;
    return INT2NUM(RUBY_API_VERSION_CODE >= 30000);
}

void Init_text_scan(void) {
    VALUE mod = rb_define_module("TextScan");
    rb_define_module_function(mod, "codepoints", codepoints, 1);
    rb_define_module_function(mod, "blank", blank, 1);
    rb_define_module_function(mod, "empty_codepoint", empty_codepoint, 1);
    rb_define_module_function(mod, "widest", widest, 1);
    rb_define_module_function(mod, "utf8", utf8, 1);
    rb_define_module_function(mod, "to_s", to_s, 1);
    rb_define_module_function(mod, "frozen", frozen, 1);
    rb_define_module_function(mod, "arity", arity, 3);
    rb_define_module_function(mod, "api_version", api_version, 0);
}

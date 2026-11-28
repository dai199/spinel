#ifndef SPINEL_RUBY_RE_H
#define SPINEL_RUBY_RE_H
#include <ruby.h>
/* CRuby's Regexp API (rb_reg_*, RMATCH) is not provided: a call to it fails the
 * extension's compilation and names the function. An extension that includes
 * the header only for the encoding API it pulls in (fast_blank) builds. */
#include <ruby/encoding.h>
#endif

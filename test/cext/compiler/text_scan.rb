# frozen_string_literal: true
require_relative 'text_scan'

p TextScan.codepoints("aé€😀")
p TextScan.codepoints("\xff\x41".b)
["\xff", "\xe2\x82", "\xc0\xaf", "\xed\xa0\x80"].each do |bad|
  begin
    TextScan.codepoints(bad.dup.force_encoding("UTF-8"))
  rescue ArgumentError => e
    p e.message
  end
end
begin
  TextScan.empty_codepoint(+"")
rescue ArgumentError => e
  p e.message
end
p [TextScan.blank(" \t\n\r\v\f"), TextScan.blank(" x "), TextScan.blank(+"")]
p [TextScan.widest(+"a"), TextScan.widest("a".b)]
p TextScan.utf8("caf\xc3\xa9".b)

class Named
  def to_s = "named"
end
class Wrong
  def to_s = 42
end
p TextScan.to_s("as is")
p TextScan.to_s(7)
p TextScan.to_s(Named.new)
begin
  TextScan.to_s(Wrong.new)
rescue TypeError => e
  p e.message
end

open = +"open"
copy, frozen, same, enc = TextScan.frozen(open)
p [copy, frozen, same, enc, open.frozen?]
p TextScan.frozen("lit".b)[1..]
[[0, 1, 1], [3, 1, -1], [5, 0, 2]].each do |given, min, max|
  begin
    TextScan.arity(given, min, max)
  rescue ArgumentError => e
    p e.message
  end
end
p TextScan.api_version

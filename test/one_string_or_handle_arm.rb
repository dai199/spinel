# A String kept through `||` beside an arm that builds one (format), and a
# gsub block whose value is a String `||` another: one answer in every
# String representation.
ESC = { "\"" => "\\\"", "\n" => "\\n" }.freeze

def quote(s)
  e = s.gsub(/["\\\x00-\x1f]/) { |c| ESC[c] || format("\\u%04x", c.ord) }
  "\"#{e}\""
end

c = "q"
puts(c || format("%d", 1))
n = nil
puts(n || format("%d", 2))
puts "xa".gsub(/a/) { |m| m || "z" }
puts quote("a\"b\nc\x01")

# A conditional whose result is a handle (it is pushed into a String Array)
# with arms that build bytes.
def ident(s) = s
pairs = []
v = 1
k = "x"
pairs << (v.nil? ? "#{ident(k)}" : "#{ident(k)}=#{ident(v.to_s)}")
puts pairs.join("&")

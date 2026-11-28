# frozen_string_literal: true
require_relative 'string_buffers'

filled = Buffers.fill(30)
p [filled, filled.bytesize, filled.encoding.to_s]
p Buffers.fill(0)
text = +"ab"
p Buffers.grow(text).bytes.first(2)
p text.bytesize
secret = +"hello"
same = Buffers.xor_in_place(secret, 1)
p [secret, same.equal?(secret)]
Buffers.xor_in_place(secret, "\x01")
p secret
begin
  Buffers.xor_in_place("frozen".freeze, 1)
rescue FrozenError => e
  p e.class
end
p Buffers.buffered
p Buffers.reserved
p Buffers.uint(4_294_967_295)
p Buffers.uint(-1)
[4_294_967_296, -2_147_483_649].each do |n|
  begin
    Buffers.uint(n)
  rescue RangeError => e
    p e.message
  end
end
p [Buffers.ushort(65_535), Buffers.ushort(-1), Buffers.sshort(-32_768)]
[65_536, -32_769].each do |n|
  begin
    Buffers.ushort(n)
  rescue RangeError => e
    p e.message
  end
end
begin
  Buffers.sshort(32_768)
rescue RangeError => e
  p e.message
end
p [Buffers.chr("A"), Buffers.chr(321)]
p Buffers.quiet

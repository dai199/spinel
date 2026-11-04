# A zone typed String that is nil when it runs reads local time, as CRuby
# reads a nil zone: Time.new's in: and 7th positional, Time.at/now's in:,
# and getlocal/localtime.
zone = ARGV.empty? ? nil : "UTC"
local = Time.new(2026, 11, 4, 10, 20, 30).utc_offset
puts Time.new(2026, 11, 4, 10, 20, 30, in: zone).utc_offset == local
puts Time.new(2026, 11, 4, 10, 20, 30, zone).utc_offset == local
puts Time.new("2026-11-04 10:20:30", in: zone).utc_offset == local
puts Time.at(0, in: zone).utc_offset == Time.at(0).utc_offset
puts Time.now(in: zone).utc_offset == Time.now.utc_offset
puts Time.at(0).utc.getlocal(zone).utc_offset == Time.at(0).utc_offset
puts Time.at(0).utc.localtime(zone).utc?

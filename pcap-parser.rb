require 'packetfu'

if ARGV.length == 0
  puts "Please specify a filename"
  Process.exit
end

filename = ARGV[0]
packets = PacketFu::PcapFile.file_to_array filename

packets.each do |packet|
  pkt = PacketFu::Packet.parse(packet)
end
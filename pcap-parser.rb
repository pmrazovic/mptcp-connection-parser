require 'packetfu'
require './mptcp_options_parser'

if ARGV.length == 0
  puts "Please specify a filename"
  Process.exit
end

filename = ARGV[0]
packets = PacketFu::PcapFile.file_to_array filename

mptcp_connections = 0
packets.each do |packet|

    pkt = PacketFu::Packet.parse(packet)
    if pkt.kind_of?(PacketFu::TCPPacket)
      tcp_options = PacketFu::TcpOptions.new
      tcp_options.read(pkt.tcp_opts).select{|opt| opt.kind.value == 30}.each do |mp_option|
        option_parsed = MPTCPOptionsParser.parse(mp_option.value)
        if option_parsed[:subtype] == 'MP_CAPABLE' && pkt.tcp_flags.ack == 1
          mptcp_connections += 1
        end
      end
    end

end

puts mptcp_connections
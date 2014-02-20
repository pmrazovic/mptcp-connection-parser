require 'packetfu'
require './mptcp_options_parser'

MPTCPConnection = Struct.new(:ip_saddr, :ip_daddr, :sport, :dport, :senders_key, :receivers_key) {}

if ARGV.length == 0
  puts "Please specify a filename"
  Process.exit
end

filename = ARGV[0]
packets = PacketFu::PcapFile.file_to_array filename

mptcp_connections = Array.new
packets.each do |packet|
  
  pkt = PacketFu::Packet.parse(packet)
  if pkt.kind_of?(PacketFu::TCPPacket)
    tcp_options = PacketFu::TcpOptions.new
    tcp_options.read(pkt.tcp_opts).select{|opt| opt.kind.value == 30}.each do |mp_option|
      option_parsed = MPTCPOptionsParser.parse(mp_option.value)
      if option_parsed[:subtype] == 'MP_CAPABLE' && pkt.tcp_flags.ack == 1 && pkt.tcp_flags.syn == 0
        new_mptcp_connection = MPTCPConnection.new(pkt.ip_saddr, pkt.ip_daddr, pkt.tcp_src, pkt.tcp_dst, option_parsed[:senders_key], option_parsed[:receivers_key])
        mptcp_connections << new_mptcp_connection  
      end
    end
  end

end

mptcp_connections.each do |conn|
  puts "< (#{conn.ip_saddr}, #{conn.sport}), (#{conn.ip_daddr}, #{conn.dport}) >"
  puts "Sender's key: #{conn.senders_key}"
  puts "Receiver's key: #{conn.receivers_key}"
  puts "-------------------------------------"
end
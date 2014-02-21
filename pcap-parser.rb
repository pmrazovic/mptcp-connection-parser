require 'packetfu'
require './mptcp_options_parser'
require './mptcp_connection'
require './mptcp_subflow'

if ARGV.length == 0
  puts "Please specify a filename"
  Process.exit
end

filename = ARGV[0]
packets = PacketFu::PcapFile.file_to_array filename
mptcp_connections = Array.new

read_packets_start = Time.now.utc
puts "Reading packets..."

packets.each do |packet|
  pkt = PacketFu::Packet.parse(packet)
  if pkt.kind_of?(PacketFu::TCPPacket)
    tcp_options = PacketFu::TcpOptions.new
    tcp_options.read(pkt.tcp_opts).select{|opt| opt.kind.value == 30}.each do |mp_option|
      
      option_parsed = MPTCPOptionsParser.parse(mp_option.value)
      if option_parsed[:subtype] == 'MP_CAPABLE' && pkt.tcp_flags.ack == 1 && pkt.tcp_flags.syn == 0
        new_connection = MPTCPConnection.new(pkt.ip_saddr,  
                                                   pkt.tcp_src, 
                                                   pkt.ip_daddr, 
                                                   pkt.tcp_dst, 
                                                   option_parsed[:senders_key], 
                                                   option_parsed[:receivers_key])
        mptcp_connections << new_connection
      elsif option_parsed[:subtype] == 'MP_JOIN' && pkt.tcp_flags.ack == 0 && pkt.tcp_flags.syn == 1
        new_subflow = MPTCPSubflow.new(pkt.ip_saddr, 
                                             pkt.tcp_src,
                                             pkt.ip_daddr,
                                             pkt.tcp_dst,
                                             option_parsed[:receivers_token])
        belonging_conn = mptcp_connections.select{|conn| conn.receivers_token == new_subflow.token}.first
        belonging_conn.add_subflow(new_subflow)

      end
    end
  end
end

puts "Finished in #{Time.now.utc - read_packets_start} seconds."

mptcp_connections.each do |connection|
  connection.print
  connection.subflows.each_value{ |subflow| subflow.print }
end
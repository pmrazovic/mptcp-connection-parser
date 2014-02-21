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

packets.each do |pkt|
  packet = PacketFu::Packet.parse(pkt)
  tcp_header = packet.headers.select{|h| h.kind_of?(PacketFu::TCPHeader)}.first

  unless tcp_header.nil?
    tcp_options = PacketFu::TcpOptions.new
    tcp_options.read(tcp_header.tcp_opts).select{|opt| opt.kind.value == 30}.each do |mp_option|
      
      option_parsed = MPTCPOptionsParser.parse(mp_option.value)
      if option_parsed[:subtype] == 'MP_CAPABLE' && packet.tcp_flags.ack == 1 && packet.tcp_flags.syn == 0
        new_connection = MPTCPConnection.new(packet.ip_saddr,  
                                                   packet.tcp_src, 
                                                   packet.ip_daddr, 
                                                   packet.tcp_dst, 
                                                   option_parsed[:senders_key], 
                                                   option_parsed[:receivers_key])
        mptcp_connections << new_connection
      elsif option_parsed[:subtype] == 'MP_JOIN' && packet.tcp_flags.ack == 0 && packet.tcp_flags.syn == 1
        new_subflow = MPTCPSubflow.new(packet.ip_saddr, 
                                             packet.tcp_src,
                                             packet.ip_daddr,
                                             packet.tcp_dst,
                                             option_parsed[:receivers_token])
        belonging_conn = mptcp_connections.select{|conn| [conn.receivers_token, conn.senders_token].include?(new_subflow.token)}.first
        belonging_conn.add_subflow(new_subflow)
      elsif option_parsed[:subtype] == 'DSS'
        mptcp_connections.each do |conn|
          belonging_subflow = conn.get_subflow(packet.ip_saddr, packet.tcp_src, packet.ip_daddr, packet.tcp_dst)
          belonging_subflow.total_payload += packet.payload.bytes.length unless belonging_subflow.nil?
        end        
      end
    end
  end
end

puts "Finished in #{Time.now.utc - read_packets_start} seconds."

mptcp_connections.each do |conn|
  conn.print
  conn.subflows.each_value{ |subflow| subflow.print }
end
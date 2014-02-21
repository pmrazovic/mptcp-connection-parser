class MPTCPSubflow
  attr_accessor :ip_saddr
  attr_accessor :sport
  attr_accessor :ip_daddr
  attr_accessor :dport
  attr_accessor :token_bytes
  attr_accessor :total_payload

  def initialize(ip_saddr, sport, ip_daddr, dport, token_bytes = nil)
    @ip_saddr = ip_saddr
    @sport = sport
    @ip_daddr = ip_daddr
    @dport = dport
    @token_bytes = token_bytes
    @total_payload = 0
    @state = "ESTABLISHED"
  end

  def token
    @token_bytes.pack("c*").unpack("H*").first.to_i(16)
  end

  def print
    puts "------------------------------MPTCPSubflow-------------------------------"
    puts "(#{@ip_saddr}, #{@sport}) <---> (#{@ip_daddr}, #{@dport})"
    puts "Token: #{token}"
  end

end
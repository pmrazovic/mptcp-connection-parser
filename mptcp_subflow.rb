class MPTCPSubflow
  attr_accessor :ip_saddr
  attr_accessor :sport
  attr_accessor :ip_daddr
  attr_accessor :dport
  attr_accessor :token_bytes
  attr_accessor :host_trunc_HMAC_bytes
  attr_accessor :client_HMAC_bytes
  attr_accessor :total_payload
  attr_accessor :status
  attr_accessor :initial_subflow
  attr_accessor :packets_exchanged

  def initialize(ip_saddr, sport, ip_daddr, dport, initial_subflow, token_bytes = nil)
    @ip_saddr = ip_saddr
    @sport = sport
    @ip_daddr = ip_daddr
    @dport = dport
    @initial_subflow = initial_subflow
    @token_bytes = token_bytes
    @total_payload = 0
    @status = @initial_subflow ? "ACK" : "SYN"
    @packets_exchanged = 1
  end

  def token
    @token_bytes.pack("c*").unpack("H*").first.to_i(16)
  end

  def host_trunc_HMAC
    @host_trunc_HMAC_bytes.pack("c*").unpack("H*").first.to_i(16)
  end

  def client_HMAC
    @client_HMAC_bytes.pack("c*").unpack("H*").first.to_i(16)
  end  

  def print
    puts "------------------------------MPTCPSubflow-------------------------------"
    puts "(#{@ip_saddr}, #{@sport}) <---> (#{@ip_daddr}, #{@dport})"
    puts "(initial subflow)" if @initial_subflow
    puts "Status:".ljust(20, ' ') + " #{@status}"
    unless @initial_subflow
      puts "Token:".ljust(20, ' ') + " #{token}"
      puts "Host truncated HMAC:".ljust(20, ' ') + " #{host_trunc_HMAC}"
      puts "Client HMAC:".ljust(20, ' ') + " #{client_HMAC}"
    end
    puts "Total payload:".ljust(20, ' ') + " #{@total_payload} Bytes"
    puts "Packets exchanged:".ljust(20, ' ') + " #{@packets_exchanged}"
  end

end
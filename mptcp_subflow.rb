class MPTCPSubflow
  attr_accessor :ip_saddr
  attr_accessor :sport
  attr_accessor :ip_daddr
  attr_accessor :dport
  attr_accessor :token
  attr_accessor :total_payload

  def initialize(ip_saddr, sport, ip_daddr, dport, token = nil)
    @ip_saddr = ip_saddr
    @sport = sport
    @ip_daddr = ip_daddr
    @dport = dport
    @token = token
    @total_payload = 0
    @state = "ESTABLISHED"
  end

  def print
    puts "MPTCPSubflow -------------------------------"
    puts "(#{@ip_saddr}, #{@sport}) <---> (#{@ip_daddr}, #{@dport})"
    puts "--------------------------------------------"
  end

end
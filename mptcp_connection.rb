require 'digest/sha1'

class MPTCPConnection
  attr_accessor :ip_saddr
  attr_accessor :sport
  attr_accessor :ip_daddr
  attr_accessor :dport
  attr_accessor :senders_key
  attr_accessor :receivers_key
  attr_accessor :subflows
  attr_accessor :total_payload

  def initialize(ip_saddr, sport, ip_daddr, dport, senders_key, receivers_key)
    @ip_saddr = ip_saddr
    @sport = sport
    @ip_daddr = ip_daddr
    @dport = dport
    @senders_key = senders_key
    @receivers_key = receivers_key
    @subflows = Hash.new
    @total_payload = 0
    @state = "ESTABLISHED"
    add_initial_subflow
  end

  def add_subflow(subflow)
    @subflows[{:ip_saddr => subflow.ip_saddr, 
               :sport => subflow.sport, 
               :ip_daddr => subflow.ip_daddr, 
               :dport => subflow.dport}] = subflow
  end

  def get_subflow(ip_saddr, sport, ip_daddr, dport)
    @subflows[{:ip_saddr => ip_saddr, 
               :sport => sport, 
               :ip_daddr => ip_daddr, 
               :dport => dport}]
  end

  def add_initial_subflow
    initial_subflow = MPTCPSubflow.new(@ip_saddr, 
                                       @sport,
                                       @ip_daddr,
                                       @dport)
    add_subflow(initial_subflow)
  end

  def senders_token
    Digest::SHA1.hexdigest(@senders_key.pack("c*"))[0, 8].to_i(16)
  end

  def receivers_token
    Digest::SHA1.hexdigest(@receivers_key.pack("c*"))[0, 8].to_i(16)
  end      

  def print
    puts "+-----------------------------------------------------------------------+"
    puts "|                            MPTCPConnection                            |"
    puts "+-----------------------------------------------------------------------+"
    puts "(#{@ip_saddr}, #{@sport}) <---> (#{@ip_daddr}, #{@dport})"
    puts "Sender's token: #{senders_token}"
    puts "Receiver's token: #{receivers_token}"
  end

end
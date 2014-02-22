require 'digest/sha1'

class MPTCPConnection
  attr_accessor :ip_saddr
  attr_accessor :sport
  attr_accessor :ip_daddr
  attr_accessor :dport
  attr_accessor :senders_key
  attr_accessor :receivers_key
  attr_accessor :subflows

  def initialize(ip_saddr, sport, ip_daddr, dport, senders_key, receivers_key)
    @ip_saddr = ip_saddr
    @sport = sport
    @ip_daddr = ip_daddr
    @dport = dport
    @senders_key = senders_key
    @receivers_key = receivers_key
    @subflows = Hash.new
    add_initial_subflow
  end

  def add_subflow(subflow)
    if get_subflow(subflow.ip_saddr, subflow.sport, subflow.ip_daddr, subflow.dport).nil?
      @subflows[{:ip_saddr => subflow.ip_saddr, 
                 :sport => subflow.sport, 
                 :ip_daddr => subflow.ip_daddr, 
                 :dport => subflow.dport}] = subflow
    end
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
                                       @dport,
                                       true)
    add_subflow(initial_subflow)
  end

  def status
    get_subflow(@ip_saddr, @sport, @ip_daddr, @dport).status
  end

  def senders_token
    Digest::SHA1.hexdigest(@senders_key.pack("c*"))[0, 8].to_i(16)
  end

  def receivers_token
    Digest::SHA1.hexdigest(@receivers_key.pack("c*"))[0, 8].to_i(16)
  end   

  def total_payload
    total_payload_bytes = 0
    @subflows.each_value do |subflow|
      total_payload_bytes += subflow.total_payload
    end
    total_payload_bytes
  end   

  def print
    puts "+-----------------------------------------------------------------------+"
    puts "|                            MPTCPConnection                            |"
    puts "+-----------------------------------------------------------------------+"
    puts "(#{@ip_saddr}, #{@sport}) <---> (#{@ip_daddr}, #{@dport})"
    puts "Status:".ljust(20, ' ') + " #{status}"
    puts "Client token:".ljust(20, ' ') + " #{senders_token}"
    puts "Host token:".ljust(20, ' ') +  " #{receivers_token}"
    puts "Total payload:".ljust(20, ' ') + " #{total_payload} Bytes"
  end

end
module MPTCPOptionsParser
  def self.parse(byte_string)
    bytes = byte_string.bytes.to_a.collect{ |b| b.to_s(16).rjust(2,'0') }
    options_hash = Hash.new
    puts bytes.inspect
    # Subtype definition
    case bytes[0][0]
    when "0"
      options_hash = self.parse_mp_capable(bytes)
    when "1"
      options_hash = self.parse_mp_join(bytes)
    when "2"
      #options_hash[:subtype] = "DSS"
    when "3"
      #options_hash[:subtype] = "ADD_ADDR"
    when "4"
      #options_hash[:subtype] = "REMOVE_ADDR"
    when "5"
      #options_hash[:subtype] = "MP_PRIO"
    when "6"
      #options_hash[:subtype] = "MP_FAIL"
    when "7"
      #options_hash[:subtype] = "MP_FASTCLOSE"
    else
      #options_hash[:subtype] = "UNKNOWN"
    end

    return options_hash
  end

  def self.parse_mp_capable(bytes)
    options_hash = Hash.new
    options_hash[:kind] = "MPTCP Connection"
    options_hash[:length] = bytes.length + 2    
    options_hash[:subtype] = "MP_CAPABLE"
    options_hash[:version] = bytes[0][1].to_i(16)
    options_hash[:flags] = Hash.new
    flags_bits = bytes[1].to_i(16).to_s(2).rjust(8, '0')
    options_hash[:flags][:a] = flags_bits[0]
    options_hash[:flags][:b] = flags_bits[1]
    options_hash[:flags][:c] = flags_bits[2]
    options_hash[:flags][:d] = flags_bits[3]
    options_hash[:flags][:e] = flags_bits[4]
    options_hash[:flags][:f] = flags_bits[5]
    options_hash[:flags][:g] = flags_bits[6]
    options_hash[:flags][:h] = flags_bits[7]
    options_hash[:senders_key] = bytes[2..9].join.to_i(16)
    if options_hash[:length] == 20    
      options_hash[:receivers_key] = bytes[10..17].join.to_i(16)
    end

    return options_hash
  end

  def self.parse_mp_join(bytes)
    options_hash = Hash.new
    options_hash[:kind] = "MPTCP Connection"
    options_hash[:length] = bytes.length + 2    
    options_hash[:subtype] = "MP_JOIN"
    case options_hash[:length]
    when 12
      options_hash[:flags] = Hash.new
      options_hash[:flags][:b] = bytes[0][1].to_i(16).to_s(2).rjust(4, '0')[-1]
      options_hash[:address_id] = bytes[1].to_i(16)
      options_hash[:receivers_token] = bytes[2..5].join.to_i(16)
      options_hash[:senders_random_number] = bytes[6..9].join.to_i(16)
    when 16
      options_hash[:flags] = Hash.new
      options_hash[:flags][:b] = bytes[0][1].to_i(16).to_s(2).rjust(4, '0')[-1]
      options_hash[:address_id] = bytes[1].to_i(16)
      options_hash[:senders_trunc_HMAC] = bytes[2..9].join.to_i(16)
      options_hash[:senders_random_number] = bytes[10..13].join.to_i(16)
    when 24
      options_hash[:senders_HMAC] = bytes[2..21].join.to_i(16)
    end

    return options_hash
  end  
end
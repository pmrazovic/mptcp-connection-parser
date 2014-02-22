MPTCP Connection Parser
=======================

## Instructions

1. Install PacketFu gem by running `gem install packetfu -v 1.1.10` or `bundle install` in project's folder (libcap is required `sudo apt-get install libpcap-dev`)
2. Run the program with `ruby pcap-parser.rb <pcap_file_name>`. Example: `ruby pcap-parser.rb mptcp-test-capture.pcap`
3. Wait... It takes some time to process large pcap packet trace.

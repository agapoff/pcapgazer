PCAPgazer
=========

This app parses PCAP-files looking for TCP retransmits and writes the data (addresses and TCP ports) to a file or to Elasticsearch. The output methods are implemented as modules so the pcapgazer's functionality can be easily extended without any intervention to the main code.

The project is structured for building the RPM-package. But you can easily use it as a standalone application. Just copy everything from the src folder and you're done.

### Build the RPM package

1. Edit the SPEC-file if needed.
2. Run rpmbuild. For example:
```
tar cvzf pcapgazer.tar.gz --exclude=*/.git pcapgazer
rpmbuild -ta pcapgazer.tar.gz
```
3. PROFIT!!!

### Prerequisites

All the needed Perl modules will be installed by dependencies if you are using the RPM package. Otherwise preinstall the following modules:

* Net::Pcap
* NetPacket::Ethernet
* NetPacket::IP
* NetPacket::UDP
* NetPacket::TCP
* Data::Dumper
* LWP::UserAgent
* JSON

### Run the application

1. Edit config.ini for your needs.
2. To run it once manually:
```
./pcapgazer.pl somedump.cap
```
3. In order to execute the script for every captured dump-file run the tcpdump as follows:
```
tcpdump -nnpi any -W 50 -C 10 -w /tmp/dump <some-filter> -z /opt/pcapgazer/pcapgazer.pl
```


### Contributing

Anyone and everyone is welcome to contribute. 


## Issues

Found a bug or want to request a new feature? Please submit an Issue on this repo.


## License

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

http://www.gnu.org/copyleft/gpl.html

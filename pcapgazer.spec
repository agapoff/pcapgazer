%define release_version 1

%define _unpackaged_files_terminate_build 1

Summary: PCAPGazer
Name: pcapgazer
Version: 3.0
Release: %release_version
License: GPL2
Group: System Environment/Base
Vendor: quotix
Packager: v.agapov@quotix.com
BuildRoot: %_tmppath/%name-root
BuildArch: noarch
Requires: perl perl-Data-Dumper perl-JSON perl-libwww-perl perl-Net-Pcap perl-NetPacket

%description
PCAP Gazer

%prep

%install
%{__rm} -rf $RPM_BUILD_ROOT
%{__make} install DESTDIR=$RPM_BUILD_ROOT

%files

%defattr(-, root, root)
%attr(644, -, -) /etc/logrotate.d/pcapgazer
%attr(755, -, -) /opt/pcapgazer/
%attr(755, tcpdump, tcpdump) /var/log/pcapgazer/
%attr(755, -, -) /opt/pcapgazer/pcapgazer.pl
%attr(644, -, -) /opt/pcapgazer/Output/*
%config(noreplace) %attr(644, -, -) /opt/pcapgazer/config.ini

%pre

%post

%changelog

* Fri Sep 18 2020 Vitaly Agapov <agapov.vitaly@gmail.com> - 3.0-1
- Update for ES7

* Mon Jun 19 2017 Vitaly Agapov <agapov.vitaly@gmail.com> - 1.0-5
- Seq num is incremented even is PSH is not set

* Mon Nov 28 2016 Vitaly Agapov <agapov.vitaly@gmail.com> - 1.0-4
- Counter
- Sequence number not incremented on pure ACKs or on any empty segment

* Mon Nov 28 2016 Vitaly Agapov <agapov.vitaly@gmail.com> - 1.0-3
- Fix bug appearing when output is not an array
- Non-strict inequality for seqnums 

* Fri Nov 25 2016 Vitaly Agapov <agapov.vitaly@gmail.com> - 1.0-2
- Change owner for /var/log/pcapgazer

* Thu Nov 24 2016 Vitaly Agapov <agapov.vitaly@gmail.com> - 1.0-1
- Initial build

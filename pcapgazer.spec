# if you make changes, the it is advised to increment this number, and provide 
# a descriptive suffix to identify who owns or what the change represents
# e.g. release_version 2.MSW
%define release_version 1

# if you wish to compile an rpm without ibverbs support, compile like this...
# rpmbuild -ta glusterfs-1.3.8pre1.tar.gz --without ibverbs
%define with_ibverbs %{?_without_ibverbs:0}%{?!_without_ibverbs:1}

%define _unpackaged_files_terminate_build 0

Summary: PCAPGazer
Name: pcapgazer
Version: 1.0
Release: %release_version
License: GPL2
Group: System Environment/Base
Vendor: quotix
Packager: v.agapov@quotix.com
BuildRoot: %_tmppath/%name-root
BuildArch: noarch
Requires: perl perl-Data-Dumper perl-JSON perl-libwww-perl perl-Net-Pcap perl-NetPacket
Source: %name.tar.gz

%description
PCAP Gazer

%prep
# then -n argument says that the unzipped version is NOT %name-%version
#%setup -n %name-%version
%setup -n %name 

%install
%{__rm} -rf $RPM_BUILD_ROOT
%{__make} install DESTDIR=$RPM_BUILD_ROOT

%files

%defattr(-, root, root)
%attr(644, -, -) /etc/logrotate.d/pcapgazer
%attr(644, -, -) /usr/lib/systemd/system/pcapgazer.service
%attr(755, -, -) /opt/pcapgazer/
%attr(755, -, -) /var/log/pcapgazer/
%attr(755, -, -) /opt/pcapgazer/pcapgazer.pl
%attr(644, -, -) /opt/pcapgazer/Output/*
%config(noreplace) %attr(644, -, -) /opt/pcapgazer/config.ini


%pre

%post

%changelog
* Thu Nov 24 2016 Vitaly Agapov <agapov.vitaly@gmail.com> - 1.0-1
- Initial build

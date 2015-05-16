Summary: acpid Puppet Module
Name: pupmod-acpid
Version: 0.0.1
Release: 1
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Buildarch: noarch
Requires: simp-bootstrap >= 4.2.0
Requires: puppet
Obsoletes: pupmod-acpid-test

Prefix: /etc/puppet/environments/simp/modules

%description
This puppet module provides the basis for managing the ACPI daemon.

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/acpid

dirs='files lib manifests templates'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/acpid
done


%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/acpid

%files
%defattr(0640,root,puppet,0750)
%{prefix}/acpid

%post
#!/bin/sh

if [ -d %{prefix}/acpid/plugins ]; then
  /bin/mv %{prefix}/acpid/plugins %{prefix}/acpid/plugins.bak
fi

%postun
# Post uninstall stuff

%changelog
* Fri Jan 16 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 0.0.1-1
- Updated to require puppet

* Fri Apr 04 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 0.0.1-0
- Initial Release

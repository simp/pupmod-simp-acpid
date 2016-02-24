%define module_name acpid
%define base_name pupmod-%{module_name}

%{lua:
local variant = rpm.expand("%{_variant}")
local variant_version = nil

local foo = ""

local i = 0
for str in string.gmatch(variant,'[^-]+') do
  if i == 0 then
    variant = str
  elseif i == 1 then
    variant_version = str
  else
    break
  end

  i = i+1
end

rpm.define("variant " .. variant)

if variant == "pe" then
  rpm.define("puppet_user pe-puppet")
else
  rpm.define("puppet_user puppet")
end

if variant == "pe" then
  if variant_version and ( rpm.vercmp(variant_version,'4') >= 0 ) then
    rpm.define("_sysconfdir /etc/puppetlabs/code")
  else
    rpm.define("_sysconfdir /etc/puppetlabs/puppet")
  end
elseif variant == "p4" then
  rpm.define("_sysconfdir /etc/puppetlabs/code")
else
  rpm.define("_sysconfdir /etc/puppet")
end
}

Summary: %{module_name} Puppet Module
%if 0%{?_variant:1}
Name: %{base_name}-%{_variant}
%else
Name: %{base_name}
%endif

Version: 0.0.1
Release: 1
License: Apache License, Version 2.0
Group:     Applications/System
Source:    %{base_name}-%{version}-%{release}.tar.gz
BuildRoot: %{_tmppath}/%{base_name}-%{version}-%{release}-buildroot
BuildArch: noarch

%if "%{variant}" == "pe"
Requires: pe-puppet
%else
Requires: puppet
%endif

Prefix: %{_sysconfdir}/environments/simp/modules

%description
This puppet module provides the basis for managing the ACPI daemon.

%prep
%setup -q -n %{base_name}-%{version}

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}

rm -rf .git
rm -f *.lock
rm -rf spec/fixtures/modules

curdir=`pwd`
dirname=`basename $curdir`
cp -r ../$dirname %{buildroot}/%{prefix}/%{module_name}

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}

%files
%defattr(0640,root,%{puppet_user},0750)
%{prefix}/%{module_name}

%changelog
%{lua:
changelog = io.open("./CHANGELOG","r")
if changelog then
  io.input(changelog)
  print(io.read("*all"))
end
}

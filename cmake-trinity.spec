# BEGIN SourceDeps(oneline):
BuildRequires(pre): rpm-macros-suse-compat
BuildRequires: gcc-c++ perl(Encode.pm) cmake desktop-file-utils
# END SourceDeps(oneline)
%define suse_version 1550
# see https://bugzilla.altlinux.org/show_bug.cgi?id=10382
%define _localstatedir %{_var}
#
# spec file for package cmake-trinity (version R14)
#
# Copyright (c) 2014 Trinity Desktop Environment
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.
#
# Please submit bugfixes or comments via http://www.trinitydesktop.org/
#

# TDE variables
%if "%{?tde_version}" == ""
%define tde_version 14.1.3
%endif
%define tde_pkg tde-cmake

Name:		cmake-trinity
Version:	14.1.3
Release:	alt1_%{?tde_version}_%{?!preversion:1}%{?preversion:0_%{preversion}}
Summary:	TDE CMake modules
Group:		Development/C
URL:		http://www.trinitydesktop.org/

License:	GPL-2.0+

#Vendor:		Trinity Desktop
#Packager:	Francois Andriot <francois.andriot@free.fr>

Source0:		cmake-trinity-14.1.3.tar
Source1: import.info

#BuildRequires:	cmake
#BuildRequires:	desktop-file-utils

Requires:		cmake

Obsoletes:		cmake-trinity < %version-%release
Provides:		cmake-trinity = %version-%release

%description
TDE uses its own set of modules and macros to simplify CMake rules.

This also includes the TDEL10n module that is used to generate and
update templates for translations and the modified version of
intltool-merge used to merge translations into desktop files.


%prep
%setup -n %name-%tde_version%{?preversion:~%preversion}

%install
%cmakeinstall

%files
%_datadir/%name/


%changelog
* Mon Jan 13 2025 Petr Akhlamov <ahlamovpm@basealt.ru> 14.1.2-alt1_1
- converted for ALT Linux by srpmconvert tools


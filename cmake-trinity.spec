# BEGIN SourceDeps(oneline):
BuildRequires(pre): rpm-macros-suse-compat
BuildRequires: gcc-c++ perl(Encode.pm)
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

%if 0%{?rhel} == 6 || 0%{?rhel} == 7
%define cmake_datadir %{_datadir}/cmake3
%else
%define cmake_datadir %{_datadir}/cmake
%endif


Name:		trinity-%{tde_pkg}
Version:	%{tde_version}
Release:	alt1_%{?!preversion:1}%{?preversion:0_%{preversion}}
Summary:	TDE CMake modules
Group:		Development/C
URL:		http://www.trinitydesktop.org/

%if 0%{?suse_version}
License:	GPL-2.0+
%else
License:	GPLv2+
%endif

#Vendor:		Trinity Desktop
#Packager:	Francois Andriot <francois.andriot@free.fr>

Prefix:		%{_prefix}
BuildArch:	noarch

Source0:		%{name}-%{tde_version}%{?preversion:~%{preversion}}.tar.gz

BuildRequires:	cmake
BuildRequires:	desktop-file-utils

Requires:		cmake

Obsoletes:		trinity-cmake < %{version}-%{release}
Provides:		trinity-cmake = %{version}-%{release}
Source44: import.info

%description
TDE uses its own set of modules and macros to simplify CMake rules.

This also includes the TDEL10n module that is used to generate and
update templates for translations and the modified version of
intltool-merge used to merge translations into desktop files.


%prep
%setup -q -n %{name}-%{tde_version}%{?preversion:~%{preversion}}


%build
unset QTDIR QTINC QTLIB

if ! rpm -E %%cmake|grep -e 'cd build\|cd ${CMAKE_BUILD_DIR:-build}'; then
  mkdir -p build
  cd build
fi

%{suse_cmake} \
  -DCMAKE_BUILD_TYPE="RelWithDebInfo" \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DWITH_GCC_VISIBILITY=ON \
  \
  -DBUILD_ALL="ON" \
  -DWITH_ALL_OPTIONS="ON" \
  ..

make %{?_smp_mflags} || make


%install
rm -rf %{?buildroot}
make install -C build DESTDIR=%{?buildroot}


%files
%{cmake_datadir}/Modules/FindTDE.cmake
%{cmake_datadir}/Modules/FindTQt.cmake
%{cmake_datadir}/Modules/FindTQtQUI.cmake
%{cmake_datadir}/Modules/TDEL10n.cmake
%{cmake_datadir}/Modules/TDEMacros.cmake
%{cmake_datadir}/Modules/TDESetupPaths.cmake
%{cmake_datadir}/Modules/TDEVersion.cmake
%{cmake_datadir}/Modules/tde_automoc.cmake
%{cmake_datadir}/Modules/tde_l10n_merge.pl
%{cmake_datadir}/Modules/tde_uic.cmake
%{cmake_datadir}/Templates/tde_dummy_cpp.cmake
%{cmake_datadir}/Templates/tde_export_library.cmake
%{cmake_datadir}/Templates/tde_libtool_file.cmake
%{cmake_datadir}/Templates/tde_tdeinit_executable.cmake
%{cmake_datadir}/Templates/tde_tdeinit_module.cmake


%changelog
* Mon Jan 13 2025 Petr Akhlamov <ahlamovpm@basealt.ru> 14.1.2-alt1_1
- converted for ALT Linux by srpmconvert tools


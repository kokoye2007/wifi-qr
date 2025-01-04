Name:           wifi-qr
Version:        0.4
Release:        1%{?dist}
Summary:        Wi-Fi password share via QR codes
License:        GPL-3.0-or-later
URL:            https://github.com/kokoye2007/wifi-qr
Source0:        https://github.com/kokoye2007/wifi-qr/archive/v%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  make
BuildRequires:  appstream

# Either zenity or kdialog is required for the UI
Requires:       (zenity or kdialog)
Requires:       qrencode
Requires:       zbar

%description
Shares Wi-Fi SSID and password via a QR code. Generate a QR code of a Wi-Fi 
network with its password. Scan QR codes and easily connect to Wi-Fi Networks.

For Android, OS version 10 and above is supported.
For iOS, the Shortcut app supports generating Wi-Fi QR codes.

%prep
%autosetup

%build
# No build required for shell scripts

%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datadir}/applications
mkdir -p %{buildroot}%{_metainfodir}
install -m 755 wifi-qr %{buildroot}%{_bindir}/
install -m 644 wifi-qr.desktop %{buildroot}%{_datadir}/applications/
install -m 644 wifi-qr.metainfo.xml %{buildroot}%{_metainfodir}/

%files
%license COPYING
%doc README.md
%{_bindir}/wifi-qr
%{_datadir}/applications/wifi-qr.desktop
%{_metainfodir}/wifi-qr.metainfo.xml

%changelog
* Thu Dec 19 2024 kokoye2007 <kokoye2007@gmail.com> - 0.4-1
- New upstream release (0.4)
- Added keyboard-support
  - Improve keyboard navigation support
  - Remove deprecated Zenity code
  - Add legacy encoding support
  - Improve parsing of WIFI URI
  - Apply ShellCheck recommendations to improve script quality
- Added webcam-support
  - Add webcam-based QR scanning functionality
- Added appstream-metadata
  - Add AppStream metadata for better software center integration
- Added kdialog-support
  - Automatically detect dialog tools (Zenity or KDialog)
  - Add manual dialog tool selection with -d option

* Sat Sep 30 2023 kokoye2007 <kokoye2007@gmail.com> - 0.3-1
- New upstream release (0.3)
- Fixed Xiaomi QR code parsing issues
- Fixed QR issues with special characters in SSID and passwords
- Fixed QR issues when name and SSID differ
- Improved password handling with special characters

* Wed Apr 27 2022 kokoye2007 <kokoye2007@gmail.com> - 0.2-2
- Package description update
- Added QR Code File Scan feature

* Thu Jun 18 2020 kokoye2007 <kokoye2007@gmail.com> - 0.2-1
- Applied Shellcheck recommendations

* Sun May 31 2020 kokoye2007 <kokoye2007@gmail.com> - 0.1-1
- Initial release

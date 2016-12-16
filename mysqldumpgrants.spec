%include	/usr/lib/rpm/macros.perl
Summary:	Dumps grants from a MySQL database as valid SQL
Summary(pl.UTF-8):	Wyciąganie uprawnień z bazy danych MySQL w postaci poprawnego SQL-a
Name:		mysqldumpgrants
Version:	1.0
Release:	4
License:	GPL
Group:		Applications/Databases/Interfaces
Source0:	%{name}.pl
URL:		http://forge.mysql.com/tools/tool.php?id=12
BuildRequires:	perl-tools-pod
BuildRequires:	rpm-perlprov >= 4.1-13
Requires:	perl-DBD-mysql
Requires:	perl-Encode
BuildArch:	noarch
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%description
mysqldumpgrants dumps the grants of a MySQL database as valid SQL
commands.

this package is not maintained, use mk-show-grants from maatkit
instead.

%description -l pl.UTF-8
mysqldumpgrants wyciąga informacje o uprawnieniach z bazy danych MySQL
w postaci poprawnych poleceń SQL.

%prep
%setup -qcT
install -p %{SOURCE0} %{name}

%build
pod2man %{name} > %{name}.1

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT{%{_bindir},%{_mandir}/man1}
install -p %{name} $RPM_BUILD_ROOT%{_bindir}
cp -p %{name}.1  $RPM_BUILD_ROOT%{_mandir}/man1

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%attr(755,root,root) %{_bindir}/mysqldumpgrants
%{_mandir}/man1/mysqldumpgrants.1*

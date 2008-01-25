%include	/usr/lib/rpm/macros.perl
Summary:	Dumps grants from a MySQL database as valid SQL
Name:		mysqldumpgrants
Version:	1.0
Release:	3
License:	GPL
Group:		Applications
Source0:	http://forge.mysql.com/snippets/download.php?id=12
# Source0-md5:	c556ab1f346698e1994c97e1ae773b4e
URL:		http://forge.mysql.com/snippets/view.php?id=12
BuildRequires:	perl-tools-pod
BuildRequires:	rpm-perlprov >= 4.1-13
Requires:	perl-DBD-mysql
BuildArch:	noarch
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%description
mysqldumpgrants dumps the grants of a MySQL database as valid SQL
commands.

%prep
%setup -qcT
%{__sed} -e 's,\r$,,' %{SOURCE0} > %{name}

%build
pod2man %{name} > %{name}.1

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT{%{_bindir},%{_mandir}/man1}
install %{name} $RPM_BUILD_ROOT%{_bindir}
install %{name}.1  $RPM_BUILD_ROOT%{_mandir}/man1

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%attr(755,root,root) %{_bindir}/mysqldumpgrants
%{_mandir}/man1/mysqldumpgrants.1*

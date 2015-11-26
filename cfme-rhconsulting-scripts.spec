Name:      cfme-rhconsulting-scripts
Version:   0.2
Release:   1
Summary:   Red Hat Consulting Scripts for CloudForms

Group:     Applications/System
License:   GPLv3+
URL:       https://github.com/jsimonelli/%{name}
Source:    %{name}-%{version}-%{release}.tar.gz

BuildArch: noarch

%description
These scripts are useful to import/export specific items.

%prep
%autosetup -n %{name}

%build

%install
mkdir -p "%{buildroot}/var/www/miq/vmdb/lib/tasks"
mkdir -p "%{buildroot}/usr/bin"
cd %{_builddir}/%{name}
install --backup --mode=0644 -t "%{buildroot}/var/www/miq/vmdb/lib/tasks/$f" *.rake
install --backup --mode=0755 -t "%{buildroot}/usr/bin" miqexport
install --backup --mode=0755 -t "%{buildroot}/usr/bin" miqimport

%files
/var/www/miq/vmdb/lib/tasks/rhconsulting_buttons.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_miq_ae_datastore.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_tags.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_customization_templates.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_roles.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_dialogs.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_service_catalogs.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_reports.rake
/usr/bin/miqexport
/usr/bin/miqimport

%post

%changelog
* Thu Nov 26 2015 George Goh <george.goh@redhat.com> 0.2-1
- Add custom report import/export
- Add miqimport/miqexport commands

* Wed Aug 26 2015 George Goh <george.goh@redhat.com> 0.1-2
- Bump release version

* Mon Jul 20 2015 George Goh <george.goh@redhat.com> 0.1-1
- Initial RPM release


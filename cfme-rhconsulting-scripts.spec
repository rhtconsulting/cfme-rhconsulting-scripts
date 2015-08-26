Name:      cfme-rhconsulting-scripts
Version:   0.1
Release:   2
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
cd %{_builddir}/%{name}-%{version}
install --backup --mode=0644 -t "%{buildroot}/var/www/miq/vmdb/lib/tasks/$f" *.rake

%files
%doc
/var/www/miq/vmdb/lib/tasks/rhconsulting_buttons.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_miq_ae_datastore.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_tags.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_customization_templates.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_roles.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_dialogs.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_service_catalogs.rake

%post

%changelog
* Mon Jul 20 2015 George Goh <george.goh@redhat.com> 0.1-1
- Initial RPM release


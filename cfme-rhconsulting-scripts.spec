Name:      cfme-rhconsulting-scripts
Version:   0.1
Release:   1
Summary:   Red Hat Consulting Scripts for CloudForms

Group:     Applications/System
License:   GPLv3+
URL:       https://github.com/jsimonelli/%{name}
Source0:   https://github.com/jsimonelli/%{name}/archive/%{version}.tar.gz

BuildArch: noarch

%description
These scripts are useful to import/export specific items.

%prep

%build

%install
mkdir -p "%{buildroot}/etc/profile.d"
mkdir "%{buildroot}/root"
cd %{_builddir}/%{name}-%{version}
RAKEFILES=(rhconsulting_buttons.rake rhconsulting_miq_ae_datastore.rake \
rhconsulting_tags.rake rhconsulting_customization_templates.rake \
rhconsulting_roles.rake rhconsulting_dialogs.rake rhconsulting_service_catalogs.rake)
for f in $RAKEFILES; do
install --backup --mode=0644 $f "%{buildroot}/var/www/miq/vmdb/lib/tasks/$f"
done

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


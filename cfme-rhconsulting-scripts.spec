Name:      cfme-rhconsulting-scripts
Version:   0.12
Release:   1
Summary:   Red Hat Consulting Scripts for CloudForms

Group:     Applications/System
License:   GPLv3+
URL:       https://github.com/rhtconsulting/%{name}
Source:    %{name}-%{version}-%{release}.tar.gz

BuildArch: noarch

%description
Export and import customisations for CloudForms / ManageIQ.

%prep
%autosetup -n %{name}

%build

%install
mkdir -p "%{buildroot}/var/www/miq/vmdb/lib/tasks"
mkdir -p "%{buildroot}/usr/bin"
cd %{_builddir}/%{name}
install --backup --mode=0644 -t "%{buildroot}/var/www/miq/vmdb/lib/tasks/$f" *.rake
install --backup --mode=0644 -t "%{buildroot}/var/www/miq/vmdb/lib/tasks/$f" *.rb
install --backup --mode=0755 -t "%{buildroot}/usr/bin" bin/miqexport
install --backup --mode=0755 -t "%{buildroot}/usr/bin" bin/miqimport
install --backup --mode=0755 -t "%{buildroot}/usr/bin" bin/export-miqdomain
install --backup --mode=0755 -t "%{buildroot}/usr/bin" bin/import-miqdomain

%files
/var/www/miq/vmdb/lib/tasks/rhconsulting_buttons.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_miq_ae_datastore.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_tags.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_customization_templates.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_orchestration_templates.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_roles.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_provision_dialogs.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_service_dialogs.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_service_catalogs.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_reports.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_widgets.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_policies.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_alerts.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_illegal_chars.rb
/var/www/miq/vmdb/lib/tasks/rhconsulting_options.rb
/var/www/miq/vmdb/lib/tasks/rhconsulting_model_attributes.rb
/var/www/miq/vmdb/lib/tasks/rhconsulting_scanitems.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_scriptsrc.rake
/var/www/miq/vmdb/lib/tasks/rhconsulting_schedules.rake
/usr/bin/miqexport
/usr/bin/miqimport
/usr/bin/export-miqdomain
/usr/bin/import-miqdomain

%post

%changelog
* Thu Aug 9 2018 Dustin Scott,Lynn Dixon <dscott@redhat.com,ldixon@redhat.com> 0.12-1
- Added support for schedules (non-widget type only)

* Fri Jan 26 2017 Jeffrey Cutter <jcutter@redhat.com>  0.11-1
- Added support for customization specifications.

* Wed Dec 12 2016 Andrew Spurrier <andrew.spurrier@redhat.com> 0.10-1
- Added check that the user supplied an absolute path.
- Added checks to each import to only attempt the import if there is a file to import from.

* Wed Oct 19 2016 Nick Maludy <nmaludy@gmail.com> 0.9
- Added support for importing/export individual files
- Added support for importing/exporting filenames and directories with spaces
- Added support for importing/exporting relative paths
- Added support for importing/exporting paths with symlinks
- Changed export file naming behavior to replace spaces with _
  * Note: to preserve old behavior and keep spaces the command line option
    --keep-spaces was added
- Added several new command line options to expose various underlying
  functionality in miqimport

* Mon Aug 15 2016 Brant Evans <bevans@redhat.com> 0.8
- Added export/import for provisioning dialogs

* Tue Aug 02 2016 Brant Evans <bevans@redhat.com> 0.7
- Added export/import for alerts and alert sets

* Fri Jul 08 2016 Brant Evans <bevans@redhat.com> 0.6
- Added export/import for widgets

* Thu Apr 28 2016 Kumar Jadav <kumar.jadav@redhat.com> 0.5
- Added the import-miqdomain file.

* Tue Apr 26 2016 Kumar Jadav <kumar.jadav@redhat.com> 0.4
- Added the export-miqdomain file.

* Mon Dec 21 2015 George Goh <george.goh@redhat.com> 0.3-2
- Fix wrong test in miqimport for the existence of files.

* Mon Dec 14 2015 Brant Evans <brant.evans@redhat.com> 0.3-1
- Add policy import/export
- Adjust miqexport/miqimport path to fix RPM build errors

* Thu Nov 26 2015 George Goh <george.goh@redhat.com> 0.2-1
- Add custom report import/export
- Add miqimport/miqexport commands

* Wed Aug 26 2015 George Goh <george.goh@redhat.com> 0.1-2
- Bump release version

* Mon Jul 20 2015 George Goh <george.goh@redhat.com> 0.1-1
- Initial RPM release


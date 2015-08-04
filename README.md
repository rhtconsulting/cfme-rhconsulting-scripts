# README #

= Cloudforms/ManageIQ rhconsulting rake scripts

These scripts are useful to import/export specific items


### How do I get set up? ###

== Install
* Copy the .rake files to /var/www/miq/vmdb/lib/tasks

== Example Exports
----
BUILDDIR=/tmp/CFME-build
DOMAIN_EXPORT=YourDomainHere

rm -fR ${BUILDDIR}
mkdir -p ${BUILDDIR}/{service_catalogs,dialogs,roles,tags,buttons,customization_templates}

cd /var/www/miq/vmdb
bin/rake rhconsulting:service_catalogs:export[${BUILDDIR}/service_catalogs]
bin/rake rhconsulting:dialogs:export[${BUILDDIR}/dialogs]
bin/rake rhconsulting:roles:export[${BUILDDIR}/roles/roles.yml]
bin/rake rhconsulting:tags:export[${BUILDDIR}/tags/tags.yml]
bin/rake rhconsulting:buttons:export[${BUILDDIR}/buttons/buttons.yml]
bin/rake rhconsulting:customization_templates:export[${BUILDDIR}/customization_templates/customization_templates.yml]
bin/rake "rhconsulting:miq_ae_datastore:export[${DOMAIN_EXPORT}, ${BUILDDIR}/miq_ae_datastore]"
----

== Example Imports
----
BUILDDIR=/tmp/CFME-build
DOMAIN_IMPORT=YourDomainHere

cd /var/www/miq/vmdb
bin/rake rhconsulting:service_catalogs:import[${BUILDDIR}/service_catalogs]
bin/rake rhconsulting:dialogs:import[${BUILDDIR}/dialogs]
bin/rake rhconsulting:roles:import[${BUILDDIR}/roles/roles.yml]
bin/rake rhconsulting:tags:import[${BUILDDIR}/tags/tags.yml]
bin/rake rhconsulting:buttons:import[${BUILDDIR}/buttons/buttons.yml]
bin/rake rhconsulting:customization_templates:import[${BUILDDIR}/customization_templates/customization_templates.yml]
bin/rake "rhconsulting:miq_ae_datastore:import[${DOMAIN_IMPORT}, ${BUILDDIR}/miq_ae_datastore]"
----
### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

### Who do I talk to? ###
* Jose Simonelli (jose@redhat.com)
* Lester Claudio (claudiol@redhat.com)
* George Goh (george.goh@redhat.com)

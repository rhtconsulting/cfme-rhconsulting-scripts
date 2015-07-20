VERSION := 0.1
BUILD_DIR := $(shell rpmbuild -E %{_builddir})/cfme-rhconsulting-scripts-$(VERSION)

rpm:
	mkdir -p $(BUILD_DIR)
	git archive $(VERSION) | tar -x -C $(BUILD_DIR)
	rpmbuild -bb cloudforms-util.spec

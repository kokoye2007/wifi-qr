#!/bin/bash

# Makefile for Building, Managing, and Releasing wifi-qr Package

# Define the installation directories
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
APPDIR = $(PREFIX)/share/applications
ICONDIR = $(PREFIX)/share/icons

# Files to install
BIN_FILES = wifi-qr
DESKTOP_FILES = wifi-qr.desktop
ICON_FILES = wifi-qr.svg
METAINFO = wifi-qr.metainfo.xml

# Variables
VERSION := 0.4
DEBIAN_REVISION := 1
DEBIAN_VERSION := $(VERSION)-$(DEBIAN_REVISION)
SOFTWARE := wifi-qr
SOFTFILE := $(SOFTWARE)_$(VERSION)
SOFTTAG := $(SOFTWARE)-$(VERSION)
UPSTREAM_PACKAGE := $(SOFTFILE).org.tar.xz
DEB_FILE := $(SOFTWARE)_$(DEBIAN_VERSION)_all.deb
ARCHIVE := $(SOFTTAG).tar.gz
CHECKSUM_FILE_SHA := CHECKSUMS.sha256
CHECKSUM_FILE_MD5 := CHECKSUMS.md5
CHANGES := $(SOFTFILE)_source.changes
BUILD_DIR := ../BUILD_DIR_$(SOFTWARE)
NOTES := "WiFi-QR update Debian Package"

# Targets
.PHONY: all test-install test-uninstall release-tag build-orig build-changes git-init git-tag git-tag-upload uscan-watch checksum checksum-deb clean debug gbp deb dput

# Default target
all: debug

# Release Tag
release-tag: git-tag git-archive checksum checksum-deb git-tag-upload


# Installation rule
test-install:
	# Install binary file
	install -Dm755 $(BIN_FILES) $(DESTDIR)$(BINDIR)/$(BIN_FILES)
	# Install desktop entry
	install -Dm644 $(DESKTOP_FILES) $(DESTDIR)$(APPDIR)/$(DESKTOP_FILES)
	# Install icon file
	install -Dm644 $(ICON_FILES) $(DESTDIR)$(ICONDIR)/$(ICON_FILES)

# Uninstallation rule
test-uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(BIN_FILES)
	rm -f $(DESTDIR)$(APPDIR)/$(DESKTOP_FILES)
	rm -f $(DESTDIR)$(ICONDIR)/$(ICON_FILES)

# Target to clean up previous build and create a new Debian orig file
build-orig:
	@echo "Building original source package..."
	rm -rf $(BUILD_DIR) ../$(SOFTFILE).orig.tar.xz*
	mkdir -p $(BUILD_DIR)
	cp -r ./ $(BUILD_DIR)
	cd $(BUILD_DIR) && rm -rf .git && dh_make -s -e kokoye2007 -c gpl3 -p $(SOFTFILE) --createorig -y || echo "DONE"
	gpg --armor --detach-sign ../$(SOFTFILE).orig.tar.xz
	@echo "Original source package created."

# Target to build Debian changes file
build-changes:
	@echo "Building Debian changes file with correct versioning..."
	debuild -S -i -I -sa
	@echo "Changes file created."

# Git repository initialization
git-init:
	@echo "Initializing Git repository..."
	git init
	git add .
	git remote add origin "git@github.com:kokoye2007/$(SOFTWARE).git"
	git remote -v
	@echo "Git repository initialized."

# Create and push a Git tag
git-tag:
	@echo "Creating and pushing Git tag..."
	git tag -s v$(VERSION) -m "Upstream release $(VERSION)"
	git tag -v v$(VERSION)
	git push origin v$(VERSION)
	@echo "Git tag created and pushed."

# Archive, sign, and push the tag
git-archive:
	@echo "Creating Debian-compliant source archive..."
	git archive --prefix=$(SOFTTAG)/ -o ../$(ARCHIVE) $(VERSION)
	gpg --armor --detach-sign ../$(ARCHIVE)

git-tag-upload:
	@echo "Uploading release archive, Debian package, and checksums..."
	gh release create v$(VERSION) \
		../$(ARCHIVE) \
		../$(ARCHIVE).asc \
		../$(SOFTTAG)_$(CHECKSUM_FILE_SHA) \
		../$(SOFTTAG)_$(CHECKSUM_FILE_MD5) \
		../$(SOFTTAG)_$(CHECKSUM_FILE_SHA).asc \
		../$(SOFTTAG)_$(CHECKSUM_FILE_MD5).asc \
		../$(DEB_FILE) \
		../$(DEB_FILE)_$(CHECKSUM_FILE_SHA) \
		../$(DEB_FILE)_$(CHECKSUM_FILE_MD5) \
		../$(DEB_FILE)_$(CHECKSUM_FILE_SHA).asc \
		../$(DEB_FILE)_$(CHECKSUM_FILE_MD5).asc \
		--title "$(SOFTTAG)" \
		--notes "Release $(SOFTTAG) with Debian package"
	@echo "GitHub release updated with Debian package and checksums."

# Run uscan to check for new upstream versions
uscan-watch:
	@echo "Running uscan to check for upstream updates..."
	uscan --no-download --verbose --debug
	@echo "uscan check completed."

# Generate checksums for build artifacts
# checksum: $(ARCHIVE)
checksum:
	@echo "Generating SHA256 and MD5 checksums for $(ARCHIVE)..."
	sha256sum ../$(ARCHIVE)* > ../$(SOFTTAG)_$(CHECKSUM_FILE_SHA)
	md5sum ../$(ARCHIVE)* > ../$(SOFTTAG)_$(CHECKSUM_FILE_MD5)
	gpg --armor --detach-sign ../$(SOFTTAG)_$(CHECKSUM_FILE_SHA)
	gpg --armor --detach-sign ../$(SOFTTAG)_$(CHECKSUM_FILE_MD5)
	@echo "Checksums generated and signed: $(CHECKSUM_FILE_SHA) and $(CHECKSUM_FILE_MD5)"

# Generate checksums for DEB file
checksum-deb:
	@echo "Generating SHA256 and MD5 checksums for $(DEB_FILE)..."
	sha256sum ../$(DEB_FILE) > ../$(DEB_FILE)_$(CHECKSUM_FILE_SHA)
	md5sum ../$(DEB_FILE) >    ../$(DEB_FILE)_$(CHECKSUM_FILE_MD5)
	gpg --armor --detach-sign  ../$(DEB_FILE)_$(CHECKSUM_FILE_SHA)
	gpg --armor --detach-sign  ../$(DEB_FILE)_$(CHECKSUM_FILE_MD5)
	@echo "Checksums generated and signed: $(DEB_FILE)_$(CHECKSUM_FILE_SHA) and $(DEB_FILE)_$(CHECKSUM_FILE_MD5)"

# Clean up build artifacts
clean:
	@echo "Cleaning up build artifacts..."
	rm -rf $(BUILD_DIR) *.tar.gz *.orig.tar.xz $(CHECKSUM_FILE_SHA)* $(CHECKSUM_FILE_MD5)* $(CHANGES)
	@echo "Clean-up complete."

# Output current state of variables for debugging
debug:
	@echo "SOFTWARE: $(SOFTWARE)"
	@echo "VERSION: $(VERSION)"
	@echo "SOFTFILE: $(SOFTFILE)"
	@echo "SOFTTAG: $(SOFTTAG)"
	@echo "BUILD_DIR: $(BUILD_DIR)"
	@echo "ARCHIVE: $(ARCHIVE)"
	@echo "CHECKSUM_FILE_SHA: $(CHECKSUM_FILE_SHA)"
	@echo "CHECKSUM_FILE_MD5: $(CHECKSUM_FILE_MD5)"
	@echo "CHANGES: $(CHANGES)"
	@echo "UPSTREAM_PACKAGE: $(UPSTREAM_PACKAGE)"

# Git-buildpackage for Debian package building
gbp:
	@echo "Running Git-buildpackage..."
	gbp buildpackage --git-tag-only --git-ignore-branch
	@echo "Git-buildpackage complete."

# Build Debian binary package
deb:
	@echo "Building Debian binary package..."
	debuild -b
	@echo "Debian binary package built."

# Upload package to Debian mentors
dput:
	@echo "Uploading package to mentors..."
	dput -f mentors ../$(CHANGES)
	@echo "Package uploaded to mentors."

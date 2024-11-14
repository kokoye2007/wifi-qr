# Makefile for Building, Managing, and Releasing wifi-qr Package

# Variables
SOFTWARE := wifi-qr
VERSION := 0.3-2
SOFTFILE := $(SOFTWARE)_$(VERSION)
SOFTTAG := $(SOFTWARE)-$(VERSION)
BUILD_DIR := BUILD_DIR_$(SOFTWARE)
ARCHIVE := $(SOFTTAG).tar.gz
CHECKSUM_FILE_SHA := CHECKSUMS.sha256
CHECKSUM_FILE_MD5 := CHECKSUMS.md5
CHANGES := $(SOFTFILE)_source.changes
UPSTREAM_PACKAGE := $(SOFTWARE)_$(VERSION).orig.tar.xz
DEB_FILE := $(SOFTWARE)_$(VERSION)_all.deb
NOTES := "Wifi-QR update Debian Package"

# Targets
.PHONY: all release-tag build-orig build-changes git-init git-tag git-tag-upload uscan-watch checksum checksum-deb clean debug gbp deb dput

# Default target to build everything
all: debug

# Release Tag
release-tag: git-tag git-archive checksum git-tag-upload


# Target to clean up previous build and create a new Debian orig file
build-orig:
	@echo "Building original source package..."
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	cp -r ./ $(BUILD_DIR)
	cd $(BUILD_DIR) && rm -rf .git
	cd $(BUILD_DIR) && dh_make -s -e kokoye2007 -c gpl3 -p $(SOFTFILE) --createorig -y
	gpg --armor --detach-sign $(SOFTFILE).orig.tar.xz
	@echo "Original source package created."

# Target to build Debian changes file
build-changes:
	@echo "Building Debian changes file..."
	debuild -S -i -I
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
	# git add -A
	# git commit -s -am "$(SOFTWARE) $(VERSION)"
	git tag -s $(SOFTTAG) -m "Upstream $(VERSION)"
	git tag -v $(SOFTTAG) 
	git push -u origin master
	git push origin $(SOFTTAG)
	@echo "Git tag created and pushed."

# Archive, sign, and push the tag
git-archive:
	@echo "Creating release archive and uploading..."
	git archive --prefix=$(SOFTTAG)/ -o ../$(ARCHIVE) $(SOFTTAG)
	gpg --armor --detach-sign ../$(ARCHIVE)

git-tag-upload:
	@echo "Release archive created and signed."
	gh release create $(VERSION) \
		../$(ARCHIVE) \
		../$(ARCHIVE).asc \
    ../$(SOFTTAG)_$(CHECKSUM_FILE_SHA) \
    ../$(SOFTTAG)_$(CHECKSUM_FILE_MD5) \
    ../$(SOFTTAG)_$(CHECKSUM_FILE_SHA).asc \
    ../$(SOFTTAG)_$(CHECKSUM_FILE_MD5).asc \
		--title "$(SOFTTAG)" \
		--notes "Release $(SOFTTAG)"
	@echo "Release archive created and signed."

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
	gbp buildpackage --git-tag-only
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


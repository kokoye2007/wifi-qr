# Makefile for managing Debian package building, Git operations, and GitHub releases

#### REFACTORED VERSION ####

# Variables
SOFTWARE := wifi-qr
VERSION := 0.3-2
BUILD_DIR := ../BUILD_DIR_$(SOFTWARE)
SOFTFILE := $(SOFTWARE)_$(VERSION)
SOFTTAG := $(SOFTWARE)-$(VERSION)
SCRIPT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
WORK_DIR := $(SCRIPT_DIR)/$(BUILD_DIR)
NOTES := "Wifi-QR update Debian Package"
UPSTREAM_PACKAGE := $(SOFTWARE)_$(VERSION).orig.tar.xz
CHANGES := $(SOFTWARE)_$(VERSION)_source.changes
RELEASE_REPO := git@github.com:kokoye2007/$(SOFTWARE).git

# Targets and Recipes
.PHONY: all build-orig build-changes git-init git-tag git-tag-upload \
        uscan-watch gbp-build create-release dpkg dput deb git

all: build-orig build-changes

# Clean up previous build and prepare the build directory
build-orig:
	@echo "Cleaning and preparing build directory..."
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	cp -r ./ $(BUILD_DIR)
	cd $(WORK_DIR) && \
		rm -rf .git && \
		dh_make -s -e kokoye2007 -c gpl3 -p $(SOFTFILE) --createorig -y && \
		gpg --armor --detach-sign ../$(SOFTFILE).orig.tar.xz

# Build changes file using debuild
build-changes:
	@echo "Building changes file..."
	debuild -S -i -I

# Initialize Git repository and link to remote
git-init:
	@echo "Initializing Git repository..."
	git init
	git add .
	git remote add origin $(RELEASE_REPO)
	git remote -v

# Commit, tag, and push Git changes
git-tag:
	@echo "Tagging and pushing to Git repository..."
	git add -A
	git commit -s -am "$(SOFTWARE) $(VERSION)"
	git tag -s "$(SOFTTAG)" -m "Upstream $(VERSION)"
	git tag -v "$(SOFTTAG)"
	git push -u --force origin master

# Create a signed archive of the tagged version
git-tag-upload:
	@echo "Creating and signing Git archive..."
	git archive --prefix="$(SOFTTAG)/" -o "../$(SOFTTAG).tar.gz" "$(SOFTTAG)"
	gpg --armor --detach-sign "../$(SOFTTAG).tar.gz"

# Run uscan to check for new versions
uscan-watch:
	@echo "Running uscan..."
	uscan --no-download --verbose --debug

# Build package using gbp
gbp-build:
	@echo "Building package with gbp..."
	gbp buildpackage --git-tag-only

# Create a GitHub release
create-release:
	@echo "Creating GitHub release..."
	gh release create "$(VERSION)" --title "$(SOFTTAG)" --notes "$(NOTES)"

# Create upstream package and sign it
dpkg:
	@echo "Building upstream package..."
	tar caf ../$(UPSTREAM_PACKAGE) --exclude='debian' --exclude='.git' .
	cp debian/upstream/*.asc ../$(UPSTREAM_PACKAGE).asc
	gpg --armor --detach-sign ../$(UPSTREAM_PACKAGE).asc
	debuild -S -i -I

# Upload package to mentors using dput
dput:
	@echo "Uploading package with dput..."
	dput -f mentors-ftp ../$(CHANGES)

# Build Debian package
deb:
	@echo "Building Debian package..."
	debuild -b

# Commit changes, tag, and push to GitHub with release creation
git:
	@echo "Committing changes and creating release..."
	git add -A
	git commit -m "$(VERSION) upstream"
	git tag -s "$(SOFTTAG)" -m "Upstream $(VERSION)"
	git tag -v "$(SOFTTAG)"
	git push --tags
	gh release create "$(VERSION)" --title "$(SOFTTAG)"


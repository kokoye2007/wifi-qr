# Makefile for managing Debian package building, Git operations, and GitHub releases

# Variables
SOFTWARE = wifi-qr
VERSION = 0.3
BUILD_DIR = ./BUILD_DIR_$(SOFTWARE)
SOFTFILE = $(SOFTWARE)_$(VERSION)
SOFTTAG = $(SOFTWARE)-$(VERSION)
SCRIPT_DIR = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
WORK_DIR = $(SCRIPT_DIR)/$(BUILD_DIR)/src
NOTES = "Wifi-QR update Debian Package"
UPSTREAM_PACKAGE = $(SOFTWARE)_$(VERSION).orig.tar.xz
CHANGES = $(SOFTWARE)_$(VERSION)_source.changes

# Targets and Recipes
.PHONY: all build-orig build-changes git-init git-tag git-tag-upload uscan-watch gbp-build create-release dpkg dput deb git

all: build-orig build-changes

build-orig:
    # Clean up previous build
    rm -rf $(BUILD_DIR)
    
    # Create and navigate to the build directory
    mkdir $(BUILD_DIR)
    cp -r ./src $(BUILD_DIR)
    cd $(WORK_DIR) || exit
    
    # Remove Git metadata
    rm -rf .git/*
    
    # Initialize Debian packaging
    dh_make -s -e kokoye2007 -c gpl3 -p $(SOFTFILE) --createorig -y
    
    # Create GPG signature for orig.tar.xz
    gpg --armor --detach-sign ../$(SOFTFILE).orig.tar.xz

build-changes:
    echo "Working directory: $(PWD)"
    debuild -S -i -I

git-init:
    git init
    git add .
    git remote add origin "git@github.com:kokoye2007/$(SOFTWARE).git"
    git remote -v

git-tag:
    git add -A
    git commit -m "Clean upstream"
    git tag -s "$(SOFTTAG)" -m "Upstream $(VERSION)"
    git tag -v "$(SOFTTAG)"
    git push -u --force origin master

git-tag-upload:
    git archive --prefix="$(SOFTTAG)/" -o "../$(SOFTTAG).tar.gz" "$(SOFTTAG)"
    gpg --armor --detach-sign "../$(SOFTTAG).tar.gz"

uscan-watch:
    uscan --no-download --verbose --debug

gbp-build:
    gbp buildpackage --git-tag-only

create-release:
    gh release create "$(VERSION)" --title "$(SOFTTAG)" --notes "$(NOTES)"

dpkg:
    tar caf ../$(UPSTREAM_PACKAGE) --exclude='debian' --exclude='.git' .
    cp debian/upstream/*.asc ../$(UPSTREAM_PACKAGE).asc
    gpg --armor --detach-sign ../$(UPSTREAM_PACKAGE).asc
    debuild -S -i -I

dput:
    cd .. && dput -f mentors-ftp $(CHANGES)

deb:
    debuild -b

git:
    cd .. && git add -A
    git commit -m "$(VERSION) upstream"
    git tag -s "$(SOFTTAG)" -m "Upstream $(VERSION)"
    git tag -v "$(SOFTTAG)"
    git push --tags
    gh release create "$(VERSION)" --title "$(SOFTTAG)" 


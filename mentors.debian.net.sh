#!/bin/bash
# Github Version
# DRAFT by Ko Ko Ye and Refactor by ChatGPT 3.5

#### JUST DRAFT - NOT TEST YET ####

SOFTWARE="wifi-qr"
VERSION="0.3-2"

BUILD_DIR="../BUILD_DIR_$SOFTWARE"
SOFTFILE="${SOFTWARE}_${VERSION}"
SOFTTAG="${SOFTWARE}-${VERSION}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$script_dir/$BUILD_DIR/"

echo_test() {
  echo BUILD_DIR: $BUILD_DIR
  echo SOFTFILE:  $SOFTFILE
  echo SOFTTAG:   $SOFTTAG
  echo SCRIPT:    $script_dir
  echo WORK_DIR:  $WORK_DIR
}


# Function to create the Debian 3.0 orig file
build_orig() {
    # Clean up previous build
    rm -rf "$BUILD_DIR"
    
    # Create and navigate to the build directory
    mkdir "$BUILD_DIR"
    cp -r ./ "$BUILD_DIR"
    cd "$WORK_DIR" || exit
    
    # Remove Git metadata
    rm -rf .git/*
    
    # Initialize Debian packaging
    dh_make -s -e kokoye2007 -c gpl3 -p "$SOFTFILE" --createorig -y
    
    # Create GPG signature for orig.tar.xz
    gpg --armor --detach-sign "../${SOFTFILE}.orig.tar.xz"
}

# Function to build the Debian package changes file
build_changes() {
    echo "Working directory: $(pwd)"
    debuild -S -i -I
}

# Function to set up Git repository
git_repo() {
    git init
    git add .
    git remote add origin "git@github.com:kokoye2007/${SOFTWARE}.git"
    git remote -v
}

# Function to create a release tag in Git
git_tag() {
    git add -A
    git commit -s -am "wifi-qr $VERSION"
    git tag -s "$SOFTTAG" -m "Upstream $VERSION"
    git tag -v "$SOFTTAG"
    git push -u --force origin master
}

# Function to create a Git tag and upload a release archive
git_tag_upload() {
    git archive --prefix="$SOFTTAG/" -o "../$SOFTTAG.tar.gz" "$SOFTTAG"
    gpg --armor --detach-sign "../${SOFTTAG}.tar.gz"
}

# Function to run 'uscan' for Debian watch file
uscan_watch() {
    uscan --no-download --verbose --debug
}

# Main script logic
case "$1" in
    "build-orig")
        build_orig
        ;;
    "build-changes")
        build_changes
        ;;
    "git-init")
        git_repo
        ;;
    "git-tag")
        git_tag
        ;;
    "git-tag-upload")
        git_tag_upload
        ;;
    "uscan-watch")
        uscan_watch
        ;;
    "echo")
        echo_test
        ;;
    *)
        echo "Usage: $0 {build-orig|build-changes|git-init|git-tag|git-tag-upload|uscan-watch}"
        exit 1
        ;;
esac

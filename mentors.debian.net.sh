#!/bin/bash
# Github Version

SOFTWARE=wifi-qr
VERSION=0.3
BUILD_DIR=./BUILD_DIR_$SOFTWARE
SOFTFILE=${SOFTWARE}_${VERSION}
SOFTTAG=${SOFTWARE}-${VERSION}

#rm -rf $BUILD_DIR
# check and make

mkdir $BUILD_DIR
cp -r ./src ./$BUILD_DIR
cd  $BUILD_DIR/src
echo ${pwd}


rm .git/* -rf

dh_make -s -e kokoye2007 -c gpl3 -p $SOFTFILE --createorig -y


cp debian/upstream/*.asc ../${SOFTFILE}.orig.tar.xz.asc
#gpg --armor  --detach-sign ../${SOFTFILE}.orig.tar.xz.asc

echo ${pwd}
debuild -S -i -I

#dput -f mentor ../${SOFTFILE}_source.changes


git init 
git add .
#git remote add origin git@salsa.debian.org:kokoye2007-guest/${SOFTWARE}.git
git remote add origin git@github.com:kokoye2007/${SOFTWARE}.git
git remote -v
git commit -m "reclean upstream"
git tag -s "$SOFTTAG" -m "Upstream $VERSION"
git tag -v "$SOFTTAG"
git push -u --force origin master

#

git archive --prefix="$SOFTTAG/" -o "../$SOFTTAG.tar.gz" "$SOFTTAG"
gpg --armor --detach-sign "../${VERSION}.tar.gz"

uscan --no-download --verbose --debug


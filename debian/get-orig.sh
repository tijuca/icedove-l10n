#!/bin/bash -e
#
# Download upstream xpi files from mozilla server and extract into upstream
# folder. Must run from root of debian package.
#
# Need version number (e.g 3.0.1) as argument.

if [ "$#" -lt 1 ]; then
    echo "usage: $0 Version"
    exit 1
fi

TMPDIR=`mktemp -d /tmp/icedove-l10n.XXXXXXXXXX`
CURDIR=`pwd`
VERSION=$1
VERSIONWITHOUTESR=`echo $1 | sed -e 's/\([0-9\.]*\)\([a-z]\{3\}\)/\1/'`

if [ -f $CURDIR/../icedove-l10n_$VERSIONWITHOUTESR.orig.tar.gz ]; then
    echo "icedove-l10n_$VERSIONWITHOUTESR.orig.tar.gz exists, giving up..."
    exit 1
fi

mkdir $TMPDIR/icedove-l10n-$VERSIONWITHOUTESR
mkdir $TMPDIR/icedove-l10n-$VERSIONWITHOUTESR/upstream
cd $TMPDIR/icedove-l10n-$VERSIONWITHOUTESR

# use wget mirror mode
wget -m ftp://ftp.mozilla.org/pub/mozilla.org/thunderbird/releases/$VERSION/linux-i686/xpi
cp ftp.mozilla.org/pub/mozilla.org/thunderbird/releases/$VERSION/linux-i686/xpi/*.xpi upstream

for XPI in `ls upstream`; do
    LOCALE=`basename $XPI .xpi`
    mkdir upstream/$LOCALE
    unzip -o -q -d upstream/$LOCALE upstream/$XPI
    cd upstream/$LOCALE
    if [ -f chrome/$LOCALE.jar ]; then
        JAR=$LOCALE.jar
    else
        JAR=`echo $XPI | sed --posix 's|-.*||'`.jar
    fi
    if [ -f chrome/$JAR ]; then
        unzip -o -q -d chrome chrome/$JAR
        rm -f chrome/$JAR
    fi
    cd $TMPDIR/icedove-l10n-$VERSIONWITHOUTESR
    rm upstream/$XPI
done

# en-US is integrated in icedove itself
cd $TMPDIR/icedove-l10n-$VERSIONWITHOUTESR
rm -rf upstream/en-US
rm -rf ftp.mozilla.org
cd ..
tar -zcf icedove-l10n_$VERSIONWITHOUTESR.orig.tar.gz icedove-l10n-$VERSIONWITHOUTESR
cp icedove-l10n_$VERSIONWITHOUTESR.orig.tar.gz $CURDIR/..
rm -rf $TMPDIR/icedove-l10n-$VERSIONWITHOUTESR

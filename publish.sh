#!/bin/bash
# Launchpad publishing script
# Copyright 2012 - Pavel Kalian (pavel@kalian.cz)
# Licensed under the terms of GPLv2+
VERSION=4.1.1317
AUTHOR='Pavel Kalian <pavel@kalian.cz>'
DATE=`date -R`
SERIES=1
Ubuntus=('xenial' 'wily' 'vivid' 'trusty' 'precise')
LPUSER='nohal'
WORKDIR=/tmp/launchpad
BRANCH=opencpngithub/master

MYDIR=`pwd`
if [ $# -lt 1 ] ; then
 echo You must supply changelog message
 exit 0 
fi

mkdir $WORKDIR
cd ..
git archive $BRANCH | tar -x -C $WORKDIR

rm -rf $WORKDIR/wxWidgets
rm -rf $WORKDIR/buildosx
rm -rf $WORKDIR/buildwin
rm -rf $WORKDIR/buildandroid
rm -rf $WORKDIR/plugins/grib_pi/src/bzip2
rm -rf $WORKDIR/plugins/grib_pi/src/zlib-1.2.3
rm -rf $WORKDIR/data/tcdata
rm -rf $WORKDIR/data/doc/images
rm -rf $WORKDIR/data/doc/help_en_US.html
rm -rf $WORKDIR/data/gshhs
rm -rf $WORKDIR/data/wvsdata
rm $WORKDIR/include/tinyxml.h $WORKDIR/src/tinyxml.cpp $WORKDIR/src/tinyxmlerror.cpp $WORKDIR/src/tinyxmlparser.cpp
rm -rf $WORKDIR/include/GL/

TOMOVE=`ls -d $WORKDIR/*`

mkdir $WORKDIR/opencpn
mv $TOMOVE $WORKDIR/opencpn

tar -cf $WORKDIR/opencpn_$VERSION.orig.tar -C $WORKDIR/opencpn .
xz $WORKDIR/opencpn_$VERSION.orig.tar

cd launchpad
cp -rf opencpn/* $WORKDIR/opencpn

read -p "Press [Enter] to publish (now it's time to apply patches manually if needed)"

for u in "${Ubuntus[@]}"
do
 cat changelog.tpl|sed "s/VERSION/$VERSION/g"|sed "s/UBUNTU/$u/g"|sed "s/SERIES/$SERIES/g"|sed "s/MESSAGE/$1/g"|sed "s/AUTHOR/$AUTHOR/g"|sed "s/TIMESTAMP/$DATE/g" > $WORKDIR/dummy
 cat $WORKDIR/opencpn/debian/changelog >> $WORKDIR/dummy
 mv $WORKDIR/dummy $WORKDIR/opencpn/debian/changelog
 cd $WORKDIR/opencpn
 debuild -k0xB43F1889 -S
 #dput -f ppa:$LPUSER/opencpn ../opencpn_$VERSION-0~"$u""$SERIES"_source.changes
 dput -f ppa ../opencpn_$VERSION-0~"$u""$SERIES"_source.changes
 cd $MYDIR
done

cp $WORKDIR/opencpn/debian/changelog opencpn/debian
rm -rf $WORKDIR

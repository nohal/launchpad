#!/bin/bash
# Launchpad publishing script
# Copyright 2012 - Pavel Kalian (pavel@kalian.cz)
# Licensed under the terms of GPLv2+
VERSION=0.0.8.1
AUTHOR='Pavel Kalian <pavel@kalian.cz>'
DATE=`date -R`
SERIES=1
Ubuntus=('bionic' 'artful' 'xenial' 'trusty' 'precise')
LPUSER='nohal'
WORKDIR=/tmp/launchpad
SRC="https://codeload.github.com/nohal/libbsb/tar.gz/v0.0.8"

MYDIR=`pwd`
if [ $# -lt 1 ] ; then
 echo You must supply changelog message
 exit 0 
fi

mkdir -p $WORKDIR

curl -o src.tar.gz $SRC

tar zxf src.tar.gz -C $WORKDIR
rm -rf src.tar.gz

TOMOVE=`ls -d $WORKDIR/*`

mkdir $WORKDIR/libbsb
mv $TOMOVE/* $WORKDIR/libbsb

tar -cf $WORKDIR/libbsb_$VERSION.orig.tar -C $WORKDIR/libbsb .
xz $WORKDIR/libbsb_$VERSION.orig.tar

cp -rf libbsb/libbsb/* $WORKDIR/libbsb

read -p "Press [Enter] to publish (now it's time to apply patches manually if needed)"

for u in "${Ubuntus[@]}"
do
 cat changelog-libbsb.tpl|sed "s/VERSION/$VERSION/g"|sed "s/UBUNTU/$u/g"|sed "s/SERIES/$SERIES/g"|sed "s/MESSAGE/$1/g"|sed "s/AUTHOR/$AUTHOR/g"|sed "s/TIMESTAMP/$DATE/g" > $WORKDIR/dummy
 cat $WORKDIR/libbsb/debian/changelog >> $WORKDIR/dummy
 mv $WORKDIR/dummy $WORKDIR/libbsb/debian/changelog
 cd $WORKDIR/libbsb
 debuild -k0xB43F1889 -S
 #dput -f ppa:$LPUSER/libbsb ../libbsb_$VERSION-0~"$u""$SERIES"_source.changes
 dput -f ppa ../libbsb_$VERSION-0~"$u""$SERIES"_source.changes
 cd $MYDIR
done

cp $WORKDIR/libbsb/debian/changelog libbsb/debian
rm -rf $WORKDIR

#!/bin/bash
# Launchpad publishing script
# Copyright 2012 - Pavel Kalian (pavel@kalian.cz)
# Licensed under the terms of GPLv2+
VERSION=3.3.2107.1
AUTHOR='Pavel Kalian <pavel@kalian.cz>'
DATE=`date -R`
SERIES=1
Ubuntus=('lucid' 'precise' 'trusty' 'utopic')
LPUSER='nohal'
PPA='opencpn'
WORKDIR=/tmp/launchpad

MYDIR=`pwd`
if [ $# -lt 1 ] ; then
 echo You must supply changelog message
 exit 0
fi

mkdir $WORKDIR
cp opencpn-doc_$VERSION.tar.xz $WORKDIR/opencpn-doc_$VERSION.orig.tar.xz
cp -rf opencpn-doc $WORKDIR
tar Jxf opencpn-doc_$VERSION.tar.xz -C $WORKDIR/opencpn-doc
mv $WORKDIR/opencpn-doc/opencpn/doc $WORKDIR/opencpn-doc
rm -rf $WORKDIR/opencpn-doc/opencpn

read -p "Press [Enter] to publish (now it's time to apply patches manually if needed)"

for u in "${Ubuntus[@]}"
do
 cat changelog-doc.tpl|sed "s/VERSION/$VERSION/g"|sed "s/UBUNTU/$u/g"|sed "s/SERIES/$SERIES/g"|sed "s/MESSAGE/$1/g"|sed "s/AUTHOR/$AUTHOR/g"|sed "s/TIMESTAMP/$DATE/g" > $WORKDIR/dummy
 cat $WORKDIR/opencpn-doc/debian/changelog >> $WORKDIR/dummy
 mv $WORKDIR/dummy $WORKDIR/opencpn-doc/debian/changelog
 cd $WORKDIR/opencpn-doc
 debuild -k0xB43F1889 -S
 dput -f ppa ../opencpn-doc_$VERSION-0~"$u""$SERIES"_source.changes
 cd $MYDIR
done

cp $WORKDIR/opencpn-doc/debian/changelog opencpn-doc/debian
read -p "Done. Press [Enter] to continue and delete the working directory."
rm -rf $WORKDIR

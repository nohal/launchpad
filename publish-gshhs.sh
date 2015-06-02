#!/bin/bash
# Launchpad publishing script
# Copyright 2012 - Pavel Kalian (pavel@kalian.cz)
# Licensed under the terms of GPLv2+
VERSION=2.2.4
AUTHOR='Pavel Kalian <pavel@kalian.cz>'
DATE=`date -R`
SERIES=2
Ubuntus=('precise' 'trusty' 'utopic' 'vivid' 'wily')
LPUSER='nohal'
PPA='opencpn-data'
WORKDIR=/tmp/launchpad

MYDIR=`pwd`
if [ $# -lt 1 ] ; then
 echo You must supply changelog message
 exit 0
fi

mkdir $WORKDIR
cp opencpn-gshhs_$VERSION.tar.xz $WORKDIR/opencpn-gshhs_$VERSION.orig.tar.xz
cp -rf opencpn-gshhs $WORKDIR
tar Jxf opencpn-gshhs_$VERSION.tar.xz -C $WORKDIR/opencpn-gshhs
mv $WORKDIR/opencpn-gshhs/opencpn/gshhs $WORKDIR/opencpn-gshhs
rm -rf $WORKDIR/opencpn-gshhs/opencpn

read -p "Press [Enter] to publish (now it's time to apply patches manually if needed)"

for u in "${Ubuntus[@]}"
do
 cat changelog-gshhs.tpl|sed "s/VERSION/$VERSION/g"|sed "s/UBUNTU/$u/g"|sed "s/SERIES/$SERIES/g"|sed "s/MESSAGE/$1/g"|sed "s/AUTHOR/$AUTHOR/g"|sed "s/TIMESTAMP/$DATE/g" > $WORKDIR/dummy
 cat $WORKDIR/opencpn-gshhs/debian/changelog >> $WORKDIR/dummy
 mv $WORKDIR/dummy $WORKDIR/opencpn-gshhs/debian/changelog
 cd $WORKDIR/opencpn-gshhs
 debuild -k0xB43F1889 -S
 dput -f ppa-data ../opencpn-gshhs_$VERSION-0~"$u""$SERIES"_source.changes
 cd $MYDIR
done

cp $WORKDIR/opencpn-gshhs/debian/changelog opencpn-gshhs/debian
read -p "Done. Press [Enter] to continue and delete the working directory."
rm -rf $WORKDIR

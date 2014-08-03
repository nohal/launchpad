#!/bin/bash
# Launchpad publishing script
# Copyright 2012 - Pavel Kalian (pavel@kalian.cz)
# Licensed under the terms of GPLv2+
VERSION=3.3.1932
AUTHOR='Pavel Kalian <pavel@kalian.cz>'
DATE=`date -R`
SERIES=1
Ubuntus=('lucid' 'precise' 'trusty' 'utopic')
LPUSER='nohal'
PPA='opencpn-data'
WORKDIR=/tmp/launchpad

MYDIR=`pwd`
if [ $# -lt 1 ] ; then
 echo You must supply changelog message
 exit 0
fi

mkdir $WORKDIR
cp opencpn-tcdata_$VERSION.tar.bz2 $WORKDIR/opencpn-tcdata_$VERSION.orig.tar.bz2
cp -rf opencpn-tcdata $WORKDIR
tar jxf opencpn-tcdata_$VERSION.tar.bz2 -C $WORKDIR/opencpn-tcdata
mv $WORKDIR/opencpn-tcdata/opencpn/tcdata $WORKDIR/opencpn-tcdata
rm -rf $WORKDIR/opencpn-tcdata/opencpn

read -p "Press [Enter] to publish (now it's time to apply patches manually if needed)"

for u in "${Ubuntus[@]}"
do
 cat changelog-tcdata.tpl|sed "s/VERSION/$VERSION/g"|sed "s/UBUNTU/$u/g"|sed "s/SERIES/$SERIES/g"|sed "s/MESSAGE/$1/g"|sed "s/AUTHOR/$AUTHOR/g"|sed "s/TIMESTAMP/$DATE/g" > $WORKDIR/dummy
 cat $WORKDIR/opencpn-tcdata/debian/changelog >> $WORKDIR/dummy
 mv $WORKDIR/dummy $WORKDIR/opencpn-tcdata/debian/changelog
 cd $WORKDIR/opencpn-tcdata
 debuild -k0xB43F1889 -S
 dput -f ppa-data ../opencpn-tcdata_$VERSION-0~"$u""$SERIES"_source.changes
 cd $MYDIR
done

cp $WORKDIR/opencpn-tcdata/debian/changelog opencpn-tcdata/debian
read -p "Done. Press [Enter] to continue and delete the working directory."
rm -rf $WORKDIR

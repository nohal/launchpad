#!/bin/bash
# Launchpad publishing script
# Copyright 2012 - Pavel Kalian (pavel@kalian.cz)
# Licensed under the terms of GPLv2+
VERSION=1.0.0
AUTHOR='Pavel Kalian <pavel@kalian.cz>'
DATE=`date -R`
SERIES=1
Ubuntus=('vivid' 'utopic' 'trusty' 'precise' 'lucid')
LPUSER='nohal'
PPA='opencpn'
WORKDIR=/tmp/launchpad

MYDIR=`pwd`
if [ $# -lt 1 ] ; then
 echo You must supply changelog message
 exit 0
fi

mkdir $WORKDIR
cp opencpn-plugin-climatology-data_$VERSION.tar.xz $WORKDIR/opencpn-plugin-climatology-data_$VERSION.orig.tar.xz
cp -rf opencpn-plugin-climatology-data $WORKDIR
tar Jxf opencpn-plugin-climatology-data_$VERSION.tar.xz -C $WORKDIR/opencpn-plugin-climatology-data
mv $WORKDIR/opencpn-plugin-climatology-data/climatology_pi/data $WORKDIR/opencpn-plugin-climatology-data
rm -rf $WORKDIR/opencpn-plugin-climatology-data/climatology_pi

read -p "Press [Enter] to publish (now it's time to apply patches manually if needed)"

for u in "${Ubuntus[@]}"
do
 cat changelog-plugin-climatology-data.tpl|sed "s/VERSION/$VERSION/g"|sed "s/UBUNTU/$u/g"|sed "s/SERIES/$SERIES/g"|sed "s/MESSAGE/$1/g"|sed "s/AUTHOR/$AUTHOR/g"|sed "s/TIMESTAMP/$DATE/g" > $WORKDIR/dummy
 cat $WORKDIR/opencpn-plugin-climatology-data/debian/changelog >> $WORKDIR/dummy
 mv $WORKDIR/dummy $WORKDIR/opencpn-plugin-climatology-data/debian/changelog
 cd $WORKDIR/opencpn-plugin-climatology-data
 debuild -k0xB43F1889 -S
 dput -f ppa ../opencpn-plugin-climatology-data_$VERSION-0~"$u""$SERIES"_source.changes
 cd $MYDIR
done

cp $WORKDIR/opencpn-plugin-climatology-data/debian/changelog opencpn-plugin-climatology-data/debian
rm -rf $WORKDIR

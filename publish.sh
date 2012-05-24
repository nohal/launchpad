#!/bin/bash
# Launchpad publishing script
# Copyright 2012 - Pavel Kalian (pavel@kalian.cz)
# Licensed under the terms of GPLv2+
VERSION=2.6.1723
AUTHOR='Pavel Kalian <pavel@kalian.cz>'
DATE=`date -R`
SERIES=1
Ubuntus=('lucid' 'maverick' 'natty' 'oneiric' 'precise' 'quantal')
LPUSER='nohal'
WORKDIR=/tmp/launchpad
BRANCH=master

MYDIR=`pwd`
if [ $# -lt 1 ] ; then
 echo You must supply changelog message
 exit 0 
fi

mkdir /tmp/launchpad
cd ..
git archive $BRANCH | bzip2 > $WORKDIR/opencpn_$VERSION.tar.bz2
cd launchpad
cp $WORKDIR/opencpn_$VERSION.tar.bz2 $WORKDIR/opencpn_$VERSION.orig.tar.bz2
cp -rf opencpn /tmp/launchpad
tar jxf $WORKDIR/opencpn_$VERSION.tar.bz2 -C $WORKDIR/opencpn
for u in "${Ubuntus[@]}"
do
 cat changelog.tpl|sed "s/VERSION/$VERSION/g"|sed "s/UBUNTU/$u/g"|sed "s/SERIES/$SERIES/g"|sed "s/MESSAGE/$1/g"|sed "s/AUTHOR/$AUTHOR/g"|sed "s/TIMESTAMP/$DATE/g" > $WORKDIR/dummy
 cat $WORKDIR/opencpn/debian/changelog >> $WORKDIR/dummy
 mv $WORKDIR/dummy $WORKDIR/opencpn/debian/changelog
 cd $WORKDIR/opencpn
 debuild -S
 dput -f ppa:$LPUSER/opencpn ../opencpn_$VERSION-0~"$u""$SERIES"_source.changes
 cd $MYDIR
done

cp $WORKDIR/opencpn/debian/changelog opencpn/debian
rm -rf /tmp/launchpad

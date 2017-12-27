#!/bin/bash
# Launchpad publishing script
# Copyright 2012 - Pavel Kalian (pavel@kalian.cz)
# Licensed under the terms of GPLv2+
PACKAGER='Pavel Kalian <pavel@kalian.cz>'
DATE=`date -R`
SERIES=1
Ubuntus=('bionic' 'artful' 'zesty' 'xenial' 'vivid' 'trusty' 'precise')
LPUSER='nohal'
WORKDIR=/tmp/launchpad

MYDIR=`pwd`
if [ $# -lt 5 ] ; then
 echo "Usage $0 <plugin name> <source tar.gz URL> <version> <Author> <Changelog message> [Additional dependencies] [Additional build dependencies]"
 echo "Ex. $0 myplugin https://github.com/myuser/myplugin_pi/archive/v1.0.tar.gz 1.0.0 \"Joe Black <joe@black.xy>\" \"Version 1.0.0\" "libcurl3, opencpn-plugin-climatology-data" libcurl4-openssl-dev"
 exit 0 
fi

if [ $# -ge 6 ] ; then
  DEPENDENCIES=", $6"
else
  DEPENDENCIES=''
fi

if [ $# -ge 7 ] ; then
  BUILDDEPS=", $7"
else
  BUILDDEPS=''
fi

PLUGIN=$1
SRCURL=$2
FILENAME=`basename ${SRCURL}`
VERSION=$3
AUTHOR=$4
MSG=$5

wget ${SRCURL}

if [ -d ${WORKDIR} ]; then
  rm -rf ${WORKDIR}
fi
mkdir -p ${WORKDIR}/opencpn-plugin-${PLUGIN}

tar zxf ${FILENAME} --strip 1 -C $WORKDIR/opencpn-plugin-${PLUGIN}
rm ${FILENAME}
cd $WORKDIR/opencpn-plugin-${PLUGIN}
tar c .|bzip2 >${WORKDIR}/opencpn-plugin-${PLUGIN}_${VERSION}.orig.tar.bz2
cd ${MYDIR}

cp -rf opencpn-plugin-tpl/* $WORKDIR/opencpn-plugin-${PLUGIN}

read -p "Press [Enter] to publish (now it's time to apply patches manually if needed)"

for u in "${Ubuntus[@]}"
do
  cat changelog-plugin-tpl.tpl|sed "s/PLUGIN/${PLUGIN}/g"|sed "s/VERSION/${VERSION}/g"|sed "s/UBUNTU/${u}/g"|sed "s/SERIES/${SERIES}/g"|sed "s/MESSAGE/${MSG}/g"|sed "s/PACKAGER/${PACKAGER}/g"|sed "s/TIMESTAMP/${DATE}/g" > ${WORKDIR}/opencpn-plugin-${PLUGIN}/debian/changelog
  if [ -f changelog-plugin-${PLUGIN} ]; then
    cat changelog-plugin-${PLUGIN} >> ${WORKDIR}/opencpn-plugin-${PLUGIN}/debian/changelog
  fi
  cp ${WORKDIR}/opencpn-plugin-${PLUGIN}/debian/changelog changelog-plugin-${PLUGIN}
  cd ${WORKDIR}/opencpn-plugin-${PLUGIN}
  sed -i -e "s/PLUGIN/${PLUGIN}/g" ${WORKDIR}/opencpn-plugin-${PLUGIN}/debian/control
  sed -i -e "s/VERSION/${VERSION}/g" ${WORKDIR}/opencpn-plugin-${PLUGIN}/debian/control
  sed -i -e "s/DEPENDENCIES/${DEPENDENCIES}/g" ${WORKDIR}/opencpn-plugin-${PLUGIN}/debian/control
  sed -i -e "s/BUILDDEPS/${BUILDDEPS}/g" ${WORKDIR}/opencpn-plugin-${PLUGIN}/debian/control
  sed -i -e "s/AUTHOR/${AUTHOR}/g" ${WORKDIR}/opencpn-plugin-${PLUGIN}/debian/copyright
  sed -i -e "s/PLUGIN/${PLUGIN}/g" ${WORKDIR}/opencpn-plugin-${PLUGIN}/debian/copyright

  debuild -k0xB43F1889 -S
  dput -f ppa ../opencpn-plugin-${PLUGIN}_${VERSION}-0~"$u""${SERIES}"_source.changes
  cd ${MYDIR}
done

rm -rf ${WORKDIR}

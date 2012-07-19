#!/bin/bash
#packaging libqq-pidgin for lucid(default), maverick, natty and oneiric

#define some variables
basedir=/home/lainme/packaging/libqq-pidgin
releases=("lucid" "maverick" "natty" "oneiric")
sourcecmd="svn checkout http://libqq-pidgin.googlecode.com/svn/trunk/"
timestamp=`date -R`

#change to working dir
cd $basedir

#read version and comment
version=`head -n 1 debian/changelog | sed -e "s/.*(\([^~]*\).*/\\1/"` #get the old version
read -e -i $version -p "Input version: " input
read -p "Input comment: " comment
version=${input:-$version}


#get source code
majorver=${version%%-*} #get the major version
sourcedir=libqq-pidgin-$majorver
rm -rf libqq-pidgin* #clean source dir
$sourcecmd $sourcedir
rm -rf $sourcedir/.[^.]*

#package it
for item  in ${releases[*]};do

string="libqq-pidgin ($version~lainme~$item) $item; urgency=low\n\
\n\
  * $comment\n\
\n\
 -- lainme <lainme993@gmail.com>  $timestamp\n\
"

#create dir if not exist
if [ ! -d $basedir/$item ]; then
    mkdir $basedir/$item
fi

rm -rf $basedir/$item/* #clean dir

cp -r "$basedir/$sourcedir" "$basedir/$item" 
cp -r "$basedir/debian" "$basedir/$item/$sourcedir"
sed -i "1i $string" "$basedir/$item/$sourcedir/debian/changelog"

#build and upload
cd $basedir/$item/$sourcedir
debuild -S -sa
cd ..
dput ppa:lainme/libqq "libqq-pidgin_"$version"~lainme~"$item"_source.changes"

done

#backup debian dir
cp -r "$basedir/lucid/$sourcedir/debian" $basedir

#!/bin/sh -e
# Get the snowball source and documentation from SVN and call the
# script which makes the website.

tmpdir="/tmp/snowball_bootstrap$$"
trap "(rm -rf $tmpdir;echo \"bootstrap.sh failed\")" EXIT

svnbase="svn://snowball.tartarus.org/snowball/trunk/"

rm -rf ${tmpdir}
mkdir -p ${tmpdir}
chmod go= ${tmpdir}
chmod g+s ${tmpdir}

cd ${tmpdir}
svn export -q ${svnbase}
cd trunk

/s1/snowball-svn/snowball/hooks/make_website.sh

trap EXIT
rm -rf ${tmpdir}

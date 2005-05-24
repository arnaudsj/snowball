#!/bin/sh -e
# Get the snowball source and documentation from SVN and call the
# script which makes the website.

mailcmd="/usr/lib/sendmail -oem -t -oi"

tmpdir="/tmp/snowball_bootstrap$$"
logfile="${tmpdir}/log"

#trap "(echo \"bootstrap.sh failed\";
trap "(rm -rf $tmpdir;echo \"bootstrap.sh failed\";
{
    echo \"From: richard@tartarus.org\";
    echo \"To: richard@tartarus.org\";
    echo \"Subject: Snowball - bootstrap.sh failed\";
    echo;
    echo \"Date: `date`\";
    echo;
    /usr/bin/env;
    echo;
    cat $logfile;
} | $mailcmd )" EXIT

svnbase="svn://snowball.tartarus.org/snowball/trunk/"

rm -rf ${tmpdir}
mkdir -p ${tmpdir}
chmod go= ${tmpdir}
chmod g+s ${tmpdir}

cd ${tmpdir}
svn export ${svnbase} >$logfile 2>&1
cd trunk

/s1/snowball-svn/snowball/hooks/make_website.sh >>$logfile 2>&1

trap EXIT
rm -rf ${tmpdir}

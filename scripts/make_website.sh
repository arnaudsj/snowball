#!/bin/sh -e
# Must be called from a directory which the snowball module
# has been checked out into.
# Builds the website, placing all the generated files (such as
# tarballs and generated code files) in the appropriate places.

# Directory to place the built website into.
htmldir_local="/home/www/snowball.tartarus.org/"
htmldir_local="/home/richard/snowballweb/"

tmpdir="/tmp/snowball_mkwebsite$$"
trap "(rm -rf $tmpdir;echo \"make_website.sh failed\")" EXIT
tmpdir=`pwd`/newsite
trap EXIT

rm -rf ${tmpdir}
mkdir -p ${tmpdir}
chmod go= ${tmpdir}
chmod g+s ${tmpdir}

cp -a snowball ${tmpdir}
cp -a website ${tmpdir}
find ${tmpdir} -name .svn | xargs rm -rf

cd ${tmpdir}/snowball
make dist >/dev/null
cd -

cd snowball/algorithms
langs=`find * -type d -maxdepth 0 -not -name .svn`
cd -

# Build the website, excluding the data files.
for lang in $langs
do
  cp -a ${tmpdir}/snowball/algorithms/${lang}/stem.sbl ${tmpdir}/website/algorithms/${lang}/stem.sbl
  cp -a ${tmpdir}/snowball/src_c/stem_${lang}.c        ${tmpdir}/website/algorithms/${lang}/stem.c
  cp -a ${tmpdir}/snowball/src_c/stem_${lang}.h        ${tmpdir}/website/algorithms/${lang}/stem.h
done

# Build a tarball of the whole website, together with the code,
# but excluding the data.
cd ${tmpdir}
mv website snowball_web_and_code
tar zcf snowball_web_and_code.tgz snowball_web_and_code
mv snowball_web_and_code website
cd -

# Add the data files to the website
cd data
datalangs=`find * -type d -maxdepth 0 -not -name .svn`
for lang in $datalangs
do
  cp -a ${lang}/*.txt ${tmpdir}/website/algorithms/${lang}/
done
cd -

# Build a tarball of the whole website, together with the code and data.
cd ${tmpdir}
mv website snowball_all
tar zcf snowball_all.tgz snowball_all
mv snowball_all website
cd -

# Build tarballs of the files for each individual stemmer.
for lang in $datalangs
do
  cd ${tmpdir}/website/algorithms/
  # kraaij_pohlmann voc.txt and output.txt don't exist.
  if [ -e ${lang}/voc.txt ]
  then
    tar zcf ${lang}/tarball.tgz \
      ${lang}/stem.sbl \
      ${lang}/stem.c \
      ${lang}/stem.h \
      ${lang}/voc.txt \
      ${lang}/output.txt \
      ${lang}/stemmer.html
  fi
  cd -
done

mkdir -p ${tmpdir}/website/dist
mv ${tmpdir}/snowball_all.tgz ${tmpdir}/website/dist/
mv ${tmpdir}/snowball_web_and_code.tgz ${tmpdir}/website/dist/
mv ${tmpdir}/snowball/dist/snowball_code.tgz ${tmpdir}/website/dist/
mv ${tmpdir}/snowball/dist/libstemmer_c.tgz ${tmpdir}/website/dist/
mv ${tmpdir}/snowball/dist/libstemmer_java.tgz ${tmpdir}/website/dist/

# Update mail archives
# HM_LINKQUOTES=1 HM_REVERSE=1 HM_MONTHLY_INDEX=1 /home/richard/software/hypermail-2.1.3/src/hypermail -m /usr/data/mailman/archives/private/snowball-discuss.mbox/snowball-discuss.mbox -d archives/snowball-discuss -l "Snowball Discuss"
# HM_LINKQUOTES=1 HM_REVERSE=1 HM_MONTHLY_INDEX=1 /home/richard/software/hypermail-2.1.3/src/hypermail -m /usr/data/mailman/archives/private/snowball-commits.mbox/snowball-commits.mbox -d archives/snowball-commits -l "Snowball Commits"

rsync -q -a -r --delete --delete-after ${tmpdir}/website/ ${htmldir_local}

trap EXIT
rm -rf ${tmpdir}

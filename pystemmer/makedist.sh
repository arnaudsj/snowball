#!/bin/sh

rm -fr dist
mkdir dist

cd libstemmer_c; make dist; cd .. 
python setup.py install --install-lib=`pwd`/dist
epydoc --html -o docs/html Stemmer.so

python setup.py sdist
(cd dist &&
 tar zxf PyStemmer*.tar.gz &&
 cd `find ./ -type d|head -n 2|tail -n 1` &&
 python setup.py install --install-lib=`pwd` &&
 python setup.py sdist &&
 python runtests.py
)

#!/bin/bash
# Author: Amos Kong <akong@redhat.com>
# June 27, 2012
# reference:
#   http://idolinux.blogspot.com.au/2011/02/atlas-numpy-scipy-build-on-rhel-6.html

echo "request tools: gcc-gfortran (gfortran), gnome-applets (cpufreq-selector) gcc-c++ (g++)"
yum install gcc-gfortran gnome-applets gcc-c++

cd /usr/local/src
wget http://www.netlib.org/lapack/lapack-3.3.0.tgz
tar xzvf lapack-3.3.0.tgz
cd lapack-3.3.0
cp INSTALL/make.inc.gfortran make.inc
echo "[debug] edit make.inc, add -fPIC to OPTS and NOOPT"
echo "OPTS     = -O2 -fPIC" >> make.inc
echo "NOOPT     = -O0 -fPIC" >> make.inc

cd /usr/local/src/lapack-3.3.0/
make 2>&1 | tee log.make
make blaslib lapacklib tmglib lapack_testing 2>&1 | tee log.makeall

cd /usr/local/src
wget http://downloads.sourceforge.net/project/math-atlas/Developer%20%28unstable%29/3.9.35/atlas3.9.35.tar.bz2
tar xjvf atlas3.9.35.tar.bz2
mv ATLAS atlas-3.9.35
cd atlas-3.9.35
mkdir ATLAS_LINUX ; cd ATLAS_LINUX
cpufreq-selector -g performance
../configure -Fa alg -fPIC -Si cputhrchk 0 --prefix=/usr/local/atlas-3.9.35 --with-netlib-lapack-tarfile=/usr/local/src/lapack-3.3.0.tgz 2>&1 | tee log.config
make 2>&1 | tee log.make
echo "[debug] THIS WILL TAKE HOURS TO MAKE!!!!!!"
make install 2>&1 | tee log.install
cd /usr/local ; ln -s atlas-3.9.35 atlas
export LD_LIBRARY_PATH=/usr/local/atlas/lib:$LD_LIBRARY_PATH

cd /usr/local/src
wget http://cdnetworks-us-2.dl.sourceforge.net/project/numpy/NumPy/1.5.1/numpy-1.5.1.tar.gz
tar xzvf numpy-1.5.1.tar.gz
cd numpy-1.5.1
cp site.cfg.example site.cfg
echo "[debug] edit site.cfg"
echo -e "[DEFAULT]\nlibrary_dirs = /usr/local/atlas/lib\ninclude_dirs = /usr/local/atlas/include" >> site.cfg
echo -e "[atlas]\natlas_libs = lapack, f77blas, cblas, atlas" >> site.cfg

python setup.py build 2>&1 | tee log.build
python setup.py install --prefix=/usr/local/numpy-1.5.1 2>&1 | tee log.install
cd /usr/local ; ln -s numpy-1.5.1 numpy
export PYTHONPATH=$PYTHONPATH:/usr/local/numpy/lib64/python2.6/site-packages
export PATH=/usr/local/numpy/bin:$PATH
python /usr/local/numpy/lib64/python2.6/site-packages/numpy/distutils/system_info.py

cd /usr/local/src
wget http://cdnetworks-us-2.dl.sourceforge.net/project/scipy/scipy/0.9.0rc3/scipy-0.9.0rc3.tar.gz
tar xzvf scipy-0.9.0rc3.tar.gz
cd scipy-0.9.0rc3
python setup.py build 2>&1 | tee log.build
python setup.py install --prefix=/usr/local/scipy-0.9.0rc3 2>&1 | tee log.install
cd /usr/local ; ln -s scipy-0.9.0rc3 scipy

echo "Exec status: $?"

export PYTHONPATH=$PYTHONPATH:/usr/local/numpy/lib64/python2.6/site-packages:/usr/local/scipy/lib64/python2.6/site-packages

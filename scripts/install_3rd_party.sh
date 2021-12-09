#!/bin/bash

DEBIAN_FRONTEND=noninteractive
apt-get -qq update 

# need for Docker
apt-get install -y --no-install-recommends apt-utils


# RGL and GLU
apt-get install -y mesa-common-dev libglu1-mesa-dev 

# Standard/Common Stuff/System
apt-get install -y build-essential cmake 
apt-get install -y zlib1g-dev libbz2-dev liblzma-dev lzma
apt-get install -y bzip2
apt-get install -y libboost-all-dev
apt-get install -y libfftw3-dev ;
apt-get install -y libjq-dev ;
apt-get install -y libudunits2-dev ;
apt-get install -y udunits
apt-get install -y libprotobuf-dev protobuf-compiler libprotoc-dev
apt-get install -y gdal
apt-get install -y cargo
apt-get install -y libgit2-dev
apt-get install -y libxml2-dev
apt-get install -y libcurl4-openssl-dev
apt-get install -y libssl-dev
apt-get install -y curl


# Statistics stuff
apt-get install -y jags

# Web/Internet Stuff
apt-get install -y libssh-dev;
apt-get install -y libv8-dev;
apt-get install -y libsecret-1-dev
apt-get install -y libsodium-dev
apt-get install -y libzmq3-dev

# Data formats
apt-get install -y libhdf5-serial-dev libhdf5-dev ;

# Image devices
apt-get install -y libpng-dev
apt-get install -y libtiff-dev
apt-get install -y libmng2 ; 

# OCR Image
# apt-get install -y libtesseract-dev libleptonica-dev tesseract-ocr-eng
# apt-get install -y libpoppler-cpp-dev

# Image utils
apt-get install -y imagej
apt-get install -y libav-tools
apt-get install -y ffmpeg --allow-unauthenticated 
apt-get install -y libmagick++-dev ;
apt-get install -y ghostscript imagemagick
apt-get install -y libwebp-dev

# Science/Specific 
# apt-get install -y bowtie2
# apt-get install -y qgis

# apt-get install -y dcmtk ;
# apt-get install -y insighttoolkit4-python libinsighttoolkit4-dev



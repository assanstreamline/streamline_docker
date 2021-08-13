#!/bin/bash

DEBIAN_FRONTEND=noninteractive
sudo apt-get -qq update 

# need for Docker
sudo apt-get install -y --no-install-recommends apt-utils


# RGL and GLU
sudo apt-get install -y mesa-common-dev libglu1-mesa-dev 

# Standard/Common Stuff/System
sudo apt-get install -y build-essential cmake 
sudo apt-get install -y zlib1g-dev libbz2-dev liblzma-dev lzma
sudo apt-get install -y bzip2
sudo apt-get install -y libboost-all-dev
sudo apt-get install -y libfftw3-dev ;
sudo apt-get install -y libjq-dev ;
sudo apt-get install -y libudunits2-dev ;
sudo apt-get install -y udunits
sudo apt-get install -y libprotobuf-dev protobuf-compiler libprotoc-dev
sudo apt-get install -y gdal
sudo apt-get install -y cargo
sudo apt-get install -y libgit2-dev
sudo apt-get install -y libxml2-dev
sudo apt-get install -y libcurl4-openssl-dev
sudo apt-get install -y libssl-dev
sudo apt-get install -y curl


# Statistics stuff
sudo apt-get install -y jags

# Web/Internet Stuff
sudo apt-get install -y libssh-dev;
sudo apt-get install -y libv8-dev;
sudo apt-get install -y libsecret-1-dev
sudo apt-get install -y libsodium-dev
sudo apt-get install -y libzmq3-dev

# Data formats
sudo apt-get install -y libhdf5-serial-dev libhdf5-dev ;

# Image devices
sudo apt-get install -y libpng-dev
sudo apt-get install -y libtiff-dev
sudo apt-get install -y libmng2 ; 

# OCR Image
# sudo apt-get install -y libtesseract-dev libleptonica-dev tesseract-ocr-eng
# sudo apt-get install -y libpoppler-cpp-dev

# Image utils
sudo apt-get install -y imagej
sudo apt-get install -y libav-tools
sudo apt-get install -y ffmpeg --allow-unauthenticated 
sudo apt-get install -y libmagick++-dev ;
sudo apt-get install -y ghostscript imagemagick
sudo apt-get install -y libwebp-dev

# Science/Specific 
# sudo apt-get install -y bowtie2
# sudo apt-get install -y qgis

# sudo apt-get install -y dcmtk ;
# sudo apt-get install -y insighttoolkit4-python libinsighttoolkit4-dev



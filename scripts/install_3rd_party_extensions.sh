#!/bin/bash
OS_CODENAME=$(lsb_release -cs)
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq keyboard-configuration


# Install req for ChemmineOB
apt-get update -qq

apt-get install -y software-properties-common || true

if [ "${OS_CODENAME}" == "focal" ]; then
echo "deb-src http://archive.ubuntu.com/ubuntu/ focal universe" >> /etc/apt/sources.list
echo "deb-src http://archive.ubuntu.com/ubuntu/ focal-updates universe" >> /etc/apt/sources.list
apt-get update -qq
apt-get install -y libopenbabel-dev libeigen3-dev || true
else
apt-get update -qq
apt-get install -y libopenbabel-dev || true
fi

# Install req for RAmazonS3
apt-get update -qq
apt-get install -y libdigest-hmac-perl || true

# Install req for RSelenium
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y libssl-dev phantomjs || true

# Install req for Rglpk
apt-get update -qq
apt-get install -y libglpk-dev || true

# Install req for Rmpfr
apt-get update -qq
apt-get install -y libmpfr-dev || true

# Install req for Rpoppler
apt-get update -qq
apt-get install -y libpoppler-glib-dev || true

# Install req for Rsymphony
apt-get update -qq
apt-get install -y libbz2-dev coinor-libsymphony-dev coinor-libcgl-dev || true

# Install req for V8
apt-get update -qq
apt-get -y install libv8-dev || true

# Install req for animation

# Even though animation depends upon magick, the test framework doesn't run
# the installers for imported packages, so we need to install libmagick++-dev
# here as well.
if [ $OS_CODENAME == "xenial" ]; then
add-apt-repository -y ppa:cran/imagemagick
fi
# check for supported platform (whitelisted ubuntu versions)
if [ $OS_CODENAME == "xenial" ]; then
add-apt-repository ppa:jonathonf/ffmpeg-4
fi
apt-get update -qq
if [ $OS_CODENAME == "focal" ]; then
apt-get install -y libmagick++-dev ffmpeg graphicsmagick pdftk x264 x265  || true
else
apt-get install -y libmagick++-dev ffmpeg graphicsmagick libav-tools pdftk x264 x265 || true
fi

# Install req for av
# need for add-apt-repository
apt-get update -qq
# check for supported platform (whitelisted ubuntu versions)
if [ $OS_CODENAME == "xenial" ]; then
add-apt-repository ppa:jonathonf/ffmpeg-4 || true
fi
apt-get update -qq
apt-get install -y libavfilter-dev libavformat-dev || true

# Install req for convertGraph
apt-get update -qq
apt-get install -y phantomjs || true

# Install req for docxtractr
apt-get update -qq

add-apt-repository ppa:libreoffice/ppa
apt-get update -qq
apt-get install -y libreoffice || true

# Install req for gdalUtils
if [ "${OS_CODENAME}" == "xenial" ]; then
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x089EBE08314DF160
echo "deb http://ppa.launchpad.net/ubuntugis/ppa/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list.d/ubuntugis-ppa.list
fi
apt-get update -qq
apt-get install -y libgdal-dev libproj-dev gdal-bin || true

# Install req for gert
# install libgit2 on xenial only
if [ "${OS_CODENAME}" == "xenial" ]; then
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0xb3cf35c315b55a9f
echo "deb http://ppa.launchpad.net/cran/libgit2/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list.d/cran-libgit2-ppa.list
fi
apt-get update -qq
apt-get install -y libgit2-dev || true

# Install req for gmp
apt-get update -qq
if [ ${OS_CODENAME} == "xenial" ]; then
apt-get install -y libgmp10-dev || true
else
apt-get install -y libgmp-dev || true
fi

# Install req for gridGraphics
apt-get update -qq
apt-get install -y imagemagick || true

# Install req for gsl
OS_CODENAME=$(lsb_release -cs)
apt-get update -qq
if [ ${OS_CODENAME} == "xenial" ]; then
apt-get install -y libgsl0-dev || true
else
apt-get install -y libgsl-dev || true
fi

# Install req for hunspell
apt-get update -qq
apt-get install -y libhunspell-dev || true

# Install req for igraph
apt-get update -qq
apt-get install -y libglpk-dev || true

# Install req for jqr
apt-get update -qq
# these sysdeps are available by default in bionic
if [ "${OS_CODENAME}" == "xenial" ]; then
add-apt-repository -y ppa:cran/jq
apt-get update -qq
apt-get install -y python-software-properties || true
fi
apt-get install -y libjq-dev || true

# Install req for keyring
apt-get update -qq
apt-get install -y libsecret-1-dev libsodium-dev || true

# Install req for lwgeom
if [ $OS_CODENAME == "xenial" ]; then
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x089EBE08314DF160
echo "deb http://ppa.launchpad.net/ubuntugis/ppa/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list.d/ubuntugis-ppa.list || true
fi
apt-get update -qq
apt-get install -y libudunits2-dev libgdal-dev libgeos-dev libproj-dev || true

# Install req for magick
apt-get update -qq
# these sysdeps are available by default in bionic
if [ ${OS_CODENAME} == "xenial" ]; then
apt-get install -y python-software-properties || true
# PPA has recent ImageMagick versions for for Ubuntu Trusty/Xenial
add-apt-repository -y ppa:cran/imagemagick
apt-get update -qq
fi
apt-get install -y libmagick++-dev || true
if [ ${OS_CODENAME} == "focal" ]; then
# Enable imagemagick ghostscript features
# See https://www.kb.cert.org/vuls/id/332928/
# focal has a new enough version of ghostscript
sed -i "\$i \ \ <policy domain=\"coder\" rights=\"read | write\" pattern=\"{PS,PS2,PS3,EPS,PDF,XPS}\" />" /etc/ImageMagick-6/policy.xml || true
fi

# Install req for ncdf4
apt-get update -qq
apt-get install -y libnetcdf-dev netcdf-bin || true

# Install req for pagedown
apt-get update -qq
# install chrome to use pagedown::chrome_print()
curl -LO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt-get install -y ./google-chrome-stable_current_amd64.deb  || true
rm google-chrome-stable_current_amd64.deb

# Install req for pdftools
apt-get update -qq
apt-get install -y libpoppler-cpp-dev || true

# Install req for pensieve
apt-get update -qq
apt-get install -y pdf2svg librsvg2-bin || true

# Install req for rDEA
apt-get update -qq
apt-get install -y libglpk-dev || true

# Install req for rJava
/usr/bin/R CMD javareconf || true

# Install req for ragg
apt-get update -qq
apt-get install -y libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libharfbuzz-dev libfribidi-dev || true

# Install req for rcbc
apt-get update -qq
apt-get install -y coinor-libcbc-dev coinor-libclp-dev coinor-libcgl-dev libbz2-dev || true

# Install req for rcdd
apt-get update -qq
apt-get install -y libgmp-dev libgmp3-dev || true

# Install req for redland
apt-get update -qq
apt-get install -y librdf0-dev || true

# Install req for rgdal
if [ "${OS_CODENAME}" == "xenial" ]; then
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x089EBE08314DF160
echo "deb http://ppa.launchpad.net/ubuntugis/ppa/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list.d/ubuntugis-ppa.list || true
fi
apt-get update -qq
apt-get install -y libgdal-dev libproj-dev || true

# Install req for rgeos
apt-get update -qq
apt-get install -y libgeos-dev || true

# Install req for rgl
apt-get update -qq
apt-get install -y libgl1-mesa-dev libglu1-mesa-dev || true

# Install req for rsvg
apt-get update -qq
apt-get install -y librsvg2-dev || true

# Install req for seewave
apt-get update -qq
apt-get install -y libsndfile1 libsndfile1-dev || true

# Install req for sf
if [ "${OS_CODENAME}" == "xenial" ]; then
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x089EBE08314DF160
echo "deb http://ppa.launchpad.net/ubuntugis/ppa/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list.d/ubuntugis-ppa.list || true
fi
apt-get update -qq
apt-get install -y libudunits2-dev libgdal-dev libgeos-dev libproj-dev || true

# Install req for sodium
apt-get update -qq
apt-get install -y libsodium-dev || true

# Install req for ssh
apt-get update -qq
apt-get install -y libssh-dev || true

# Install req for staplr
apt-get update -qq
apt-get install -y pdftk || true

# Install req for symengine
apt-get update -qq
apt-get install -y cmake libgmp-dev libmpfr-dev libmpc-dev || true

# Install req for tensorflow
pip3 install --upgrade tensorflow keras scipy h5py pyyaml requests Pillow || true

# Install req for tesseract
apt-get update -qq
apt-get install -y libtesseract-dev libleptonica-dev tesseract-ocr-eng tesseract-ocr-fra || true

# Install req for textshaping
apt-get update -qq
apt-get install -y libharfbuzz-dev libfribidi-dev || true

# Install req for tiff
apt-get update -qq
apt-get install -y libtiff-dev || true

# Install req for tkrplot
apt-get update -qq
apt-get install -y tk tk-dev tcl tcl-dev || true

# Install req for tm
apt-get update -qq
apt-get install -y antiword poppler-utils || true

# Install req for topicmodels
apt-get update -qq
if [ "${OS_CODENAME}" == "xenial" ]; then
apt-get install -y libgsl0-dev libgfortran-5-dev libblas-dev || true
else
apt-get install -y libgsl-dev || true 
fi

# Install req for units
apt-get update -qq
apt-get install -y libudunits2-dev || true

# Install req for xslt
apt-get update -qq
apt-get install -y libxslt1-dev || true


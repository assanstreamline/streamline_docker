# Install req for ChemmineOB
OS_CODENAME=$(lsb_release -cs)
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y software-properties-common || true

if [ "${OS_CODENAME}" == "focal" ]; then
sudo echo "deb-src http://archive.ubuntu.com/ubuntu/ focal universe" >> /etc/apt/sources.list
sudo echo "deb-src http://archive.ubuntu.com/ubuntu/ focal-updates universe" >> /etc/apt/sources.list
sudo apt-get update -qq
sudo apt-get install -y libopenbabel-dev libeigen3-dev || true
else
sudo apt-get update -qq
sudo apt-get install -y libopenbabel-dev || true
fi

# Install req for RAmazonS3
sudo apt-get update -qq
sudo apt-get install -y libdigest-hmac-perl || true

# Install req for RSelenium
sudo apt-get update -qq
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y libssl-dev phantomjs || true

# Install req for Rglpk
sudo apt-get update -qq
sudo apt-get install -y libglpk-dev || true

# Install req for Rmpfr
sudo apt-get update -qq
sudo apt-get install -y libmpfr-dev || true

# Install req for Rpoppler
sudo apt-get update -qq
sudo apt-get install -y libpoppler-glib-dev || true

# Install req for Rsymphony
sudo apt-get update -qq
sudo apt-get install -y libbz2-dev coinor-libsymphony-dev coinor-libcgl-dev || true

# Install req for V8
sudo apt-get update -qq
sudo apt-get -y install libv8-dev || true

# Install req for animation

# Even though animation depends upon magick, the test framework doesn't run
# the installers for imported packages, so we need to install libmagick++-dev
# here as well.
if [ $OS_CODENAME == "xenial" ]; then
sudo add-apt-repository -y ppa:cran/imagemagick
fi
# check for supported platform (whitelisted ubuntu versions)
if [ $OS_CODENAME == "xenial" ]; then
sudo add-apt-repository ppa:jonathonf/ffmpeg-4
fi
sudo apt-get update -qq
if [ $OS_CODENAME == "focal" ]; then
sudo apt-get install -y libmagick++-dev ffmpeg graphicsmagick pdftk x264 x265  || true
else
sudo apt-get install -y libmagick++-dev ffmpeg graphicsmagick libav-tools pdftk x264 x265 || true
fi

# Install req for av
# need for add-apt-repository
sudo apt-get update -qq
# check for supported platform (whitelisted ubuntu versions)
if [ $OS_CODENAME == "xenial" ]; then
sudo add-apt-repository ppa:jonathonf/ffmpeg-4 || true
fi
sudo apt-get update -qq
sudo apt-get install -y libavfilter-dev libavformat-dev || true

# Install req for convertGraph
sudo apt-get update -qq
sudo apt-get install -y phantomjs || true

# Install req for docxtractr
sudo apt-get update -qq

sudo add-apt-repository ppa:libreoffice/ppa
sudo apt-get update -qq
sudo apt-get install -y libreoffice || true

# Install req for gdalUtils
if [ "${OS_CODENAME}" == "xenial" ]; then
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x089EBE08314DF160
sudo echo "deb http://ppa.launchpad.net/ubuntugis/ppa/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list.d/ubuntugis-ppa.list
fi
sudo apt-get update -qq
sudo apt-get install -y libgdal-dev libproj-dev gdal-bin || true

# Install req for gert
# install libgit2 on xenial only
if [ "${OS_CODENAME}" == "xenial" ]; then
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0xb3cf35c315b55a9f
sudo echo "deb http://ppa.launchpad.net/cran/libgit2/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list.d/cran-libgit2-ppa.list
fi
sudo apt-get update -qq
sudo apt-get install -y libgit2-dev || true

# Install req for gmp
sudo apt-get update -qq
if [ ${OS_CODENAME} == "xenial" ]; then
sudo apt-get install -y libgmp10-dev || true
else
sudo apt-get install -y libgmp-dev || true
fi

# Install req for gridGraphics
sudo apt-get update -qq
sudo apt-get install -y imagemagick || true

# Install req for gsl
OS_CODENAME=$(lsb_release -cs)
sudo apt-get update -qq
if [ ${OS_CODENAME} == "xenial" ]; then
sudo apt-get install -y libgsl0-dev || true
else
sudo apt-get install -y libgsl-dev || true
fi

# Install req for hunspell
sudo apt-get update -qq
sudo apt-get install -y libhunspell-dev || true

# Install req for igraph
sudo apt-get update -qq
sudo apt-get install -y libglpk-dev || true

# Install req for jqr
sudo apt-get update -qq
# these sysdeps are available by default in bionic
if [ "${OS_CODENAME}" == "xenial" ]; then
sudo add-apt-repository -y ppa:cran/jq
sudo apt-get update -qq
sudo apt-get install -y python-software-properties || true
fi
sudo apt-get install -y libjq-dev || true

# Install req for keyring
sudo apt-get update -qq
sudo apt-get install -y libsecret-1-dev libsodium-dev || true

# Install req for lwgeom
if [ $OS_CODENAME == "xenial" ]; then
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x089EBE08314DF160
sudo echo "deb http://ppa.launchpad.net/ubuntugis/ppa/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list.d/ubuntugis-ppa.list || true
fi
sudo apt-get update -qq
sudo apt-get install -y libudunits2-dev libgdal-dev libgeos-dev libproj-dev || true

# Install req for magick
sudo apt-get update -qq
# these sysdeps are available by default in bionic
if [ ${OS_CODENAME} == "xenial" ]; then
sudo apt-get install -y python-software-properties || true
# PPA has recent ImageMagick versions for for Ubuntu Trusty/Xenial
sudo add-apt-repository -y ppa:cran/imagemagick
sudo apt-get update -qq
fi
sudo apt-get install -y libmagick++-dev || true
if [ ${OS_CODENAME} == "focal" ]; then
# Enable imagemagick ghostscript features
# See https://www.kb.cert.org/vuls/id/332928/
# focal has a new enough version of ghostscript
sudo sed -i "\$i \ \ <policy domain=\"coder\" rights=\"read | write\" pattern=\"{PS,PS2,PS3,EPS,PDF,XPS}\" />" /etc/ImageMagick-6/policy.xml || true
fi

# Install req for ncdf4
sudo apt-get update -qq
sudo apt-get install -y libnetcdf-dev netcdf-bin || true

# Install req for pagedown
sudo apt-get update -qq
# install chrome to use pagedown::chrome_print()
curl -LO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get install -y ./google-chrome-stable_current_amd64.deb  || true
rm google-chrome-stable_current_amd64.deb

# Install req for pdftools
sudo apt-get update -qq
sudo apt-get install -y libpoppler-cpp-dev || true

# Install req for pensieve
sudo apt-get update -qq
sudo apt-get install -y pdf2svg librsvg2-bin || true

# Install req for rDEA
sudo apt-get update -qq
sudo apt-get install -y libglpk-dev || true

# Install req for rJava
sudo /usr/bin/R CMD javareconf || true

# Install req for ragg
sudo apt-get update -qq
sudo apt-get install -y libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libharfbuzz-dev libfribidi-dev || true

# Install req for rcbc
sudo apt-get update -qq
sudo apt-get install -y coinor-libcbc-dev coinor-libclp-dev coinor-libcgl-dev libbz2-dev || true

# Install req for rcdd
sudo apt-get update -qq
sudo apt-get install -y libgmp-dev libgmp3-dev || true

# Install req for redland
sudo apt-get update -qq
sudo apt-get install -y librdf0-dev || true

# Install req for rgdal
if [ "${OS_CODENAME}" == "xenial" ]; then
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x089EBE08314DF160
sudo echo "deb http://ppa.launchpad.net/ubuntugis/ppa/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list.d/ubuntugis-ppa.list || true
fi
sudo apt-get update -qq
sudo apt-get install -y libgdal-dev libproj-dev || true

# Install req for rgeos
sudo apt-get update -qq
sudo apt-get install -y libgeos-dev || true

# Install req for rgl
sudo apt-get update -qq
sudo apt-get install -y libgl1-mesa-dev libglu1-mesa-dev || true

# Install req for rsvg
sudo apt-get update -qq
sudo apt-get install -y librsvg2-dev || true

# Install req for seewave
sudo apt-get update -qq
sudo apt-get install -y libsndfile1 libsndfile1-dev || true

# Install req for sf
if [ "${OS_CODENAME}" == "xenial" ]; then
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x089EBE08314DF160
sudo echo "deb http://ppa.launchpad.net/ubuntugis/ppa/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list.d/ubuntugis-ppa.list || true
fi
sudo apt-get update -qq
sudo apt-get install -y libudunits2-dev libgdal-dev libgeos-dev libproj-dev || true

# Install req for sodium
sudo apt-get update -qq
sudo apt-get install -y libsodium-dev || true

# Install req for ssh
sudo apt-get update -qq
sudo apt-get install -y libssh-dev || true

# Install req for staplr
sudo apt-get update -qq
sudo apt-get install -y pdftk || true

# Install req for symengine
sudo apt-get update -qq
sudo apt-get install -y cmake libgmp-dev libmpfr-dev libmpc-dev || true

# Install req for tensorflow
sudo pip3 install --upgrade tensorflow keras scipy h5py pyyaml requests Pillow || true

# Install req for tesseract
sudo apt-get update -qq
sudo apt-get install -y libtesseract-dev libleptonica-dev tesseract-ocr-eng tesseract-ocr-fra || true

# Install req for textshaping
sudo apt-get update -qq
sudo apt-get install -y libharfbuzz-dev libfribidi-dev || true

# Install req for tiff
sudo apt-get update -qq
sudo apt-get install -y libtiff-dev || true

# Install req for tkrplot
sudo apt-get update -qq
sudo apt-get install -y tk tk-dev tcl tcl-dev || true

# Install req for tm
sudo apt-get update -qq
sudo apt-get install -y antiword poppler-utils || true

# Install req for topicmodels
sudo apt-get update -qq
if [ "${OS_CODENAME}" == "xenial" ]; then
sudo apt-get install -y libgsl0-dev libgfortran-5-dev libblas-dev || true
else
sudo apt-get install -y libgsl-dev || true 
fi

# Install req for units
sudo apt-get update -qq
sudo apt-get install -y libudunits2-dev || true

# Install req for xslt
sudo apt-get update -qq
sudo apt-get install -y libxslt1-dev || true


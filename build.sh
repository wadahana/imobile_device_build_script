#!/bin/bash

path=$(cd "$(dirname "$0")"; pwd)
build_path="${path}/build"
release_path="${path}/target"

mkdir -p "${build_path}"
mkdir -p "${release_path}"

function build_module()
{
    module_name=$1
    module_path="${build_path}/${module_name}"
    module_git_url=$2
    commit_name=$3
    patch_path=$4
    echo -e "\n\n\t\tchekcout ${module_name} ...\n\n"
    if [ ! -d "$module_path" ]; then
        git clone "$module_git_url" "$module_path"  > /dev/null
    fi
    pushd "${module_path}" > /dev/null
        git reset --hard
        git clean -df
        git checkout "${commit_name}"
        ./autogen.sh --prefix="${release_path}" > /dev/null
        echo -e "patch_path: ${patch_path}"
        if [ -f "${patch_path}" ]; then
            patch -p1 < "${patch_path}"
        fi
        make
        make install
    popd > /dev/null

}

function build_openssl()
{
    openssl_path="${build_path}/openssl"
    openssl_git_url="https://github.com/openssl/openssl.git"
    echo -e "chekcout OpenSSL 1.0.2j ..."
    if [ ! -d "$openssl_path" ]; then
        git clone "$openssl_git_url" "$openssl_path"  > /dev/null
    fi
    pushd "${openssl_path}" > /dev/null
    git checkout OpenSSL_1_0_2j
    git reset --hard > /dev/null
    ./Configure --prefix="${release_path}" darwin64-x86_64-cc  zlib-dynamic shared enable-cms  enable-ec_nistp_64_gcc_128
    make
    make install
}

brew install autoconf
brew install automake
brew install pkg-config
brew install libtool
brew install libxml2
brew install libtasn1
brew install libzip
brew install libusb

export PKG_CONFIG_PATH="${release_path}/lib/pkgconfig:$PKG_CONFIG_PATH"
export PATH="${release_path}/bin:$PATH"
export LD_LIBRARY_PATH="${release_path}/lib:$LD_LIBRARY_PATH"
export CPATH="${release_path}/include:$LD_LIBRARY_PATH"

build_openssl
build_module "libplist" "https://github.com/libimobiledevice/libplist.git"
build_module "libusbmuxd" "https://github.com/libimobiledevice/libusbmuxd.git"
build_module "libimobiledevice" "https://github.com/libimobiledevice/libimobiledevice.git"
build_module "usbmuxd" "http://git.sukimashita.com/usbmuxd.git" "35e5d48f29ae03b2b9686109e4ed9ab8b9677ce8" "${path}/usbmuxd.patch"
build_module "ideviceinstaller" "https://github.com/libimobiledevice/ideviceinstaller.git" "442f670a01f82c63d1316d60f1f47191b8bc6b5a" "${path}/ideviceinstaller.patch"

#!/bin/bash

path=$(cd "$(dirname "$0")"; pwd)
build_path="${path}/build"
release_path="${path}/target"

function build_module()
{
    module_name=$1
    module_path="${build_path}/${module_name}"
    module_git_url=$2
    echo -e "chekcout ${module_name} ..."
    if [ ! -d "$module_path" ]; then
        git clone "$module_git_url" "$module_path"  > /dev/null
    fi
    pushd "${module_path}" > /dev/null
        git checkout
        git reset --hard HEAD
        ./autogen.sh --prefix="${release_path}"
        make
        make install
    popd > /dev/null

}

function build_openssl()
{
    openssl_path="${build_path}/openssl"
    openssl_git_url="https://github.com/openssl/openssl.git"
    if [ ! -d "$openssl_path" ]; then
        git clone "$openssl_git_url" "$openssl_path"  > /dev/null
    fi
    pushd "${openssl_path}" > /dev/null
    ./Configure --prefix="${release_path}" darwin64-x86_64-cc  zlib-dynamic shared enable-cms  enable-ec_nistp_64_gcc_128
    make
    make install
}

brew install autoconf automake libtool
brew install lixml2 libtasn1 libzip libusb openssl

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:"${release_path}/lib/pkgconfig"
export PATH=/Users/wuxin/workspace/git/libmobiledevice/target/bin:$PATH
export LD_LIBRARY_PATH=/Users/wuxin/workspace/git/libmobiledevice/target/lib:$LD_LIBRARY_PATH
export CPATH=/Users/wuxin/workspace/git/libmobiledevice/target/include:$LD_LIBRARY_PATH

build_module "libplist" "https://github.com/libimobiledevice/libplist.git"
build_module "libusbmuxd" "https://github.com/libimobiledevice/libusbmuxd.git"
build_module "libimobiledevice" "https://github.com/libimobiledevice/libideviceactivation.git"
build_module "usbmuxd" "http://git.sukimashita.com/usbmuxd.git"
build_module "ideviceinstaller" "https://github.com/libimobiledevice/ideviceinstaller.git"
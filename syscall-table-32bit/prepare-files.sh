#!/bin/bash

KERNEL_VERSION="4.14"
LINK="https://www.kernel.org/pub/linux/kernel/v4.x/linux-${KERNEL_VERSION}.tar.xz"

TBL_32="/tmp/linux-${KERNEL_VERSION}/arch/x86/entry/syscalls/syscall_32.tbl"

if [ ! -d ${DIR}/linux-${KERNEL_VERSION} ];then
    wget $LINK -O /tmp/linux-${KERNEL_VERSION}.tar.xz
    tar xf /tmp/linux-${KERNEL_VERSION}.tar.xz -C /tmp/
fi

if [ ! -f ${TBL_32} ]; then
    echo "File syscall_32.tbl doesn't exist"
    exit -1
fi

echo "[+] Generating tags, this may take a while..."
ctags --fields=afmikKlnsStz --c-kinds=+pc -R /tmp/linux-${KERNEL_VERSION}
echo "[+] Tags generated"
echo "[+] Preparing the syscall table file..."
cp -v $TBL_32 .
sed -i '1,8d' syscall_32.tbl

echo "[+] Done :)"
rm -rf "/tmp/linux-${KERNEL_VERSION}"
rm -rf "/tmp/linux-${KERNEL_VERSION}.tar.xz"

echo "[I] Calling gen_syscalls..."
python2 ./gen_syscalls.py > www/syscalls-x86.js
rm -rf tags
rm -rf syscall_32.tbl
sed -i "s/\/tmp\/linux-${KERNEL_VERSION}\///g" www/syscalls-x86.js

echo "[+] Copying files to ../docs/32/${KERNEL_VERSION}..."
mkdir -p ../docs/32/
cp -r ./www ../docs/32/${KERNEL_VERSION}

echo "[I] Replacing the kernel version"
sed -n "s/https:\/\/elixir.bootlin.com\/linux\/v.*\/source/https:\/\/elixir.bootlin.com\/linux\/v${KERNEL_VERSION}\/source/p" ../docs/32/${KERNEL_VERSION}/index.html
sed -i "s/https:\/\/elixir.bootlin.com\/linux\/v.*\/source/https:\/\/elixir.bootlin.com\/linux\/v${KERNEL_VERSION}\/source/g" ../docs/32/${KERNEL_VERSION}/index.html

#!/bin/bash

KERNEL_VERSION="6.6"
LINK="https://mirrors.tuna.tsinghua.edu.cn/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz"

TBL_64="/tmp/linux-${KERNEL_VERSION}/arch/x86/entry/syscalls/syscall_64.tbl"

if [ ! -d ${DIR}/linux-${KERNEL_VERSION} ]; then
    curl -L $LINK > /tmp/linux-${KERNEL_VERSION}.tar.xz
    tar xf /tmp/linux-${KERNEL_VERSION}.tar.xz -C /tmp/
fi

if [ ! -f ${TBL_64} ]; then
    echo "File syscall_64.tbl doesn't exist"
    exit -1
fi

echo "[+] Generating tags, this may take a while..."
ctags --fields=afmikKlnsStz --c-kinds=+pc -R /tmp/linux-${KERNEL_VERSION}
echo "[+] Tags generated"
echo "[+] Preparing the syscall table file..."
cp -v $TBL_64 .
sed -i "s/__x64_//g" syscall_64.tbl
sed -i "s/__x32_compat_//g" syscall_64.tbl

echo "[+] Done :)"
rm -rf "/tmp/linux-${KERNEL_VERSION}"
rm -rf "/tmp/linux-${KERNEL_VERSION}.tar.xz"

echo "[I] Calling gen_syscalls.py..."
./gen_syscalls.py > www/syscalls-x86_64.js
rm -rf tags
rm -rf syscall_64.tbl
sed -i "s/\/tmp\/linux-${KERNEL_VERSION}\///g" www/syscalls-x86_64.js

echo "[+] Copying files to ../docs/64/${KERNEL_VERSION}..."
mkdir -p ../docs/64/${KERNEL_VERSION}
cp -r ./www/* ../docs/64/${KERNEL_VERSION}

echo "[I] Replacing the kernel version"
sed -n "s/https:\/\/elixir.bootlin.com\/linux\/v6.6\/source/https:\/\/elixir.bootlin.com\/linux\/v${KERNEL_VERSION}\/source/p" ../docs/64/${KERNEL_VERSION}/index.html
sed -i "s/https:\/\/elixir.bootlin.com\/linux\/v6.6\/source/https:\/\/elixir.bootlin.com\/linux\/v${KERNEL_VERSION}\/source/g" ../docs/64/${KERNEL_VERSION}/index.html

sed -n "s/Generated from Linux kernel 6.6 using/Generated from Linux kernel ${KERNEL_VERSION} using/p" ../docs/64/${KERNEL_VERSION}/index.html
sed -i "s/Generated from Linux kernel 6.6 using/Generated from Linux kernel ${KERNEL_VERSION} using/g" ../docs/64/${KERNEL_VERSION}/index.html

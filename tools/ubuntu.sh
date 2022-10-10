#!/usr/bin/env bash

# Author : James Nock
# Year   : 2022

set -euo pipefail

echo () {
    printf "\n%b\n" "[iac] $1"
}

echo "Updating apt packages... you may have to enter your password here"
sudo apt update

echo "Installing dependencies.."
sudo apt install -y git \
    perl \
    python3 \
    python3-pip \
    gperf \
    autoconf \
    bc \
    bison \
    gcc \
    clang \
    make

sudo apt install -y \
    flex \
    build-essential \
    ca-certificates \
    ccache \
    libgoogle-perftools-dev \
    numactl \
    perl-doc \
    libfl2 \
    libfl-dev \
    zlib1g \
    zlib1g-dev \
    qemu qemu-user \
    gtkwave \
    jq

# Install Verilator
echo "Installing Verilator"
cd /tmp
rm -rf verilator

git clone https://github.com/verilator/verilator verilator
cd verilator
git checkout v4.226
autoconf
./configure
make -j "$(nproc)"
sudo make install
cd ..
rm -rf verilator

verilator --version

echo "Installing riscv-gnu-toolchain... this may require your password..."
# shellcheck disable=SC1091
ubuntu_version=$( . /etc/os-release ; printf "%s" "$VERSION_ID" )
echo "Got Ubuntu version: ${ubuntu_version}"
tools_download_link="https://github.com/EIE2-IAC-Labs/Lab0-devtools/releases/download/v1.0.0-rc.1/riscv-gnu-toolchain-2022-09-21-Ubuntu-${ubuntu_version}.tar.gz"

cd /tmp
rm -rf riscv-gnu-toolchain.tar.gz
curl --output riscv-gnu-toolchain.tar.gz -L "${tools_download_link}"
sudo rm -rf /opt/riscv
sudo tar -xzf riscv-gnu-toolchain.tar.gz --directory /opt
export PATH="/opt/riscv/bin:$PATH"
if ! grep "/opt/riscv/bin" ~/.bashrc > /dev/null; then
    # shellcheck disable=SC2016
    printf '\n%s' 'export PATH="/opt/riscv/bin:$PATH"' >> ~/.bashrc
fi
rm -rf riscv-gnu-toolchain.tar.gz

#!/bin/bash

CYAN='\033[0;36m'

sudo apt update

while [ "$1" != "" ]; do
    if [ "$1" == "--c" ] || [ "$1" == "--all" ] ; then
        echo -e "${CYAN}>>> Installing C..."
        sudo apt install gcc
    elif [ "$1" == "--go" ] || [ "$1" == "--all" ] ; then
        echo -e "${CYAN}>>> Installing Go..."
        sudo apt install golang
        echo 'export GOPATH=$HOME/go' >> ~/.bashrc
        echo 'export PATH=${PATH}:${GOPATH}/bin' >> ~/.bashrc
        source ~/.bashrc
    elif [ "$1" == "--java" ] || [ "$1" == "--all" ] ; then
        echo -e "${CYAN}>>> Installing Java..."
        sudo apt install openjdk-11-jre openjdk-11-jdk
    elif [ "$1" == "--julia" ] || [ "$1" == "--all" ] ; then
        echo -e "${CYAN}>>> Installing wget tar..."
        sudo apt install wget tar
        echo -e "${CYAN}>>> Installing Julia..."
        wget https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.0-linux-x86_64.tar.gz
        tar -xzf julia-1.0.0-linux-x86_64.tar.gz
        sudo mv julia-1.0.0 /usr/local/
        sudo ln -s /usr/local/julia-1.0.0/bin/julia /usr/local/bin/julia
        sudo rm julia-1.0.0-linux-x86_64.tar.gz
    elif [ "$1" == "--kotlin" ] || [ "$1" == "--all" ] ; then
        echo -e "${CYAN}>>> Installing Java..."
        sudo apt install openjdk-11-jre openjdk-11-jdk
        echo -e "${CYAN}>>> Installing snap..."
        sudo apt install snapd
        echo 'export PATH=${PATH}:/snap/bin' >> ~/.bashrc
        source ~/.bashrc
        echo -e "${CYAN}>>> Installing Kotlin..."
        sudo snap install --classic kotlin
    elif [ "$1" == "--node" ] || [ "$1" == "--typescript" ] || [ "$1" == "--all" ] ; then
        echo -e "${CYAN}>>> Installing NodeJS and TypeScript..."
        sudo apt install nodejs npm
        sudo npm install -g typescript
    elif [ "$1" == "--python" ] || [ "$1" == "--all" ] ; then
        echo -e "${CYAN}>>> Installing Python3.7..."
        sudo apt install python3.7 python3-pip mypy
    elif [ "$1" == "--rust" ] || [ "$1" == "--all" ] ; then
        echo -e "${CYAN}>>> Installing Rust..."
        sudo apt install rustc cargo
    elif [ "$1" == "--swift" ] || [ "$1" == "--all" ] ; then
        echo -e "${CYAN}>>> Installing clang..."
        sudo apt-get install clang
        echo -e "${CYAN}>>> Installing Swift..."
        wget https://swift.org/builds/development/ubuntu1804/swift-DEVELOPMENT-SNAPSHOT-2018-09-04-a/swift-DEVELOPMENT-SNAPSHOT-2018-09-04-a-ubuntu18.04.tar.gz
        tar -xzf swift-DEVELOPMENT-SNAPSHOT-2018-09-04-a-ubuntu18.04.tar.gz
        sudo mv swift-DEVELOPMENT-SNAPSHOT-2018-09-04-a-ubuntu18.04 /usr/local/
        echo 'export PATH=${PATH}:/usr/local/swift-DEVELOPMENT-SNAPSHOT-2018-09-04-a-ubuntu18.04/usr/bin' >> ~/.bashrc
        source ~/.bashrc
        rm swift-DEVELOPMENT-SNAPSHOT-2018-09-04-a-ubuntu18.04.tar.gz
    fi
    if [ "$1" == "--c" ] || [ "$1" == "--c-deps" ] || [ "$1" == "--all" ] ; then
        echo -e "${CYAN}>>> Installing C dependencies for OpenMPI..."
        sudo apt install make cmake openmpi-bin openmpi-common openmpi-doc openssh-server openssh-client libopenmpi-dev libopenmpi2
    elif [ "$1" == "--go" ] || [ "$1" == "--go-deps" ] || [ "$1" == "--all" ] ; then
        echo -e "${CYAN}>>> No Go dependencies!"
    elif [ "$1" == "--java" ] || [ "$1" == "--java-deps" ] || [ "$1" == "--all" ] ; then
        echo -e "${CYAN}>>> No Java dependencies!"
    elif [ "$1" == "--julia" ] || [ "$1" == "--julia-deps" ] || [ "$1" == "--all" ] ; then
        echo -e "${CYAN}>>> Installing Julia dependencies..."
        julia -e 'using Pkg; Pkg.update(); Pkg.add("Printf"); Pkg.add("Distributed");'
    elif [ "$1" == "--node" ] || [ "$1" == "--node-deps" ] || [ "$1" == "--typescript" ] || [ "$1" == "--typescript-deps" ] || [ "$1" == "--all" ] ; then
        echo -e "${CYAN}>>> Installing NodeJS/TypeScript dependencies..."
        sudo npm install -g hamsters.js paralleljs
    elif [ "$1" == "--python" ] || [ "$1" == "--python-deps" ] || [ "$1" == "--all" ] ; then
        echo -e "${CYAN}>>> Installing Python dependencies..."
        python3.7 -m pip install virtualenv
    elif [ "$1" == "--rust" ] || [ "$1" == "--rust-deps" ] || [ "$1" == "--all" ] ; then
        echo -e "${CYAN}>>> No Rust dependencies!"
    fi
    shift
done


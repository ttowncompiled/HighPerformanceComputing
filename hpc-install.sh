#!/bin/bash

ENDC='\033[0m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'

if ! [ "$1" == "--no-update" ] ; then
    sudo apt update
else
    shift
fi

while [ "$1" != "" ] ; do
    if [ "$1" == "c" ] || [ "$1" == "all" ] ; then
        echo -e "${CYAN}>>> Installing C...${ENDC}"
        sudo apt install gcc
    elif [ "$1" == "go" ] || [ "$1" == "all" ] ; then
        echo -e "${CYAN}>>> Installing Go...${ENDC}"
        sudo apt install golang
        if [ -z "$GOPATH" ] ; then
            echo -e "${CYAN}>>> Adding GOPATH to the environment...${ENDC}"
            echo 'export GOPATH=$HOME/go' >> ~/.bashrc
            echo -e "${CYAN}>>> Adding go/bin to PATH...${ENDC}"
            echo 'export PATH=${PATH}:${GOPATH}/bin' >> ~/.bashrc
            source ~/.bashrc
        fi
    elif [ "$1" == "java" ] || [ "$1" == "all" ] ; then
        echo -e "${CYAN}>>> Installing Java...${ENDC}"
        sudo apt install openjdk-11-jre openjdk-11-jdk
    elif [ "$1" == "julia" ] || [ "$1" == "all" ] ; then
        if ! [ -x "$(command -v julia)" ] ; then
            echo -e "${CYAN}>>> Installing wget tar...${ENDC}"
            sudo apt install wget tar
            echo -e "${CYAN}>>> Installing Julia...${ENDC}"
            wget https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.0-linux-x86_64.tar.gz
            tar -xzf julia-1.0.0-linux-x86_64.tar.gz
            sudo mv julia-1.0.0 /usr/local/
            sudo ln -s /usr/local/julia-1.0.0/bin/julia /usr/local/bin/julia
            sudo rm julia-1.0.0-linux-x86_64.tar.gz
        else
            echo -e "${RED}>>> Julia already installed!${ENDC}"
        fi
    elif [ "$1" == "kotlin" ] || [ "$1" == "all" ] ; then
        if ! [ -x "$(command -v java)" ] ; then
            echo -e "${RED}>>> Java not installed!${ENDC}"
            echo -e "${CYAN}>>> Installing Java...${ENDC}"
            sudo apt install openjdk-11-jre openjdk-11-jdk
        fi
        if ! [ -x "$(command -v snap)" ] ; then
            echo -e "${RED}>>> snap not installed!${ENDC}"
            echo -e "${CYAN}>>> Installing snap...${ENDC}"
            sudo apt install snapd
            echo -e "${CYAN}>>> Adding snap/bin to PATH...${ENDC}"
            echo 'export PATH=${PATH}:/snap/bin' >> ~/.bashrc
            source ~/.bashrc
        fi
        echo -e "${CYAN}>>> Installing Kotlin...${ENDC}"
        sudo snap install classic kotlin
    elif [ "$1" == "node" ] || [ "$1" == "typescript" ] || [ "$1" == "all" ] ; then
        echo -e "${CYAN}>>> Installing NodeJS and TypeScript...${ENDC}"
        sudo apt install nodejs npm
        sudo npm install -g typescript
    elif [ "$1" == "python" ] || [ "$1" == "all" ] ; then
        echo -e "${CYAN}>>> Installing Python3.7...${ENDC}"
        sudo apt install python3.7 python3-pip mypy
    elif [ "$1" == "rust" ] || [ "$1" == "all" ] ; then
        echo -e "${CYAN}>>> Installing Rust...${ENDC}"
        sudo apt install rustc cargo
    elif [ "$1" == "swift" ] || [ "$1" == "all" ] ; then
        if ! [ -x "$(command -v clang)" ] ; then
            echo -e "${RED}>>> clang not installed!${ENDC}"
            echo -e "${CYAN}>>> Installing clang...${ENDC}"
            sudo apt-get install clang
        fi
        if ! [ -x "$(command -v swift)" ] ; then
            echo -e "${CYAN}>>> Installing Swift...${ENDC}"
            wget https://swift.org/builds/development/ubuntu1804/swift-DEVELOPMENT-SNAPSHOT-2018-09-04-a/swift-DEVELOPMENT-SNAPSHOT-2018-09-04-a-ubuntu18.04.tar.gz
            tar -xzf swift-DEVELOPMENT-SNAPSHOT-2018-09-04-a-ubuntu18.04.tar.gz
            sudo mv swift-DEVELOPMENT-SNAPSHOT-2018-09-04-a-ubuntu18.04 /usr/local/
            echo 'export PATH=${PATH}:/usr/local/swift-DEVELOPMENT-SNAPSHOT-2018-09-04-a-ubuntu18.04/usr/bin' >> ~/.bashrc
            source ~/.bashrc
            rm swift-DEVELOPMENT-SNAPSHOT-2018-09-04-a-ubuntu18.04.tar.gz
        else
            echo -e "${RED}>>> Swift already installed!${ENDC}"
        fi
    fi
    if [ "$1" == "c" ] || [ "$1" == "c-deps" ] || [ "$1" == "all" ] ; then
        echo -e "${CYAN}>>> Installing C dependencies for OpenMPI...${ENDC}"
        sudo apt install make cmake openmpi-bin openmpi-common openmpi-doc openssh-server openssh-client libopenmpi-dev libopenmpi2
    elif [ "$1" == "go" ] || [ "$1" == "go-deps" ] || [ "$1" == "all" ] ; then
        echo -e "${YELLOW}>>> No Go dependencies!${ENDC}"
    elif [ "$1" == "java" ] || [ "$1" == "java-deps" ] || [ "$1" == "all" ] ; then
        echo -e "${YELLOW}>>> No Java dependencies!${ENDC}"
    elif [ "$1" == "julia" ] || [ "$1" == "julia-deps" ] || [ "$1" == "all" ] ; then
        echo -e "${CYAN}>>> Installing Julia dependencies...${ENDC}"
        julia -e 'using Pkg; Pkg.update(); Pkg.add("Printf"); Pkg.add("Distributed");'
    elif [ "$1" == "kotlin" ] || [ "$1" == "kotlin-deps" ] || [ "$1" == "all" ] ; then
        echo -e "${YELLOW}>>> No Kotlin dependencies!${ENDC}"
    elif [ "$1" == "node" ] || [ "$1" == "node-deps" ] || [ "$1" == "typescript" ] || [ "$1" == "typescript-deps" ] || [ "$1" == "all" ] ; then
        echo -e "${CYAN}>>> Installing NodeJS/TypeScript dependencies...${ENDC}"
        sudo npm install -g hamsters.js paralleljs
    elif [ "$1" == "python" ] || [ "$1" == "python-deps" ] || [ "$1" == "all" ] ; then
        echo -e "${CYAN}>>> Installing Python dependencies...${ENDC}"
        python3.7 -m pip install virtualenv
    elif [ "$1" == "rust" ] || [ "$1" == "rust-deps" ] || [ "$1" == "all" ] ; then
        echo -e "${YELLOW}>>> No Rust dependencies!${ENDC}"
    elif [ "$1" == "swift" ] || [ "$1" == "swift-deps" ] || [ "$1" == "all" ] ; then
        echo -e "${YELLOW}>>> No Swift dependencies!${ENDC}"
    fi
    shift
done

echo -e "${GREEN}>>> DONE.${ENDC}"

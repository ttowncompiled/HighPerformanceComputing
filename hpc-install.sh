#!/bin/bash

sudo apt update

while [ "$1" != "" ]; do
    if [ "$1" == "--c" ] ; then
        echo "Installing C..."
        sudo apt install gcc
    elif [ "$1" == "--julia" ] ; then
        echo "Installing Julia..."
        sudo apt install wget tar
        wget https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.0-linux-x86_64.tar.gz
        tar -xzf julia-1.0.0-linux-x86_64.tar.gz
        sudo mv julia-1.0.0 /usr/local/
        sudo ln -s /usr/local/julia-1.0.0/bin/julia /usr/local/bin/julia
        sudo rm julia-1.0.0-linux-x86_64.tar.gz
    fi
    if [ "$1" == "--c" ] || [ "$1" == "--c-deps" ] ; then
        echo "Installing C dependencies for OpenMPI..."
        sudo apt install make cmake openmpi-bin openmpi-common openmpi-doc openssh-server openssh-client libopenmpi-dev libopenmpi2
    elif [ "$1" == "--julia" ] || [ "$1" == "--julia-deps" ] ; then
        echo "Installing Julia dependencies..."
        julia -e 'using Pkg; Pkg.update(); Pkg.add("Printf"); Pkg.add("Distributed");'
    fi
    shift
done


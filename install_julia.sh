#!/bin/bash

# For Ubuntu 18.04 or later
wget https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.0-linux-x86_64.tar.gz
tar -xzf julia-1.0.0-linux-x86_64.tar.gz
sudo mv julia-1.0.0 /usr/local/
sudo ln -s /usr/local/julia-1.0.0/bin/julia /usr/local/bin/julia
sudo rm julia-1.0.0-linux-x86_64.tar.gz


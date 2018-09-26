#!/bin/bash

# For Ubuntu 18.04 or later
julia -e 'using Pkg; Pkg.update(); Pkg.add("Printf"); Pkg.add("Distributed");'


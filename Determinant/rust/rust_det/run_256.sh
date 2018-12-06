#!/usr/bin/env bash

rm log/job.256.out
cargo run 256 256 >> log/job.256.out

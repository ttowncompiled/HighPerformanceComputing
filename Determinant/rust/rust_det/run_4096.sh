#!/usr/bin/env bash

rm log/job.4096.out
cargo run 4096 256 >> log/job.4096.out

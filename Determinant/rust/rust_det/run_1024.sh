#!/usr/bin/env bash

rm log/job.1024.out
cargo run 1024 256 >> log/job.1024.out

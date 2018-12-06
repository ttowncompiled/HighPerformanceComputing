#!/usr/bin/env bash

rm log/job.2048.out
cargo run 2048 256 >> log/job.2048.out

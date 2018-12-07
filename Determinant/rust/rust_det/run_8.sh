#!/usr/bin/env bash

rm log/job.8.out
cargo run 8 256 >> log/job.8.out

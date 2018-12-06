#!/usr/bin/env bash

rm log/job.128.out
cargo run 128 256 >> log/job.128.out

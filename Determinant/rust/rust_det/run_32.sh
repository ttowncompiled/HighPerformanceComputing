#!/usr/bin/env bash

rm log/job.32.out
cargo run 32 256 >> log/job.32.out

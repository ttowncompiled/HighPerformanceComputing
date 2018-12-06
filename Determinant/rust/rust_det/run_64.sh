#!/usr/bin/env bash

rm log/job.64.out
cargo run 64 256 >> log/job.64.out

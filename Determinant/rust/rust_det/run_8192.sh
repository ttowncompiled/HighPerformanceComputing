#!/usr/bin/env bash

rm log/job.8192.out
cargo run 8192 256 >> log/job.8192.out

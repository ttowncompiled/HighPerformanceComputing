#!/usr/bin/env bash

rm log/job.512.out
cargo run 512 256 >> log/job.512.out

#!/bin/bash

RFSIMULATOR=server ./nr-softmodem -O ../../../gnb.conf --sa -E --rfsim --nokrnmod 1 --log_config.global_log_options level,nocolor,time
# Cluster benchmarking

## Prerequisites

* Docker installed with docker daemon at `/var/run/docker.sock`
* AWS credentials in a file     (Default : `~/.aws/credentials`)

## Running the benchmark

To run the benchmark, use the convenient command

    $ ./run_benchmark.bash

If you want to run the benchmark using the automatic setup and teardown, use the command with the following parameter

    $ ./run_benchmark.bash -d


If you want to run the benchmark using automatic build, use the command with the following parameter

    $ ./run_benchmark.bash -b


To debug, it is recommended to run

    $ ./run_benchmark.bash | tee >(sed $'s/\033[[][^A-Za-z]*m//g' > benchmark.log)
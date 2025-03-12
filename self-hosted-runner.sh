#!/bin/bash
#
# Run self-hosted actions runner Linux x64
#
# Create the runner and start the configuration experience
# ./config.sh --url https://github.com/dtnorth/lockwood --token ADFANXDUHX5WI3LMWXBYWQTH2FRHK
#
# Use this YAML in your workflow file for each job
#   
#   runs-on: self-hosted
#

  ./actions-runner/run.sh &

#!/usr/bin/env bash

# Build the env, install w/ setuptools
rm -rf env
python3 -m venv env
source env/bin/activate
pip install .

# Reminder to source the env outside this script
echo "RUN:"
echo "source env/bin/activate"

#!/bin/bash

envs=$(conda env list | grep "/project/" | awk '{print $1}' | grep -v "Python_env")

for env in $envs; do
    echo "Exporting $env..."
    conda env export -n $env --no-builds | grep -v "^prefix: " > "${env}.yml"
done
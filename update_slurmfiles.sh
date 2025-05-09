#!/usr/bin/env bash

set -e

restart=false

for var in "$@"
do
    if [ "$var" = "slurmdbd.conf" ] || [ "$var" = "slurm.conf" ] || [ "$var" = "cgroup.conf" ] || [ "$var" = "job_submit.lua" ]
    then
        docker cp ./slurm_files/$var mysql:/etc/slurm/$var
        restart=true
    fi
done

if $restart; then docker compose restart; fi

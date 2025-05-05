#!/usr/bin/env bash

set -e

restart=false

for var in "$@"
do
    if [ "$var" = "slurmdbd.conf" ] || [ "$var" = "slurm.conf" ] || [ "$var" = "cgroup.conf" ] || [ "$var" = "job_submit.lua" ]
    then
        export SLURM_TMP=$(cat ./slurm_files/$var)
        docker exec slurmctld bash -c "echo \"$SLURM_TMP\" >/etc/slurm/\"$var\""
        restart=true
    fi
done
if $restart; then docker-compose restart; fi

#!/bin/bash
#
# list files in the server by variable and frequency

variable=${1:-tas}
frequency=${2:-1hr}

pattern="${variable}_*_${frequency}_*"
datadir="/work/bg1369/FPS-URB-RCC"
outfile="$(pwd)/list_server_files__${variable}_${frequency}.txt"

cd ${datadir}
find . -type f -name ${pattern} | grep -v delete | sort > ${outfile}
echo "${outfile} updated."

#!/bin/bash

domain=${1:-PARIS-3}

BASE_DIR="/work/bg1369/FPS-URB-RCC/${domain}"
OUTPUT_DIR="/home/b/b382580/FPS-URB-RCC/b382580_jfernandez"

for file in $(find ${BASE_DIR} -type f -name '*.nc' | sort); do
    # Extract components from the filename
    filename=$(basename "$file")
    fullpath="${file}"

    # Fixes
    filename=${filename//ICTP-RegCM5/ICTP_RegCM5}
    filename=${filename//CLMcom-CMCC-ICONCLM2-6-6/CLMcom-CMCC_ICONCLM2-6-6}
    filename=${filename//r1.nc/r1_fx.nc}
    filename=${filename//r3.nc/r3_fx.nc}
    filename=${filename//_fxrkDMAU2225158.nc/_fx.nc}
    filename=${filename//_fxXfzz8U955319.nc/_fx.nc}
    filename=${filename//_fixed*.nc/_fx.nc}
    filename=${filename//_fix*.nc/_fx.nc}
    filename=${filename//_PAR-3_/_PARIS-3_}
    filename=${filename//_v1_/_v1-fpsurbrcc-s0r1_}
    filename=${filename//_fpsurbrcc-s0r1_/_v1-fpsurbrcc-s0r1_}
    filename=${filename//_v1-r1_/_v1-fpsurbrcc-s0r1_}
    filename=${filename//_v1-r6_/_v1-fpsurbrcc-s0r6_}

    filename=${filename//.nc/}
    IFS="_" read -r variable_id domain_id driving_source_id driving_experiment_id driving_variant_label institution_id source_id version_realization frequency dates <<< "$filename"

    # Try to get the version from the path
    version=$(basename $(dirname "${fullpath}"))
    if test "${version:0:4}" = "v202"; then
        formatted_version=${version}
    else
        # Otherwise, get the file modification time and format it as vYYYYMMDD
        mod_time=$(stat -c %y "${fullpath}" | cut -d' ' -f1 | tr -d '-')
        formatted_version="v${mod_time}"
    fi
    
    target_dir="$OUTPUT_DIR/CORDEX/CMIP6/FPS-URB-RCC/${domain_id}/${institution_id}/${driving_source_id}/${driving_experiment_id}/${driving_variant_label}/${source_id}/${version_realization}/${frequency}/${variable_id}/${formatted_version}"

    mkdir -p "$target_dir"
    ln -s "$fullpath" "$target_dir/${filename}.nc"
done

echo "Files have been organized into the CORDEX DRS hierarchy."


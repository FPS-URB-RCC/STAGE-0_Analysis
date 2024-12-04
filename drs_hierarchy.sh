#!/bin/bash

BASE_DIR="/work/bg1369/FPS-URB-RCC/PARIS-3"
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

    filename=${filename//.nc/}
    IFS="_" read -r variable_id domain_id driving_source_id driving_experiment_id driving_variant_label institution_id source_id version_realization frequency dates <<< "$filename"

    # Get the file modification time and format it as vYYYYMMDD
    mod_time=$(stat -c %y "${fullpath}" | cut -d' ' -f1 | tr -d '-')
    formatted_version="v${mod_time}"

    target_dir="$OUTPUT_DIR/CORDEX/CMIP6/FPS-URB-RCC/${domain_id}/${institution_id}/${driving_source_id}/${driving_experiment_id}/${driving_variant_label}/${source_id}/${version_realization}/${frequency}/${variable_id}/${formatted_version}"

    mkdir -p "$target_dir"
    ln -s "$fullpath" "$target_dir/${filename}.nc"
done

echo "Files have been organized into the CORDEX DRS hierarchy."


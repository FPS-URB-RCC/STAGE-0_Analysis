#!/usr/bin/env python3

import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
import seaborn as sns

import pandas as pd

dreq_url = "https://raw.githubusercontent.com/impetus4change/T32-CPRCM/refs/heads/main/data-request-fpsurbrcc.csv"

version = True # Does the file path have version folder?
only_requested_variables = True

def list_all_files(base_path, has_version = True):
    """
    List all files in the directory hierarchy and organize them into a pandas DataFrame
    based on path components.

    Args:
        base_path (str): The root directory to start searching.

    Returns:
        pd.DataFrame: A DataFrame where each column corresponds to a level of the hierarchy.
    """
    all_files = []

    for dirpath, _, filenames in os.walk(base_path):#, followlinks = True):
        for file in filenames:
            full_path = os.path.join(dirpath, file)
            if 'delete' in full_path:
                continue
            if not '.nc' in full_path:
                continue
            components = full_path.split(os.sep)
            all_files.append(components[7:])

    facets = ['domain_id', 'institution_id', 'driving_source_id', 'driving_experiment_id', 'driving_variant_label', 'source_id', 'version_realization', 'frequency', 'variable_id', 'version', 'filename']

    facets_noversion = ['domain_id', 'institution_id', 'driving_source_id', 'driving_experiment_id', 'driving_variant_label', 'source_id', 'version_realization', 'frequency', 'variable_id', 'filename']
    # Create a DataFrame
    df = pd.DataFrame(all_files, columns=facets if has_version else facets_noversion)
    return df

base_path = "/work/bg1369/FPS-URB-RCC/PARIS-3"
base_path = "/work/bg1369/b382580_jfernandez/CORDEX/CMIP6/FPS-URB-RCC/PARIS-3"
df = list_all_files(base_path, has_version = version)

if only_requested_variables:
    dreq = pd.read_csv(dreq_url, usecols=['out_name', 'frequency']).rename(
        columns = {'out_name': 'variable_id'}
    )
    df = df.merge(dreq, on=['variable_id', 'frequency'], how='right')

df.to_csv('docs/CORDEX_FPSURBRCC_DKRZ_all_variables.csv', index = False)

#
#  Plot variable availability as heatmap
#
data = pd.read_csv('docs/CORDEX_FPSURBRCC_DKRZ_all_variables.csv', usecols=['variable_id', 'frequency', 'source_id', 'version_realization', 'institution_id'])
data['source_institution'] = data['source_id'] + '_' + data['version_realization'].str.replace('fpsurbrcc-s0', '') + ' (' + data['institution_id'] + ')'
data.drop(columns = ['source_id', 'institution_id', 'version_realization'], inplace = True)
# Drop monthly data (for the sake of brevity)
data.query('frequency != "mon"', inplace = True)
# Avoid showing different subdaily frequencies
#data['frequency'] = data['frequency'].replace('.hr', 'xhr', regex = True)
data.drop_duplicates(inplace = True)
# matrix with models as rows and variables as columns
matrix = data.pivot_table(index='source_institution', columns=['frequency', 'variable_id'], aggfunc='size', fill_value=0)
matrix = matrix.replace(0, np.nan)
# Plot as heatmap (make sure to show all ticks and labels)
plt.figure(figsize=(20,15))
ax = sns.heatmap(matrix, cmap='YlGnBu_r', annot=False, cbar=False, linewidths=1, linecolor='lightgray')
ax.set_xticks(0.5+np.arange(len(matrix.columns)))
xticklabels = [f'{v} ({f})' for f,v in matrix.columns]
xticklabels = (pd.Series(xticklabels)
  .replace(r'(.*) \(fx\)', r'\1 (fx)   ', regex=True)
  .replace(r'(.*) \(xhr\)', r'\1 (xhr)  ', regex=True)
).to_list()
ax.set_xticklabels(xticklabels)
ax.set_xlabel("variable (freq.)")
ax.set_yticks(0.5+np.arange(len(matrix.index)))
ax.set_yticklabels(matrix.index, rotation=0, horizontalalignment='left')
ax.yaxis.set_tick_params(pad=200)
ax.set_ylabel("source _ realization (institution)")
ax.set_aspect('equal')
plt.savefig(f'docs/CORDEX_FPSURBRCC_DKRZ_varlist{"_noversion" if not version else ""}.png', bbox_inches='tight')
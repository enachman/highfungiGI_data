#!/usr/bin/env python

import os
import pandas as pd

# Input directory. the directory location where all of the Quast samples are located
work_dir = "/mount/britton/Erika/2024-07-29-Funannotate_life-gift_batch_2/workflow-output/quast"
output_file = "/mount/britton/Erika/2024-07-29-Funannotate_life-gift_batch_2/code-output/quast_mapping_file.tsv"

# Create an empty DataFrame to store all final_df
giant_df = pd.DataFrame()

# Iterate through each subdirectory in the current directory
for sub_directory in os.listdir(work_dir):
    # Check if the item is a directory
    if os.path.isdir(os.path.join(work_dir, sub_directory)):
        # Set Sample_ID to the name of the subdirectory
        Sample_ID = sub_directory
        
        # Check if the metawrap_50_1_bins.stats file exists in the subdirectory
        file_path = os.path.join(work_dir, sub_directory, 'transposed_report.tsv')
        if os.path.exists(file_path):
            # Read the data and perform the operations as before
            df = pd.read_csv(file_path, sep="\t", index_col=0)
            temp_df = pd.DataFrame(columns=['key', 'Sample_ID', 'bin'])
            temp_df['key'] = [f"{Sample_ID}_{index}" for index in df.index]
            temp_df['Sample_ID'] = Sample_ID
            temp_df['bin'] = df.index
            final_df = pd.merge(left=temp_df, right=df, left_on="bin", right_on=df.index, how="left")

            
            # Append final_df to giant_df
            giant_df = pd.concat([giant_df, final_df])

columns_to_keep = ['key', '# contigs', 'Total length','GC (%)', 'N50', 'N90', 'auN', 'L50', 'L90']
giant_df = giant_df[columns_to_keep]
giant_df.to_csv(output_file,sep="\t",index=False)


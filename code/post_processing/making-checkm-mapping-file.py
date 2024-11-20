#!/usr/bin/env python

import os
import pandas as pd

# Input directory. the directory location where all of the Quast samples are located
work_dir = "/mount/britton/Erika/2024-07-29-Funannotate_life-gift_batch_2/workflow-output/checkm"
output_file = "/mount/britton/Erika/2024-07-29-Funannotate_life-gift_batch_2/code-output/checkm_mapping_file.tsv"


# Create an empty DataFrame to store all final_df
giant_df = pd.DataFrame()

# Iterate through each subdirectory in the current directory
for sub_directory in os.listdir(work_dir):
    # Check if the item is a directory
    if os.path.isdir(os.path.join(work_dir, sub_directory)):
        # Set Sample_ID to the name of the subdirectory
        Sample_ID = sub_directory
        
        file_path = os.path.join(work_dir, sub_directory, 'storage/bin_stats_ext.tsv')
        if os.path.exists(file_path):
        
            df = pd.read_csv(file_path, sep="\t", index_col=0, header=None)
            data = {}

            # Iterate over each row in the DataFrame
            for i in range(len(df)):
                # Get the dictionary key (the index of the DataFrame)
                dict_key = df.index[i]
                
                # Get the dictionary (the value in the second column of the DataFrame)
                dict_quals = eval(df.iloc[i][1])
                
                # Add the dictionary to the data dictionary, using the dict_key as the key
                data[dict_key] = dict_quals

            new_df = pd.DataFrame.from_dict(data, orient='index')
            columns_to_keep = ['Genome size', 'Completeness', 'N50 (contigs)', 'Contamination', 'N50 (scaffolds)']
            new_df = new_df[columns_to_keep]
            new_df['sampleID'] = Sample_ID
            new_df.reset_index(inplace=True)
            new_df['key'] = new_df['sampleID'].astype(str) + "_" + new_df['index'].astype(str)
            new_df['key'] = new_df['key'].str.rsplit('.', n=1).str[0]
            new_df = new_df.drop(columns=["index", "sampleID"])
            new_df.set_index('key',inplace = True)

            # Reorder the columns
            new_order = ['Completeness', 'Contamination', 'Genome size', 'N50 (contigs)', 'N50 (scaffolds)']
            new_df = new_df[new_order]

           
            # Append final_df to giant_df
            giant_df = pd.concat([giant_df, new_df])


giant_df.to_csv(output_file,sep="\t")


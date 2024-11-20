#!/usr/bin/env python

import os
import pandas as pd

work_dir = "/mount/britton/Erika/2024-07-29-Funannotate_life-gift_batch_2/code-output/kaiju"
output_file = "/mount/britton/Erika/2024-07-29-Funannotate_life-gift_batch_2/code-output/kaiju_mapping_file.tsv"

# Initialize an empty DataFrame
giant_df = pd.DataFrame()

# Iterate through each subdirectory in the main directory
for sub_directory in os.listdir(work_dir):
    sub_directory_path = os.path.join(work_dir, sub_directory)
    
    # Check if the item is a directory
    if os.path.isdir(sub_directory_path):
        # Set Sample_ID to the name of the subdirectory
        Sample_ID = sub_directory
        
        # Iterate through each subdirectory inside the current subdirectory
        for bin_directory in os.listdir(sub_directory_path):
            bin_directory_path = os.path.join(sub_directory_path, bin_directory)
            
            # Check if the item is a directory
            if os.path.isdir(bin_directory_path):
                # Set bin_ID to the name of the subdirectory
                bin_ID = bin_directory
                
                # Construct the path to the file of interest
                file_path = os.path.join(bin_directory_path, 'kaiju.table')
                
                # Check if the file exists
                if os.path.exists(file_path):
                    # Read the data and perform operations
                    df = pd.read_csv(file_path, sep="\t", index_col=-1)
                    df.drop(columns=['file','taxon_id'],inplace=True)
                    df.sort_values(by='percent',ascending=False,inplace=True)
                    top_taxon_row = df.iloc[0]
                    remaining = df.iloc[1:].apply(lambda row: f"{row.name}, {row.percent}, {row.reads}", axis=1).tolist()
                    
                    # Create the new dataframe
                    key = f"{Sample_ID}_{bin_ID}"
                    new_df = pd.DataFrame({
                        'top_taxon': [top_taxon_row.name],
                        'percent': [top_taxon_row.percent],
                        'reads': [top_taxon_row.reads],
                        'remaining': [remaining]
                    }, index=[key])
                    # Set the index name
                    new_df.index.name = 'key'
            
                    # Append final_df to giant_df
                    giant_df = pd.concat([giant_df, new_df])
giant_df.to_csv(output_file,sep="\t")


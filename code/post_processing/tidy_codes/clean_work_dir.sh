#!/bin/bash

main_dir="/mount/britton/Erika/2024-07-29-Funannotate_life-gift_batch_2"

work_dir="${main_dir}/workflow-output/work"
output_file="${main_dir}/code-output/clean_work_dir-log.txt"

# Initialize temp files to concatenate at the end
temp_log_file="temp_log_file.txt"

# Calculate initial disk space usage and save to a variable
initial_disk_usage=$(du -h --max-depth=0 "$work_dir" | awk '{print $1}')

# Find and delete files ending with *fastq.gz and append to temp file
find "$work_dir" -type f -name '*fastq.gz' -print -exec rm {} \; > "$temp_log_file"

# Calculate final disk space usage and save to a variable
final_disk_usage=$(du -h --max-depth=0 "$work_dir" | awk '{print $1}')

# Print the result
echo "Initial Disk Usage: $initial_disk_usage " >> "$output_file"
echo "Final Disk Usage: $final_disk_usage " >> "$output_file"
echo -e "\n" >> "$output_file"
echo "Files deleted:" >> "$output_file"

# Concatenate temp files so disk space can be at the top, then files deleted below.
cat "$temp_log_file" >> "$output_file"

# Step 6: Remove the temp files
rm "$temp_log_file"

There are a lot of small scripts here that are all fairly simple.

inside of the kaiju directory are the scripts to run kaiju.  Inside of tidy_codes are some simple scripts to clean up the nextflow outputs.

then there are three mapping file scripts, all three of these are to create files that can be merged into one final useful output.
making-kaiju* is for the kaiju output. While the other two (making-checkm* and making-quast*) are to be run on outputs from the main workflow.  

after running 

1. main_workflow
2. kaiju
3. tidy_codes

then you can run all of the making mapping file scripts in any order.   and finally the jupyter notebook of `merging_kaiju_to_quast_and_checkm.ipynb`


After all of those are done. Then it's time to step into funannotate and use the README there.

I hope this helps =)

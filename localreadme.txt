For picking OTUs and transferring files from MSI to Local Machine:
    0. Some prep work
    # Download all raw files from dropbox directly onto MSI
        curl -L -o foldername.zip [public-link-to-folder]?dl=1
    # unzip all files into folders with same name as zip
        find -name '*.zip' -exec sh -c 'unzip -d "${1%.*}" "$1"' _ {} \;

    1. Log into MSI:
    #isub -n nodes=1:ppn=16 -m 48GB -w 24:00:00

        # MSI version of embalmer only runs on wallib nodes, which requires the following
        isub -n nodes=1:ppn=32 -m 30GB -w 12:00:00
        module load python3
    
    # Make sure that /home/knightsd/algh0022/sop is in your PATH - this is where embalmer is
    # Databases are in /scratch/gabe/databases. PROK_170704 is the new replacement for refseqdb

    2. Run script to run embalmer on all datasets with both the new refseq db and green genes (interactively)
        bash ./embalmer.all.datasets.sh PROK_170704
        bash ./embalmer.all.datasets.sh gg97
   
       2.0.1 Otherwise, can also through all of these into a PBS
            qsub -q ram1t qsub.embalmer.all.datasets.pbs 
   
       2.1. yatsunenko dataset is >250GB, therefore need to submit job for it -- log into mesabi first. Note that all runs on mesabi require referencing database files in scratch.global instead of scratch!
            qsub -q ram1t yatsunenko.embalm.pbs
        
        2.2 HMP dataset is also huge, so do the same thing
            qsub -q ram1t hmp.embalm.pbs        
        
    3. To transfer all txt files from MSI to local computer except for .b6 files and raw folders (too large)

        cd ~/Dropbox/UMN/KnightsLab/MLRepo/datasets
        # for each dataset
        rsync -rav -e "ssh -l vanga015" --include='*.txt' --exclude "*.b6"  --exclude "raw" -r login.msi.umn.edu:~/mlrepo/cho .

For generating website MD files:

    ### SWITCH TO mlrepo-source branch

    # parses dataset specific information in dataset_metadata.tsv, and generates individual dataset pages AND index page with list of datasets

    cd /Users/pvangay/Dropbox/UMN/KnightsLab/MLRepo/web

    python ./make_page.py
    
    ### After all MD files are generated, switch back to master branch
        ### make sure to either copy/paste OR merge only the newly generated MD files in /docs files back to master branch!

For pushing onto Amazon S3:
    # currently installed on local machine and MSI
    
    gzip -1 -c Cho_trimmed_150.fasta > cho2012.fasta.gz

    aws s3 cp cho2012.fasta.gz s3://knights-lab/public/MLRepo/fasta/cho2012.fasta.gz
    
    aws s3 cp qin2012.fasta.gz s3://knights-lab/public/MLRepo/fasta/qin2012.fasta.gz
    
    #tar cvf folder.tar folder; gzip -1 folder.tar
    #aws s3 cp folder.tar.gz s3://knights-lab/public/MLRepo/fasta/folder.tar.gz
    
For tar-ing and gzipping all datasets and pushing to S3
    tar -zcvf datasets.tar.gz --exclude='*.DS_Store' datasets/
    aws s3 cp datasets.tar.gz s3://knights-lab/public/MLRepo/datasets.tar.gz

tar -zcvf /project/flatiron/pj/karlsson2013.tar.gz *
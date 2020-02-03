# Steps for submitting a new dataset and/or task

1. If you have either the raw FASTQ or processed FASTA file, please deposit it into a public repository. We list large files via publicly accessible URLs and do not support uploading of any large files. If you need assistance, please contact us.

   If starting with FASTQ, we recommend processing with [SHI7](https://github.com/knights-lab/shi7) and OTU-picking with [BURST](https://github.com/knights-lab/BURST), with [NCBI RefSeq Prokaryote files](http://metagenome.cs.umn.edu/public/MLRepo/PROK_170704.tar.gz) and [Green genes 97](http://metagenome.cs.umn.edu/public/MLRepo/gg97.tar.gz)

2. [Fork](https://help.github.com/articles/fork-a-repo/) our repository.
3. Add new tasks and datasets directly into [tasks](web/data/tasks.txt) and [datasets](web/data/datasets.txt). Make sure to fill out all sections.

   We expect you to apply rigorous standards in filtering, subsetting, and selecting samples for your classification and regression tasks.

3. When ready, submit a pull request for our review.


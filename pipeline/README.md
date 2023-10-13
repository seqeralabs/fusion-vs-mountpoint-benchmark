# Real use case comparison

At the root of this repository we have a Nextflow pipeline that emulates a real use case. See the `main.nf` file for more information.

This pipeline has three different processes:

- **CHECK_AND_UNZIP** this process has four steps:
  - First read. Simple read as fast as possible discarding the output
  - Second read. Repeat same fast read a second time to see local cache effect.
  - Verify the file MD5 checksum. Just read and do some minimal CPU usage of that file.
  - Uncompress the file. Read the file, do some CPU usage and write to disk a big file.
  - Count reads. Do a fast operation on the recently uncompressed file.

- **ZIP_AND_COMPARE** this process has two steps:
  - Compress file. Compress the previously uncompressed file.
  - Compare the file with the original one. Read both files and do some CPU usage.

- **REPORT** just collect the timings of all the previous steps and print them.

## Results

At `aws_run.txt` and `fusion_run.txt`, you can see the output of running the pipeline with a 44GB file on AWS and Fusion respectively.

We comment the results on more detail at [results.pdf](results.pdf). To understand the results is important to known that 
we are running both pipelines with some important differences:
 - AWS mountpoint is not a full POSIX complaint filesystem, this makes it impossible to use it as scratch space for Nextflow 
so the processes still need to use a temporal folder in the local disk. Even it was impossible to use it as working directory.
 - Fusion can be use as scratch and also as working directory. So we do not need to allocate big local disks on the processes and
we directly use S3 as working directory, avoiding the extra cost of moving input/output files from S3 to the share filesystem that
will be used as working directory.

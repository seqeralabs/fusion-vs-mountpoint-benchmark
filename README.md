# Comparison of Fusion, AWS mountpoint and RClone

In this repository we collect all the information related to the comparison of Fusion, AWS mountpoint and RClone.
We've done two different comparisons:
 - Performance comparison: we've compared the performance of Fusion, AWS mountpoint and RClone using FIO.
 - Real use case comparison: we've use a syntehtic Nextflow pipeline emulating real use case and comparing benefits, drawbacks and timings of each solution.

## FIO benchmark

At the `benchmark` folder you'll find FIO files and bash scripts used to compare the performance of Fusion, 
AWS mountpoint and RClone. It's a benchmark suite base on [AWS Benchmarking suite](https://github.com/awslabs/mountpoint-s3/blob/main/doc/BENCHMARKING.md).
Check the [README](benchmark/README.md) for more information.

## Real use case comparison

At the `pipeline` folder you'll find the Nextflow pipeline used to compare the performance of Fusion with AWS Mountpoint.
Check the [README](pipeline/README.md) for more information.



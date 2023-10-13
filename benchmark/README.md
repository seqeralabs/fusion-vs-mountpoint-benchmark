# FIO benchmark

This is a copy of the [AWS Benchmarking suite](https://github.com/awslabs/mountpoint-s3/blob/main/doc/BENCHMARKING.md) adding
some scripts to also run on Fusion, RClone and local disk. For more information about the benchmarking suite, 
please refer to the original.

## How to run the benchmark

Steps to run the benchmark:

1. On AWS, launch a EC2 `r6id.8xlarge` instance using recommended ECS AMI.
2. Format and mount the NVMe disks at `/scrath`.
3. Export variables:

```bash
export S3_BUCKET_NAME=fusionfs
export S3_BUCKET_TEST_PREFIX=mountpoint-benchmark/
export S3_BUCKET_BENCH_FILE=bench100GB.bin
export S3_BUCKET_SMALL_BENCH_FILE=bench5MB.bin
export S3_REGION=eu-west-1
```

4. Create two files used by read benchmarks and upload them to S3:

```
fio --directory=/scratch/fusion --filename=${S3_BUCKET_SMALL_BENCH_FILE} fio/read/seq_read_small.fio
aws s3 cp /scratch/fusion/${S3_BUCKET_SMALL_BENCH_FILE} s3://${S3_BUCKET_NAME}/${S3_BUCKET_TEST_PREFIX}

fio --directory=/scratch/fusion --filename=${S3_BUCKET_BENCH_FILE} fio/read/seq_read.fio
aws s3 cp /scratch/fusion/${S3_BUCKET_BENCH_FILE} s3://${S3_BUCKET_NAME}/${S3_BUCKET_TEST_PREFIX}
```

5. Run the respective scripts: `fs_bench_aws.sh`, `fs_bench_fusion.sh`, `fs_bench_rclone.sh` and `fs_bench_local.sh`.

## Results

At `results` folder you can see the detailed results of the benchmarking suite and 
a summary of the results at [results.pdf](results/results.pdf). 
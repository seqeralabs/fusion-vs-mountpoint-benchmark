#!/bin/bash

if ! command -v fio &> /dev/null; then
  echo "fio must be installed to run this benchmark"
  exit 1
fi

if [[ -z "${S3_BUCKET_NAME}" ]]; then
  echo "Set S3_BUCKET_NAME to run this benchmark"
  exit 1
fi

if [[ -z "${S3_BUCKET_TEST_PREFIX}" ]]; then
  echo "Set S3_BUCKET_TEST_PREFIX to run this benchmark"
  exit 1
fi

if [[ -z "${S3_BUCKET_BENCH_FILE}" ]]; then
  echo "Set S3_BUCKET_BENCH_FILE to run this benchmark"
  exit 1
fi

if [[ -z "${S3_BUCKET_SMALL_BENCH_FILE}" ]]; then
  echo "Set S3_BUCKET_SMALL_BENCH_FILE to run this benchmark"
  exit 1
fi

base_dir=$(dirname "$0")
project_dir="${base_dir}"
cd ${project_dir}

results_dir=results/fusion
runtime_seconds=360
startdelay_seconds=3
max_threads=4
iteration=1

rm -rf ${results_dir}
mkdir -p ${results_dir}

run_fio_job() {
  job_file=$1
  bench_file=$2
  mount_dir=$3

  job_name=$(basename "${job_file}")
  job_name="${job_name%.*}"

  TMPDIR=/scratch/fusion ~/usr/bin/fusion bash -c "for i in \$(seq 1 $iteration); do fio --thread --output=${results_dir}/${job_name}_\${i}.json --output-format=json --directory=${mount_dir} --filename=${bench_file} ${job_file}; done"

  # combine the results and find an average value
  jq -n 'reduce inputs.jobs[] as $job (null; .name = $job.jobname | .len += 1 | .value += (if ($job."job options".rw == "read")
      then $job.read.bw / 1024
      elif ($job."job options".rw == "randread") then $job.read.bw / 1024
      elif ($job."job options".rw == "randwrite") then $job.write.bw / 1024
      else $job.write.bw / 1024 end)) | {name: .name, value: (.value / .len), unit: "MiB/s"}' ${results_dir}/${job_name}_*.json | tee ${results_dir}/${job_name}_parsed.json

  # delete the raw output files
  for i in $(seq 1 $iteration);
  do
    rm ${results_dir}/${job_name}_${i}.json
  done
}

read_bechmark () {
  jobs_dir=bench/fio/read

  for job_file in "${jobs_dir}"/*.fio; do
    mount_dir="/fusion/s3/${S3_BUCKET_NAME}/${S3_BUCKET_TEST_PREFIX}"

    echo "Running ${job_name}"

    # set bench file
    bench_file=${S3_BUCKET_BENCH_FILE}
    # run against small file if the job file ends with small.fio
    if [[ $job_file == *small.fio ]]; then
      bench_file=${S3_BUCKET_SMALL_BENCH_FILE}
    fi

    # run the benchmark
    run_fio_job $job_file $bench_file $mount_dir

  done
}

write_benchmark () {
  jobs_dir=bench/fio/write

  for job_file in "${jobs_dir}"/*.fio; do
    mount_dir="/fusion/s3/${S3_BUCKET_NAME}/${S3_BUCKET_TEST_PREFIX}"

    # set bench file
    bench_file=${job_name}_${RANDOM}.dat

    # run the benchmark
    run_fio_job $job_file $bench_file $mount_dir

  done
}

read_bechmark
write_benchmark

# combine all bench results into one json file
jq -n '[inputs]' ${results_dir}/*.json | tee ${results_dir}/output.json

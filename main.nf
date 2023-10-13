nextflow.enable.dsl=2

process CHECK_AND_UNZIP {

    input:
      val  checksum
      path "file.fastq.gz"

    output:
      path "file.fastq", emit: fastq
      path "stats.txt" , emit: stats


    script:
    """
    # Function to store execution time
    tm() { { >&2 echo -n -e "\$1\t" ; TIMEFORMAT="%E"; time bash -c "\$2" ; } 2>> stats.txt ; }

    # Read as fast as possible
    tm read "dd if=file.fastq.gz of=/dev/null iflag=direct bs=1M"

    # Read again as fast as possible
    tm read2 "dd if=file.fastq.gz of=/dev/null iflag=direct bs=1M"

    # Verify the file MD5 checksum
    tm check "echo ${checksum} file.fastq.gz | md5sum --check --status"

    # Uncompress the file
    tm uncompress "gzip -d -c file.fastq.gz > file.fastq"

    # Count reads
    tm count "grep -c '^+\$' file.fastq" 
    """
}

process ZIP_AND_COMPARE {

    input:
      path "file.fastq"
      path "original.fastq.gz"

    output:
      path "stats.txt", emit: stats

    script:
    '''
    # Function to store execution time
    tm() { { >&2 echo -n -e "$1\t" ; TIMEFORMAT="%E"; time bash -c "$2" ; } 2>> stats.txt ; }

    # Compress file
    tm compress "gzip --fast -c file.fastq > file.fastq.gz"

    # Compare with the original compressed file
    tm compare "zcmp file.fastq.gz original.fastq.gz"
    '''
}

process REPORT {
    debug true
    publishDir "${params.outdir}"

    input:
      path "check_and_unzip.txt"
      path "zip_and_compare.txt"

    output:
      path "stats.txt"

    script:
    '''
    cat *.txt | tee stats.txt
    '''
}
 
workflow {
    CHECK_AND_UNZIP(params.md5, params.infile)
    ZIP_AND_COMPARE(CHECK_AND_UNZIP.out.fastq, params.infile)
    REPORT(CHECK_AND_UNZIP.out.stats, ZIP_AND_COMPARE.out.stats)
}

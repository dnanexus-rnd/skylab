
task CellSortBam {
  File bam_input
  Int estimated_required_disk = ceil(size(bam_input, "G") * 8)
  
  command {
    # sort the bam file by Cell (CB) and UMI (UB) tags in columns 12, 13
    samtools view "${bam_input}" | sort --parallel 2 -k12,13 > cell-sorted.sam
  }
  
  runtime {
    docker: "quay.io/humancellatlas/secondary-analysis-samtools:v0.2.2-1.6"
    cpu: 2
    memory: "7.5 GB"
    disks: "local-disk ${estimated_required_disk} HDD"
  }
  
  output {
    File sam_output = "cell-sorted.sam"
  }
}


task GeneSortBam {
  File bam_input
  Int estimated_required_disk = ceil(size(bam_input, "G") * 4)

  command {
    # filter the bam by gene tag (GE) then sort on its contents
    samtools view "${bam_input}" | grep "GE:Z:" | sort --parallel 2 -k15,15 > gene-sorted.sam
  }
  runtime {
    docker: "quay.io/humancellatlas/secondary-analysis-samtools:v0.2.2-1.6"
    cpu: 2
    memory: "7.5 GB"
    disks: "local-disk ${estimated_required_disk} HDD"
  }

  output {
    File sam_output = "gene-sorted.sam"
  }
}
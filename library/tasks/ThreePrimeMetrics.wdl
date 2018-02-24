
task CalculateGeneMetrics {
  File sam_input
  Int estimated_required_disk = ceil(size(sam_input, "G") * 3)

  command {
    Calculate10xGeneMetrics -i "${sam_input}" -o gene-metrics.csv
    gzip gene-metrics.csv
  }

  runtime {
    docker: "quay.io/humancellatlas/secondary-analysis-python3-scientific:0.1.5"
    cpu: 1
    memory: "3.75 GB"
    disks: "local-disk ${estimated_required_disk} HDD"
  }

  output {
    File gene_metrics = "gene-metrics.csv.gz"
  }
}


task CalculateCellMetrics {
  File sam_input
  Int estimated_required_disk = ceil(size(sam_input, "G") * 3)

  command {
    Calculate10xCellMetrics -i "${sam_input}" -o cell-metrics.csv
    gzip cell-metrics.csv
  }

  runtime {
    docker: "quay.io/humancellatlas/secondary-analysis-python3-scientific:0.1.5"
    cpu: 1
    memory: "3.75 GB"
    disks: "local-disk ${estimated_required_disk} HDD"
  }

  output {
    File cell_metrics = "cell-metrics.csv.gz"
  }
}

task MergeGeneMetrics {
  Array[Array[File]] metric_files

  command {
    # un-nest the Array[Array[File]]
    input_line=$(python -c "print(' '.join('${sep=' ' metric_files}'.replace('[', '').replace(']', '').replace(',', '').split()))")

    Merge10xGeneMetrics -o merged-gene-metrics.csv $input_line
    gzip merged-gene-metrics.csv
  }

  runtime {
    docker: "quay.io/humancellatlas/secondary-analysis-python3-scientific:0.1.5"
    cpu: 1
    memory: "3.75 GB"
    disks: "local-disk 100 HDD"
  }

  output {
    File gene_metrics = "merged-gene-metrics.csv.gz"
  }
}


task MergeCellMetrics {
  Array[Array[File]] metric_files

  command {
    # un-nest the Array[Array[File]]
    input_line=$(python -c "print(' '.join('${sep=' ' metric_files}'.replace('[', '').replace(']', '').replace(',', '').split()))")

    Merge10xCellMetrics -o merged-cell-metrics.csv $input_line
    gzip merged-cell-metrics.csv
  }

  runtime {
    docker: "quay.io/humancellatlas/secondary-analysis-python3-scientific:0.1.5"
    cpu: 1
    memory: "3.75 GB"
    disks: "local-disk 100 HDD"
  }

  output {
    File cell_metrics = "merged-cell-metrics.csv.gz"
  }
}



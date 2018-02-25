import "StarAlignBamSingleEnd.wdl" as star_bam
import "TagGeneExon.wdl" as tag_gene_exon
import "CorrectUmiMarkDuplicates.wdl" as umi
import "TagSortBam.wdl" as tag_sort
import "ThreePrimeMetrics.wdl" as metrics

workflow AlignTagCorrectUmis {
  Array[File] bam_array
  File tar_star_reference
  File annotations_gtf

  scatter (bam in bam_array) {

    call star_bam.StarAlignBamSingleEnd {
      input:
        bam_input = bam,
        tar_star_reference = tar_star_reference
    }

    call tag_gene_exon.TagGeneExon {
      input:
        bam_input = StarAlignBamSingleEnd.bam_output,
        annotations_gtf = annotations_gtf
    }

    call umi.CorrectUmiMarkDuplicates {
      input:
        bam_input = TagGeneExon.bam_output
    }

    call tag_sort.CellSortBam {
      input:
        bam_input = CorrectUmiMarkDuplicates.bam_output
    }

    call metrics.CalculateCellMetrics {
      input:
        bam_input = CellSortBam.bam_output
    }

    call tag_sort.GeneSortBam {
      input:
        bam_input = CorrectUmiMarkDuplicates.bam_output
    }

    call metrics.CalculateGeneMetrics {
      input:
        bam_input = GeneSortBam.bam_output
    }

  }

  output {
    Array[File] bam_outputs = CorrectUmiMarkDuplicates.bam_output
    Array[File] tag_gene_exon_log = TagGeneExon.log
    Array[File] umi_metrics = CorrectUmiMarkDuplicates.umi_metrics
    Array[File] duplicate_metrics = CorrectUmiMarkDuplicates.duplicate_metrics
    Array[File] gene_metrics = GeneSortBam.gene_metrics
    Array[File] cell_metrics = CellSortBam.cell_metrics
  }
}

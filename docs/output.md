# ZarnackGroup/majiq_splicing_analysis_pipeline: Output

## Introduction

This document describes the output produced by the pipeline. Most QC plots are collected in the MultiQC report. All paths are relative to the top-level results directory.

## Output overview

The pipeline produces the following top-level output directories:

- [`processed_inputs/`](#processed-inputs) - Processed inputs used by the workflow (annotation conversions, validated sheets, BAM indices)
- [`quality_control/`](#quality-control) - Per-sample QC results (FastQC, RSeQC)
- [`majiq/`](#majiq) - Splicing analysis outputs (build, deltapsi, heterogen, quantify, modulize tables)
- [`irfinder/`](#irfinder) - Intron retention outputs (per-sample + differential comparisons)
- [`bigWig/`](#bigwig) - Coverage tracks for genome browser visualisation
- [`reports/`](#reports) - Pipeline reports and summary tables (HTML + tabular exports)
- [`multiqc/`](#multiqc) - Aggregate QC report
- [`pipeline_info/`](#pipeline-information) - Nextflow execution reports, params, and software versions

---

## Processed inputs

<details markdown="1">
<summary>Output files</summary>

- `processed_inputs/`
  - `annotation/`
    - `*.agat.gxf`: Annotation converted with AGAT.
    - `*.bed`: Annotation converted to BED.
    - `*.agat.log`: AGAT conversion log.
  - `samplesheet/`
    - `samplesheet.valid.csv`: Validated samplesheet.
  - `contrastsheet/`
    - `contrastsheet.valid.csv`: Validated contrastsheet.
  - `samtools/`
    - `*.bam.bai`: BAM index files produced by SAMTOOLS.

</details>

---

## Quality control

### FastQC

<details markdown="1">
<summary>Output files</summary>

- `quality_control/fastqc/`
  - `*_fastqc.html`: FastQC report.
  - `*_fastqc.zip`: FastQC archive.

</details>

FastQC provides general quality metrics about the sequenced reads.

### RSeQC

<details markdown="1">
<summary>Output files</summary>

- `quality_control/rseqc/<SAMPLE>/`
  - `*.bam_stat.txt`: Alignment statistics.
  - `*.infer_experiment.txt`: Strandedness inference.
  - `*.DupRate_plot.pdf`: Duplication rate plots.
  - `*.junction.xls`: Junction annotation.
  - `*.junctionSaturation_plot.pdf`: Junction saturation plot.
  - `*.splice_events.pdf`: Splice event plots.
  - `*.splice_junction.pdf`: Splice junction plots.
  - `*.junction_annotation.log`: Annotation log.
  - `*.R`: R scripts used for plotting.

</details>

---

## MAJIQ

### MAJIQ build

<details markdown="1">
<summary>Output files</summary>

- `majiq/build/`
  - `splicegraph.zarr/`: MAJIQ splice graph (Zarr).
  - `sj/<SAMPLE>.sj/`: Splice junction quantification (Zarr).
  - `sg-coverage/<GROUP>.sgc/`: Splice graph coverage (Zarr).
  - `psi-coverage/<GROUP>.psicov/`: PSI coverage (Zarr).

</details>

> These directories are MAJIQ internal Zarr stores and are not intended for manual inspection.

### Differential splicing (deltapsi)

<details markdown="1">
<summary>Output files</summary>

- `majiq/deltapsi/deltapsi/`
  - `<CONTRAST>.deltapsi.tsv`: Differential splicing results.
  - `<CONTRAST>.deltapsi.logger.txt`: Log file.

- `majiq/deltapsi/modulize/`
  - `*.tsv`: Event-type tables produced by `voila modulize`.
  - `junctions.tsv`: Junction-level table.
  - `summary.tsv`: Summary table.
  - `voila.log`: Voila log.

</details>

### Differential splicing  (heterogen)

<details markdown="1">
<summary>Output files</summary>

- `majiq/heterogen/heterogen/`
  - `<CONTRAST>.heterogen.tsv`: Differential splicing results.
  - `<CONTRAST>.heterogen.logger.txt`: Log file.

- `majiq/heterogen/modulize/`
  - `*.tsv`: Event-type tables produced by `voila modulize`.
  - `junctions.tsv`: Junction-level table.
  - `summary.tsv`: Summary table.
  - `voila.log`: Voila log.


</details>

### Quantification

<details markdown="1">
<summary>Output files</summary>

- `majiq/quantify/`
  - `<GROUP>.tsv`: Group-level quantification.
- `majiq/heterogen/modulize/`
  - `*.tsv`: Event-type tables produced by `voila modulize`.
  - `junctions.tsv`: Junction-level table.
  - `summary.tsv`: Summary table.
  - `voila.log`: Voila log.

</details>

---

## IRFinder

### Per-sample intron retention

<details markdown="1">
<summary>Output files</summary>

- `irfinder/<SAMPLE>/`
  - `IRFinder-IR-nondir.txt`
  - `IRFinder-IR-nondir-val.txt`
  - `IRFinder-ROI.txt`
  - `IRFinder-JuncCount.txt`
  - `IRFinder-SpansPoint.txt`
  - `IRFinder-ChrCoverage.txt`
  - `WARNINGS`
  - `logs/`
    - `irfinder.stdout`
    - `irfinder.stderr`

</details>

### Differential intron retention

<details markdown="1">
<summary>Output files</summary>

- `irfinder/diff/<CONTRAST>/`
  - `groups.tsv`
  - `<GROUP>.psi.tsv`
  - `<GROUP>.tpm.tsv`
  - `events.ls`
  - `events_nowarn.ls`
  - `events_with_warn.ls`
  - `IRFinder.ioe`
  - `suppa.*`

</details>

---

## bigWig

<details markdown="1">
<summary>Output files</summary>

- `bigWig/`
  - `<SAMPLE>.bigWig`: Coverage track for genome browser/IGV visualisation.

</details>

---

## Reports

<details markdown="1">
<summary>Output files</summary>

- `reports/`
  - `majiq_deltapsi_modulize_report.html`: Rendered HTML report.
  - `majiq_deltapsi_modulize_report.qmd`: Quarto source.
  - `params.yml`: Report parameters.
  - `tables/`: contains processed majiq output tables with contrast level splice event annotations.
    - `overview_table.tsv`
    - `excel/`
      - `annotated_results.xlsx`
      - `overview_table.xlsx`
    - `rds/`
      - `annotated_results.rds`
      - `overview_table.rds`

</details>

---

## MultiQC

<details markdown="1">
<summary>Output files</summary>

- `multiqc/`
  - `multiqc_report.html`
  - `multiqc_data/`
  - `multiqc_plots/`

</details>

---

## Pipeline information

<details markdown="1">
<summary>Output files</summary>
Nextflow-generated reports and information about the pipeline execution.
- `pipeline_info/`
  - `execution_report_*.html`
  - `execution_timeline_*.html`
  - `execution_trace_*.txt`
  - `pipeline_dag_*.html`
  - `params_*.json`
  - `*_software_mqc_versions.yml`

</details>


[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.

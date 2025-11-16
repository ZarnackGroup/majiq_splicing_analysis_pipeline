# majiq_splicing_analysis_pipeline

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A524.04.2-23aa62.svg)](https://www.nextflow.io/)
[![GitHub Actions Linting Status](https://github.com/ZarnackGroup/majiq_splicing_analysis_pipeline/actions/workflows/linting.yml/badge.svg)](https://github.com/ZarnackGroup/majiq_splicing_analysis_pipeline/actions/workflows/linting.yml)
[![GitHub Actions CI Status](https://github.com/nf-core/rnaseq/actions/workflows/nf-test.yml/badge.svg)](https://github.com/nf-core/rnaseq/actions/workflows/nf-test.yml)
[![nf-test](https://img.shields.io/badge/unit_tests-nf--test-337ab7.svg)](https://www.nf-test.com)

## Introduction

**ZarnackGroup/majiq_splicing_analysis_pipeline** is a bioinformatics pipeline that ...

Our in-house pipeline for analyzing alternative splicing events from RNA sequencing data, based on Nextflow and utilizing MAJIQ as the core splicing analysis tool.

```mermaid
flowchart TB
  subgraph MAJIQ_SPLICING_ANALYSIS_PIPELINE
    subgraph required parameters
      v0["--input"]
      v2["--annotation"]
      v1["--contrasts"]
    end

    subgraph s20["converting inputs"]
          subgraph s2["annotation formatting"]
               v15([SAMTOOLS_INDEX])
          end
          subgraph s2["annotation formatting"]
               v9([AGAT_CONVERTSPGXF2GXF])
               v12([AGAT_CONVERTGFF2BED])
          end
     end
    subgraph s3["splicing analysis"]
      v25([MAJIQ])
    end
    subgraph s4["create BigWig"]
      v19([DEEPTOOLS_BAMCOVERAGE])
    end
    subgraph s7["quality_control"]
      v32([BAM_RSEQC])
      v22([FASTQC])
    end
    subgraph report
      v63([MULTIQC])
    end
    v0 --> v15
    v0 --> v19
    v15 --> v19
    v0 --> v22
    v0 --> v25
    v1 --> v25
    v0 --> v32
    v2 --> v9
    v2 --> v12
    v9 --> v12
    v12 --> v32
    v15 --> v32
    v32 --> v63
    v19 --> v63
    v22 --> v63
    v25 --> v63
    v12 --> v63
    v15 --> v63
    v6 --> s2
    v8 --> s3
    v18 --> s4
    v31 --> s7
  end

```

<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->

1. Read QC ([`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))

2. Present QC for raw reads ([`MultiQC`](http://multiqc.info/))

## Usage

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

<!-- TODO nf-core: Describe the minimum required steps to execute the pipeline, e.g. how to prepare samplesheets.
     Explain what rows and columns represent. For instance (please edit as appropriate):

First, prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
sample,fastq_1,fastq_2
CONTROL_REP1,AEG588A1_S1_L002_R1_001.fastq.gz,AEG588A1_S1_L002_R2_001.fastq.gz
```

Each row represents a fastq file (single-end) or a pair of fastq files (paired end).

-->

Now, you can run the pipeline using:

<!-- TODO nf-core: update the following command to include all required parameters for a minimal example -->

```bash
nextflow run ZarnackGroup/majiq_splicing_analysis_pipeline \
   -profile <docker/singularity/.../institute> \
   --input samplesheet.csv \
   --outdir <OUTDIR>
```

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_; see [docs](https://nf-co.re/docs/usage/getting_started/configuration#custom-configuration-files).

## Credits

majiq_splicing_analysis_pipeline was originally written by Felix Haidle.

We thank the following people for their extensive assistance in the development of this pipeline:

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use ZarnackGroup/majiq_splicing_analysis_pipeline for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

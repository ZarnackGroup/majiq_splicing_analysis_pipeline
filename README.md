# ZarnackGroup/majiq_splicing_analysis_pipeline


[![GitHub Actions CI Status](https://github.com/ZarnackGroup/majiq_splicing_analysis_pipeline/actions/workflows/nf-test.yml/badge.svg)](https://github.com/ZarnackGroup/majiq_splicing_analysis_pipeline/actions/workflows/nf-test.yml)
[![GitHub Actions Linting Status](https://github.com/ZarnackGroup/majiq_splicing_analysis_pipeline/actions/workflows/linting.yml/badge.svg)](https://github.com/ZarnackGroup/majiq_splicing_analysis_pipeline/actions/workflows/linting.yml)
[![nf-test](https://img.shields.io/badge/unit_tests-nf--test-337ab7.svg)](https://www.nf-test.com)

[![Nextflow](https://img.shields.io/badge/version-%E2%89%A525.04.0-green?style=flat&logo=nextflow&logoColor=white&color=%230DC09D&link=https%3A%2F%2Fnextflow.io)](https://www.nextflow.io/)
[![nf-core template version](https://img.shields.io/badge/nf--core_template-3.5.1-green?style=flat&logo=nfcore&logoColor=white&color=%2324B064&link=https%3A%2F%2Fnf-co.re)](https://github.com/nf-core/tools/releases/tag/3.5.1)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

## Introduction

**ZarnackGroup/majiq_splicing_analysis_pipeline** is our in-house pipeline for analyzing alternative splicing events from RNA sequencing data, based on Nextflow and utilizing [`MAJIQ V3`](https://www.biorxiv.org/content/early/2024/07/04/2024.07.02.601792) as the core splicing analysis tool.

```mermaid
flowchart TB
  subgraph MAJIQ_SPLICING_ANALYSIS_PIPELINE
    subgraph required parameters
      v0["--input"]
      v2["--annotation"]
      v1["--contrasts"]
    end

    subgraph s20["converting inputs"]
          subgraph s100["index bam files"]
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
    subgraph s7["quality control"]
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
    v9 --> v25
    v12 --> v32
    v15 --> v32
    v32 --> v63
    v19 --> v63
    v22 --> v63
    v25 --> v63
    v12 --> v63
    v15 --> v63
  end

```

1. Index BAM files ([`SAMTOOLS`](https://doi.org/10.1093/bioinformatics/btp352))

2. Convert annotation: GXF conversion ([`AGAT`](https://doi.org/10.5281/zenodo.3552717))
3. Convert annotation: BED conversion ([`AGAT`](https://doi.org/10.5281/zenodo.3552717))

4. Splicing analysis ([`MAJIQ`](https://www.biorxiv.org/content/early/2024/07/04/2024.07.02.601792))
5. Coverage track generation ([`DEEPTOOLS`](https://doi.org/10.1093/nar/gkw257))
6. Quality control: read & alignment QC ([`RSeQC`](http://rseqc.sourceforge.net/))
7. Quality control: read QC ([`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
8. Reporting ([`MultiQC`](https://pubmed.ncbi.nlm.nih.gov/27312411/))

## Usage

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

### Setting up MAJIQ

1. Obtain a LICENSE – MAJIQ is free for academic use, but you need to visit the [homepage](https://majiq.biociphers.org/app_download/).
2. Add the license key to your [Nextflow secrets](https://nextflow.io/docs/latest/secrets.html) as `MAJIQ_LICENSE`.

   ```bash
   nextflow secrets set MAJIQ_LICENSE "$(cat "majiq_license_academic_official.lic")"
   ```

3. Installing MAJIQ – choose your preferred option. Current tests are built for MAJIQ V3 at tag **3.0.6**:
   1. Set up with Conda: follow the instructions on the download page.
   2. Set up with Docker: you can find a Dockerfile to build a MAJIQ container in the [`assets`](assets/docker/majiq/Dockerfile) folder of this repository.
   3. Apptainer/Singularity: use the Docker image.
   4. Others: I have not tried anything else yet. If you find a reliable and legal way to set it up, feel free to contribute here.
4. Configuring the pipeline to use your MAJIQ installation:  
   You need to create a `.config` file where you specify the container or Conda environment for each MAJIQ process. You can find an example in the `conf` folder – [`cctb.config`](conf/cctb.config).  
   For a Conda environment, use `"conda"` instead of `"container"`.  
   Pass the created `.config` file using the [`-c` option](https://www.nextflow.io/docs/latest/config.html).

### Running the pipeline

First, prepare a samplesheet with your input data.

`samplesheet.csv`:

```csv
sample,condition,genome_bam
ERR188383,GBR,PATH/TO/ERR188383.Aligned.out.bam
ERR188428,GBR,PATH/TO/ERR188428.Aligned.out.bam
ERR188454,YRI,PATH/TO/ERR188454.Aligned.out.bam
ERR204916,YRI,PATH/TO/ERR204916.Aligned.out.bam

```

Each row represents a BAM file.  
`sample` is a unique identifier for each row.  
`condition` is used to group and compare samples.  
`genome_bam` refers to reads aligned against a genome.

`contrastsheet.csv`:

```csv
contrast,treatment,control
YRI-GBR,YRI,GBR
```

Each row represents a comparison (contrast).  
The `control` column is used as the reference in comparisons, and `treatment` specifies the other condition.  
`contrast` is an identifier for the comparison.

`annotation`:  
Provide the annotation file used during alignment. It can be in `.gtf` or `.gff3` format.  
MAJIQ requires `.gff3`. If a GTF file is provided, it will be converted using AGAT.
Now, you can run the pipeline using:

```bash
nextflow run ZarnackGroup/majiq_splicing_analysis_pipeline \
   -profile <docker/singularity/.../institute> \
   --input samplesheet.csv \
   --contrasts contrastsheet.csv \
   --annotation annotation.gff3 \
   --outdir <OUTDIR> \
   -c majiq.config
```

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_; see [docs](https://nf-co.re/docs/usage/getting_started/configuration#custom-configuration-files).

## Credits

majiq_splicing_analysis_pipeline was originally written by Felix Haidle.

We thank the following people for their extensive assistance in the development of this pipeline:

- Be the first!

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use ZarnackGroup/majiq_splicing_analysis_pipeline for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

- [nf-core](https://pubmed.ncbi.nlm.nih.gov/32055031/)

> Ewels PA, Peltzer A, Fillinger S, Patel H, Alneberg J, Wilm A, Garcia MU, Di Tommaso P, Nahnsen S. The nf-core framework for community-curated bioinformatics pipelines. Nat Biotechnol. 2020 Mar;38(3):276-278. doi: 10.1038/s41587-020-0439-x. PubMed PMID: 32055031.

- [MAJIQ v3](https://www.biorxiv.org/content/early/2024/07/04/2024.07.02.601792)

> Aicher JK, Slaff B, Jewell S, Barash Y. MAJIQ V3 offers improvements in accuracy, performance, and usability for splicing analysis from RNA sequencing. bioRxiv. 2024. doi: 10.1101/2024.07.02.601792.

- [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)

> Andrews, S. (2010). FastQC: A Quality Control Tool for High Throughput Sequence Data [Online].

- [MultiQC](https://pubmed.ncbi.nlm.nih.gov/27312411/)

> Ewels P, Magnusson M, Lundin S, Käller M. MultiQC: summarize analysis results for multiple tools and samples in a single report. Bioinformatics. 2016 Oct 1;32(19):3047-8. doi: 10.1093/bioinformatics/btw354. Epub 2016 Jun 16. PubMed PMID: 27312411; PubMed Central PMCID: PMC5039924.

- [RSeQC](http://rseqc.sourceforge.net/)

> Wang L, Wang S, Li W. RSeQC: quality control of RNA-seq experiments. Bioinformatics. 2012 Aug 15;28(16):2184-2185. doi: 10.1093/bioinformatics/bts356. PubMed PMID: 22743226.

- [AGAT](https://doi.org/10.5281/zenodo.3552717)

> Dainat J. AGAT: Another Gff Analysis Toolkit to handle annotations in any GTF/GFF format (Version v0.7.0). Zenodo. doi: 10.5281/zenodo.3552717.

- [deepTools](https://doi.org/10.1093/nar/gkw257)

> Ramírez F, Ryan DP, Grüning B, Bhardwaj V, Kilpert F, Richter AS, Heyne S, Dündar F, Manke T. deepTools2: a next generation web server for deep-sequencing data analysis. Nucleic Acids Res. 2016 Jul 8;44(W1):W160-W165. doi: 10.1093/nar/gkw257. PubMed PMID: 27079975.

- [SAMtools](https://doi.org/10.1093/bioinformatics/btp352)

  > Li H, Handsaker B, Wysoker A, Fennell T, Ruan J, Homer N, Marth G, Abecasis G, Durbin R; 1000 Genome Project Data Processing Subgroup. The Sequence Alignment/Map format and SAMtools. Bioinformatics. 2009 Aug 15;25(16):2078-2079. doi: 10.1093/bioinformatics/btp352. PubMed PMID: 19505943.
  > An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

- [Nextflow](https://pubmed.ncbi.nlm.nih.gov/28398311/)

> Di Tommaso P, Chatzou M, Floden EW, Barja PP, Palumbo E, Notredame C. Nextflow enables reproducible computational workflows. Nat Biotechnol. 2017 Apr 11;35(4):316-319. doi: 10.1038/nbt.3820. PubMed PMID: 28398311.

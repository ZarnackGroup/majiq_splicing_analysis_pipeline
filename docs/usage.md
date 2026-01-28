# ZarnackGroup/majiq_splicing_analysis_pipeline: Usage

## Introduction

**ZarnackGroup/majiq_splicing_analysis_pipeline** is our in-house pipeline for analyzing alternative splicing events from RNA sequencing data, based on Nextflow and utilizing [`MAJIQ V3`](https://www.biorxiv.org/content/early/2024/07/04/2024.07.02.601792) as the core splicing analysis tool.

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

### Setting up IRFinder-S

IRFinder-S processes are per defualt configured to utilize the Docker image provided by the [IRFinder-S repository](https://github.com/RitchieLabIGH/IRFinder/wiki/Download-and-Install). If you wish to use a different method follow the instructions on how to install IRFinder-S from source in the [IRFinder-S repository](https://github.com/RitchieLabIGH/IRFinder/wiki/Download-and-Install) and create a custom config file as described for MAJIQ above.

## Samplesheet input

You will need to create a samplesheet with information about the samples you would like to analyse before running the pipeline. Use this parameter to specify its location. It has to be a comma-separated file with 3 columns, and a header row as shown in the examples below.

```bash
--input '[path to samplesheet file]'
```

`samplesheet.csv`:

```csv
sample,condition,genome_bam
ERR188383,GBR,PATH/TO/ERR188383.Aligned.out.bam
ERR188428,GBR,PATH/TO/ERR188428.Aligned.out.bam
ERR188454,YRI,PATH/TO/ERR188454.Aligned.out.bam
ERR204916,YRI,PATH/TO/ERR204916.Aligned.out.bam

```

| Column       | Description                           |
| ------------ | ------------------------------------- |
| `sample`     | Custom sample name.                   |
| `condition`  | is used to group and compare samples. |
| `genome_bam` | Full path to BAM file for short reads |

## Contrastsheet input

You will need to create a samplesheet with information about the sample groups you would like to compare before running the pipeline. Use this parameter to specify its location. It has to be a comma-separated file with 3 columns, and a header row as shown in the examples below.

```bash
--contrasts '[path to contrastsheet file]'
```

`contrastsheet.csv`:

```csv
contrast,treatment,control
YRI-GBR,YRI,GBR
```

Each row represents a comparison (contrast).  
The `control` column is used as the reference in comparisons, and `treatment` specifies the other condition.  
`contrast` is an identifier for the comparison.

## Annotation inputs

`annotation`:  
Provide the annotation file used during alignment. It can be in `.gtf` or `.gff3` format.  
MAJIQ requires `.gff3`. If a GTF file is provided, it will be converted using AGAT. `.gz` are allowed and files will be unzipped.

`genome_fasta`:
**Optional** input that is required to run **IRFinder**. `.gz` are allowed and files will be unzipped.

## Running the pipeline

The typical command for running the pipeline is as follows:

```bash
nextflow run ZarnackGroup/majiq_splicing_analysis_pipeline \
   -profile <docker> \
   --input samplesheet.csv \
   --contrasts contrastsheet.csv \
   --annotation annotation.gff3 \
   --genome_fasta reference.fa \
   --outdir <OUTDIR> \
   -c majiq.config
```

This will launch the pipeline with the `docker` configuration profile. See below for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```bash
work                # Directory containing the nextflow working files
<OUTDIR>            # Finished results in specified location (defined with --outdir)
.nextflow_log       # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

If you wish to repeatedly use the same parameters for multiple runs, rather than specifying each flag in the command, you can specify these in a params file.

Pipeline parameters can be provided in a `yaml` or `json` file via `-params-file <file>`.

> [!WARNING]
> Do not use `-c <file>` to specify parameters as this will result in errors. Custom config files specified with `-c` must only be used for [tuning process resource specifications](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources), other infrastructural tweaks (such as output directories), or module arguments (args).

The above pipeline run specified with a params file in yaml format:

```bash
nextflow run ZarnackGroup/majiq_splicing_analysis_pipeline -profile docker -params-file params.yaml
```

with:

```yaml title="params.yaml"
input: './samplesheet.csv'
outdir: './results/'
<...>
```

You can also generate such `YAML`/`JSON` files via [nf-core/launch](https://nf-co.re/launch).

### Reproducibility

It is a good idea to specify the pipeline version when running the pipeline on your data. This ensures that a specific version of the pipeline code and software are used when you run your pipeline. If you keep using the same tag, you'll be running the same version of the pipeline, even if there have been changes to the code since.

First, go to the [ZarnackGroup/majiq_splicing_analysis_pipeline releases page](https://github.com/ZarnackGroup/majiq_splicing_analysis_pipeline/releases) and find the latest pipeline version - numeric only (eg. `1.3.1`). Then specify this when running the pipeline with `-r` (one hyphen) - eg. `-r 1.3.1`. Of course, you can switch to another version by changing the number after the `-r` flag.

This version number will be logged in reports when you run the pipeline, so that you'll know what you used when you look back in the future. For example, at the bottom of the MultiQC reports.

To further assist in reproducibility, you can use share and reuse [parameter files](#running-the-pipeline) to repeat pipeline runs with the same settings without having to write out a command with every single parameter.

> [!TIP]
> If you wish to share such profile (such as upload as supplementary material for academic publications), make sure to NOT include cluster specific paths to files, nor institutional specific profiles.

## Core Nextflow arguments

> [!NOTE]
> These options are part of Nextflow and use a _single_ hyphen (pipeline parameters use a double-hyphen)

### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments.

Several generic profiles are bundled with the pipeline which instruct the pipeline to use software packaged using different methods (Docker, Singularity, Podman, Shifter, Charliecloud, Apptainer, Conda) - see below.

> [!IMPORTANT]
> We highly recommend the use of Docker or Singularity containers for full pipeline reproducibility, however when this is not possible, Conda is also supported.

The pipeline also dynamically loads configurations from [https://github.com/nf-core/configs](https://github.com/nf-core/configs) when it runs, making multiple config profiles for various institutional clusters available at run time. For more information and to check if your system is supported, please see the [nf-core/configs documentation](https://github.com/nf-core/configs#documentation).

Note that multiple profiles can be loaded, for example: `-profile test,docker` - the order of arguments is important!
They are loaded in sequence, so later profiles can overwrite earlier profiles.

If `-profile` is not specified, the pipeline will run locally and expect all software to be installed and available on the `PATH`. This is _not_ recommended, since it can lead to different results on different machines dependent on the computer environment.

Please note that depending on your execution profile you will need to adapt how you make the MAJIQ and IRFinder-S software available to the pipeline (see [Setting up MAJIQ](#setting-up-majiq)) and [Setting up IRFinder-S](#setting-up-irfinder-s).

- `test`
  - A profile with a complete configuration for automated testing
  - Includes links to test data so needs no other parameters
- `docker`
  - A generic configuration profile to be used with [Docker](https://docker.com/)
- `singularity`
  - A generic configuration profile to be used with [Singularity](https://sylabs.io/docs/)
- `podman`
  - A generic configuration profile to be used with [Podman](https://podman.io/)
- `shifter`
  - A generic configuration profile to be used with [Shifter](https://nersc.gitlab.io/development/shifter/how-to-use/)
- `charliecloud`
  - A generic configuration profile to be used with [Charliecloud](https://charliecloud.io/)
- `apptainer`
  - A generic configuration profile to be used with [Apptainer](https://apptainer.org/)
- `wave`
  - A generic configuration profile to enable [Wave](https://seqera.io/wave/) containers. Use together with one of the above (requires Nextflow ` 24.03.0-edge` or later).
- `conda`
  - A generic configuration profile to be used with [Conda](https://conda.io/docs/). Please only use Conda as a last resort i.e. when it's not possible to run the pipeline with Docker, Singularity, Podman, Shifter, Charliecloud, or Apptainer.

### `-resume`

Specify this when restarting a pipeline. Nextflow will use cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously. For input to be considered the same, not only the names must be identical but the files' contents as well. For more info about this parameter, see [this blog post](https://www.nextflow.io/blog/2019/demystifying-nextflow-resume.html).

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

### `-c`

Specify the path to a specific config file (this is a core Nextflow command). See the [nf-core website documentation](https://nf-co.re/usage/configuration) for more information.

## Custom configuration

### Resource requests

Whilst the default requirements set within the pipeline will hopefully work for most people and with most input data, you may find that you want to customise the compute resources that the pipeline requests. Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the pipeline steps, if the job exits with any of the error codes specified [here](https://github.com/nf-core/rnaseq/blob/4c27ef5610c87db00c3c5a3eed10b1d161abf575/conf/base.config#L18) it will automatically be resubmitted with higher resources request (2 x original, then 3 x original). If it still fails after the third attempt then the pipeline execution is stopped.

To change the resource requests, please see the [max resources](https://nf-co.re/docs/usage/configuration#max-resources) and [tuning workflow resources](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources) section of the nf-core website.

### Custom Containers

In some cases, you may wish to change the container or conda environment used by a pipeline steps for a particular tool. By default, nf-core pipelines use containers and software from the [biocontainers](https://biocontainers.pro/) or [bioconda](https://bioconda.github.io/) projects. However, in some cases the pipeline specified version maybe out of date.

To use a different container from the default container or conda environment specified in a pipeline, please see the [updating tool versions](https://nf-co.re/docs/usage/configuration#updating-tool-versions) section of the nf-core website.

### Custom Tool Arguments

A pipeline might not always support every possible argument or option of a particular tool used in pipeline. Fortunately, nf-core pipelines provide some freedom to users to insert additional parameters that the pipeline does not include by default.

To learn how to provide additional arguments to a particular tool of the pipeline, please see the [customising tool arguments](https://nf-co.re/docs/usage/configuration#customising-tool-arguments) section of the nf-core website.

### nf-core/configs

In most cases, you will only need to create a custom config as a one-off but if you and others within your organisation are likely to be running nf-core pipelines regularly and need to use the same settings regularly it may be a good idea to request that your custom config file is uploaded to the `nf-core/configs` git repository. Before you do this please can you test that the config file works with your pipeline of choice using the `-c` parameter. You can then create a pull request to the `nf-core/configs` repository with the addition of your config file, associated documentation file (see examples in [`nf-core/configs/docs`](https://github.com/nf-core/configs/tree/master/docs)), and amending [`nfcore_custom.config`](https://github.com/nf-core/configs/blob/master/nfcore_custom.config) to include your custom profile.

See the main [Nextflow documentation](https://www.nextflow.io/docs/latest/config.html) for more information about creating your own configuration files.

If you have any questions or issues please send us a message on [Slack](https://nf-co.re/join/slack) on the [`#configs` channel](https://nfcore.slack.com/channels/configs).

## Running in the background

Nextflow handles job submissions and supervises the running jobs. The Nextflow process must run until the pipeline is finished.

The Nextflow `-bg` flag launches Nextflow in the background, detached from your terminal so that the workflow does not stop if you log out of your session. The logs are saved to a file.

Alternatively, you can use `screen` / `tmux` or similar tool to create a detached session which you can log back into at a later time.
Some HPC setups also allow you to run nextflow within a cluster job submitted your job scheduler (from where it submits more jobs).

## Nextflow memory requirements

In some cases, the Nextflow Java virtual machines can start to request a large amount of memory.
We recommend adding the following line to your environment to limit this (typically in `~/.bashrc` or `~./bash_profile`):

```bash
NXF_OPTS='-Xms1g -Xmx4g'
```

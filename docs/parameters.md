# ZarnackGroup/majiq_splicing_analysis_pipeline pipeline parameters

In-house pipeline for analyzing alternative splicing events from RNA sequencing data, based on Nextflow and utilizing MAJIQ as the core splicing analysis tool.

## Input/output options

Define where the pipeline should find input data and save output data.

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `input` | Path to comma-separated file containing information about the samples in the experiment. <details><summary>Help</summary><small>You will need to create a design file with information about the samples in your experiment before running the pipeline. Use this parameter to specify its location. It has to be a comma-separated file with 3 columns, and a header row.</small></details>| `string` |  | True |  |
| `contrasts` | Path to comma-separated file containing information about the contrasts in the experiment. | `string` |  |  |  |
| `annotation` | Path to the annotation file used during alignment. Must be in GTF or GFF3 format. If a GTF is provided, it will be converted to GFF3 automatically. <details><summary>Help</summary><small>Ensure the annotation file matches the one used for generating the BAM files. Supported formats: .gtf, .gff3</small></details>| `string` |  | True |  |
| `genome_fasta` | Path to the reference genome fasta. Required for IRFinder.. | `string` |  |  |  |
| `outdir` | The output directory where the results will be saved. You have to use absolute paths to storage on Cloud infrastructure. | `string` |  | True |  |
| `email` | Email address for completion summary. <details><summary>Help</summary><small>Set this parameter to your e-mail address to get a summary e-mail with details of the run sent to you when the workflow exits. If set in your user config file (`~/.nextflow/config`) then you don't need to specify this on the command line for every run.</small></details>| `string` |  |  |  |
| `multiqc_title` | MultiQC report title. Printed as page header, used for filename if not otherwise specified. | `string` |  |  |  |

## MAJIQ

Parameters to modify the MAJIQ Analysis

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `skip_psi` | If set to true, this will skip the voila psi quantification | `boolean` | False |  |  |
| `skip_deltapsi` | If set to true, this will skip the voila deltapsi quantification | `boolean` | False |  |  |
| `skip_heterogen` | If set to true, this will skip the voila heterogen quantification | `boolean` | False |  |  |
| `majiq_buildgff3_args` | Additional parameters to pass to the underlying command. Provide as a single string. | `string` |  |  |  |
| `majiq_buildsj_args` | Additional parameters to pass to the underlying command. Provide as a single string. | `string` |  |  |  |
| `majiq_buildupdate_args` | Additional parameters to pass to the underlying command. Provide as a single string. | `string` |  |  |  |
| `majiq_psicoverage_args` | Additional parameters to pass to the underlying command. Provide as a single string. | `string` |  |  |  |
| `majiq_deltapsi_args` | Additional parameters to pass to the underlying command. Provide as a single string. | `string` |  |  |  |
| `majiq_heterogen_args` | Additional parameters to pass to the underlying command. Provide as a single string. | `string` |  |  |  |
| `majiq_sgcoverage_args` | Additional parameters to pass to the underlying command. Provide as a single string. | `string` |  |  |  |
| `deltapsi_modulize_args` | Additional parameters to pass to the underlying command. Provide as a single string. | `string` |  |  |  |
| `heterogen_modulize_args` | Additional parameters to pass to the underlying command. Provide as a single string. | `string` |  |  |  |
| `majiq_quantify_args` | Additional parameters to pass to the underlying command. Provide as a single string. | `string` |  |  |  |
| `majiq_quantify_modulize_args` | Additional parameters to pass to the underlying command. Provide as a single string. | `string` |  |  |  |

## IRFinder

Parameters to modify the IRFinder Analysis

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `skip_irfinder` | If set to true, this will skip the IRFinder Analysis | `boolean` | False |  |  |
| `irfinder_buildrefprocess_args` | Additional parameters to pass to the underlying command. Provide as a single string. | `string` |  |  |  |
| `irfinder_bam_args` | Additional parameters to pass to the underlying command. Provide as a single string. | `string` |  |  |  |
| `irfinder_diff_args` | Additional parameters to pass to the underlying command. Provide as a single string. | `string` |  |  |  |

## RSEQC

Parameters to modify the RSEQC execution

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `skip_rseqc` | Skip RSEQC if set to true | `boolean` | False |  |  |
| `rseqc_modules` | Which RSEQC modules to run. Comma seperated list. "inner_distance" and "read_distribution" not available | `string` | bam_stat,infer_experiment,junction_annotation,junction_saturation,read_duplication |  |  |
| `stranded_threshold` | The fraction of stranded reads that must be assigned to a strandedness for confident assignment. Must be at least 0.5. | `number` | 0.8 |  |  |
| `unstranded_threshold` | The difference in fraction of stranded reads assigned to 'forward' and 'reverse' below which a sample is classified as 'unstranded'. By default the forward and reverse fractions must differ by less than 0.1 for the sample to be called as unstranded. | `number` | 0.1 |  |  |

## DEEPTOOLS

Parameters to modify the DEEPTOOLS execution

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `skip_deeptools_bamcoverage` | Skip bamCoverage if set to true | `boolean` | False |  |  |
| `deeptools_bamcoverage_args` | additional arguments for the bamCoverage command | `string` |  |  |  |

## Institutional config options

Parameters used to describe centralised config profiles. These should not be edited.

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `custom_config_version` | Git commit id for Institutional configs. | `string` | master |  | True |
| `custom_config_base` | Base directory for Institutional configs. <details><summary>Help</summary><small>If you're running offline, Nextflow will not be able to fetch the institutional config files from the internet. If you don't need them, then this is not a problem. If you do need them, you should download the files from the repo and tell Nextflow where to find them with this parameter.</small></details>| `string` | https://raw.githubusercontent.com/nf-core/configs/master |  | True |
| `config_profile_name` | Institutional config name. | `string` |  |  | True |
| `config_profile_description` | Institutional config description. | `string` |  |  | True |
| `config_profile_contact` | Institutional config contact information. | `string` |  |  | True |
| `config_profile_url` | Institutional config URL link. | `string` |  |  | True |

## Generic options

Less common options for the pipeline, typically set in a config file.

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `version` | Display version and exit. | `boolean` |  |  | True |
| `publish_dir_mode` | Method used to save pipeline results to output directory. (accepted: `symlink`\|`rellink`\|`link`\|`copy`\|`copyNoFollow`\|`move`) <details><summary>Help</summary><small>The Nextflow `publishDir` option specifies which intermediate files should be saved to the output directory. This option tells the pipeline what method should be used to move these files. See [Nextflow docs](https://www.nextflow.io/docs/latest/process.html#publishdir) for details.</small></details>| `string` | copy |  | True |
| `email_on_fail` | Email address for completion summary, only when pipeline fails. <details><summary>Help</summary><small>An email address to send a summary email to when the pipeline is completed - ONLY sent if the pipeline does not exit successfully.</small></details>| `string` |  |  | True |
| `plaintext_email` | Send plain-text email instead of HTML. | `boolean` |  |  | True |
| `max_multiqc_email_size` | File size limit when attaching MultiQC reports to summary emails. | `string` | 25.MB |  | True |
| `monochrome_logs` | Do not use coloured log outputs. | `boolean` |  |  | True |
| `hook_url` | Incoming hook URL for messaging service <details><summary>Help</summary><small>Incoming hook URL for messaging service. Currently, MS Teams and Slack are supported.</small></details>| `string` |  |  | True |
| `multiqc_config` | Custom config file to supply to MultiQC. | `string` |  |  | True |
| `multiqc_logo` | Custom logo file to supply to MultiQC. File name must also be set in the MultiQC config file | `string` |  |  | True |
| `multiqc_methods_description` | Custom MultiQC yaml file containing HTML including a methods description. | `string` |  |  |  |
| `validate_params` | Boolean whether to validate parameters against the schema at runtime | `boolean` | True |  | True |
| `pipelines_testdata_base_path` | Base URL or local path to location of pipeline test dataset files | `string` | https://raw.githubusercontent.com/nf-core/test-datasets/ |  | True |
| `trace_report_suffix` | Suffix to add to the trace report filename. Default is the date and time in the format yyyy-MM-dd_HH-mm-ss. | `string` |  |  | True |
| `help` | Display the help message. | `['boolean', 'string']` |  |  |  |
| `help_full` | Display the full detailed help message. | `boolean` |  |  |  |
| `show_hidden` | Display hidden parameters in the help message (only works when --help or --help_full are provided). | `boolean` |  |  |  |

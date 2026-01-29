# ZarnackGroup/majiq_splicing_analysis_pipeline: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.1.0 - [2026-01-29]

Initial release of `ZarnackGroup/majiq_splicing_analysis_pipeline`, created using the
[nf-core](https://nf-co.re/) template. This version is intended as a citable, pre-1.0 release.
The pipeline interface and outputs may change in future 0.x releases.

Initial release of ZarnackGroup/majiq_splicing_analysis_pipeline, created with the [nf-core](https://nf-co.re/) template.

### `Added`

- Core functionality for splicing analysis using MAJIQ.
- Additional downstream analysis and visualization steps for MAJIQ outputs.
- Basic IRFinder-S integration for intron retention analysis.
- deepTools BAM coverage generation for visualization in genome browsers.
- Quality control using FastQC, RSeQC, and MultiQC.

### `Fixed`

### `Dependencies`

- MAJIQ (v3.0.x)
- IRFinder-S (v2.0) (optional)
- Nextflow (>= 25.04.0)

### `Deprecated`

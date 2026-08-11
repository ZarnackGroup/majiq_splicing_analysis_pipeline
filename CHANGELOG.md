# ZarnackGroup/majiq_splicing_analysis_pipeline: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-08-11

### Added

- Added BED file outputs for regulated events from the MAJIQ deltapsi modulize report (#16).

### Changed

- Replaced RSeQC with RustQC for RNA-seq quality control (#15).
- Added stricter validation of condition names: names must start with a letter and contain only alphanumeric characters (#17).
- Replaced the Mermaid workflow overview with an nf-metro pipeline visualization (#18).
- Updated nf-core modules and adjusted affected workflows (#19).
- Updated the nf-core pipeline template from version 3.5.1 to 4.1.0 (#20).
- Updated the minimum required Nextflow version from 25.04.0 to 25.10.4.

## [0.1.0] - 2026-01-29

Initial release of `ZarnackGroup/majiq_splicing_analysis_pipeline`, created using the
[nf-core](https://nf-co.re/) template. This version is intended as a citable, pre-1.0 release.
The pipeline interface and outputs may change in future 0.x releases.

### Added

- Added core alternative splicing analysis using MAJIQ.
- Added downstream analysis and visualization of MAJIQ outputs.
- Added optional IRFinder-S integration for intron retention analysis.
- Added deepTools BAM coverage generation for visualization in genome browsers.
- Added quality control using FastQC, RSeQC, and MultiQC.
- Added support for MAJIQ v3.0.x and IRFinder-S v2.0.
- Added support for Nextflow >= 25.04.0.

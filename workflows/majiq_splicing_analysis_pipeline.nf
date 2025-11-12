/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// MODULES
include { FASTQC                 } from '../modules/nf-core/fastqc/main'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { SAMTOOLS_INDEX         } from '../modules/nf-core/samtools/index/main'
include { AGAT_CONVERTSPGXF2GXF  } from '../modules/nf-core/agat/convertspgxf2gxf/main'
include { AGAT_CONVERTGFF2BED    } from '../modules/nf-core/agat/convertgff2bed/main'
include { DEEPTOOLS_BAMCOVERAGE  } from '../modules/nf-core/deeptools/bamcoverage/main'

// SUBWORKFLOWS
include { MAJIQ                  } from '../subworkflows/local/majiq/main'
include { BAM_RSEQC              } from '../subworkflows/nf-core/bam_rseqc/main'

// FUNCTIONS
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_majiq_splicing_analysis_pipeline_pipeline'
include { getInferexperimentStrandedness } from '../subworkflows/local/utils_nfcore_majiq_splicing_analysis_pipeline_pipeline'
include { multiqcTsvFromList      } from '../subworkflows/local/utils_nfcore_majiq_splicing_analysis_pipeline_pipeline'



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow MAJIQ_SPLICING_ANALYSIS_PIPELINE {

    take:
        ch_bam          // channel: bam file inputs
        ch_contrasts    // channel: contrasts input
        ch_annotation   // channel: annotation input

    main:

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()


    //
    // MODULE: AGAT_CONVERTSPGXF2GXF
    //

    ch_annotation = Channel.fromPath(params.annotation, checkIfExists: true)
        .map { file ->
        def meta = [ id: file.baseName ]
        tuple(meta, file)
    }


    // Handle annotation file input
    if (params.annotation.endsWith('.gff3')) {
        // Use GFF3
        ch_gff = ch_annotation

    } else if (params.annotation.endsWith('.gtf')) {

        AGAT_CONVERTSPGXF2GXF(
            ch_annotation
            )

        ch_gff = AGAT_CONVERTSPGXF2GXF.out.output_gff
        ch_versions = ch_versions.mix(AGAT_CONVERTSPGXF2GXF.out.versions)
    }

    //
    // MODULE: AGAT_CONVERTGFF2BED
    //
    AGAT_CONVERTGFF2BED(
        ch_gff
    )
    .bed
    .set { ch_bed }

    ch_versions = ch_versions.mix(AGAT_CONVERTGFF2BED.out.versions)

    //
    // MODULE: SAMTOOLS_INDEX
    //
    SAMTOOLS_INDEX(
        ch_bam
    )

    ch_bam.join(SAMTOOLS_INDEX.out.bai, by: [0])
    .set { ch_bam_with_index }


    ch_versions = ch_versions.mix(SAMTOOLS_INDEX.out.versions.first())

    //
    // MODULE: DEEPTOOLS_BAMCOVERAGE
    //

    if (!params.skip_deeptools_bamcoverage) {
        DEEPTOOLS_BAMCOVERAGE(
            ch_bam_with_index,
            [],
            []
        )
        ch_versions = ch_versions.mix(DEEPTOOLS_BAMCOVERAGE.out.versions.first())
    }

    //
    // MODULE: Run FastQC
    //
    FASTQC (
        ch_bam
    )
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]})
    ch_versions = ch_versions.mix(FASTQC.out.versions.first())

    //
    // SUBWORKFLOW: Run MAJIQ
    //
    MAJIQ (
        ch_bam,
        SAMTOOLS_INDEX.out.bai,
        ch_gff,
        ch_contrasts
    )
    ch_versions = ch_versions.mix(MAJIQ.out.versions.first())

    //
    // SUBWORKFLOW: RSEQC
    //


    // adjust channel structures for RSeQC subworkflow for bam and bed files


    ch_bam_with_index.map { meta, bamList, bai ->
        def bam = (bamList instanceof List ? bamList[0] : bamList)
        tuple(meta, [bam, bai])
    }.set { ch_bam_bai }


    ch_bed
    .map   { meta, bed -> bed }  // drop meta
    .unique()
    .first()
    .set { ch_bed_single }

    def rseqc_modules = params.rseqc_modules ? params.rseqc_modules.split(',').collect{ it.trim().toLowerCase() } : []



    if (!params.skip_rseqc && rseqc_modules.size() > 0) {
        BAM_RSEQC (
            ch_bam_with_index,
            ch_bed_single,
            rseqc_modules
        )
        ch_multiqc_files = ch_multiqc_files.mix(BAM_RSEQC.out.bamstat_txt.collect{it[1]})
        ch_multiqc_files = ch_multiqc_files.mix(BAM_RSEQC.out.inferexperiment_txt.collect{it[1]})
        ch_multiqc_files = ch_multiqc_files.mix(BAM_RSEQC.out.innerdistance_freq.collect{it[1]})
        ch_multiqc_files = ch_multiqc_files.mix(BAM_RSEQC.out.junctionannotation_log.collect{it[1]})
        ch_multiqc_files = ch_multiqc_files.mix(BAM_RSEQC.out.junctionsaturation_rscript.collect{it[1]})
        ch_multiqc_files = ch_multiqc_files.mix(BAM_RSEQC.out.readdistribution_txt.collect{it[1]})
        ch_multiqc_files = ch_multiqc_files.mix(BAM_RSEQC.out.readduplication_pos_xls.collect{it[1]})
        ch_multiqc_files = ch_multiqc_files.mix(BAM_RSEQC.out.tin_txt.collect{it[1]})
        ch_versions = ch_versions.mix(BAM_RSEQC.out.versions)
        ch_strand_comparison = BAM_RSEQC.out.inferexperiment_txt
            .map { meta, strand_log ->
                def rseqc_inferred_strand = getInferexperimentStrandedness(
                    strand_log,
                    params.stranded_threshold,
                    params.unstranded_threshold
                )
                def rseqc_strandedness = rseqc_inferred_strand.inferred_strandedness

                def status = 'fail'
                if (meta.strandedness == rseqc_strandedness) {
                    status = 'pass'
                }

                def multiqc_lines = [
                    "$meta.id\tRSeQC\t${rseqc_inferred_strand.values().join('\t')}"
                ]

                return [ meta, status, multiqc_lines ]
            }
            .multiMap { meta, status, multiqc_lines ->
                status: [ meta.id, status == 'pass' ]
                multiqc_lines: multiqc_lines
            }
        sample_status_header_multiqc = file("${projectDir}/assets/strandedness_table_header.txt")

        // Store the statuses for output
        ch_strand_status = ch_strand_comparison.status

        // Take the lines formatted for MultiQC and output
        ch_strand_comparison.multiqc_lines
            .flatten()
            .collect()
            .map {
                tsv_data ->
                    def header = [
                        "Sample",
                        "Strand inference method",
                        "Inferred strandedness",
                        "Sense (%)",
                        "Antisense (%)",
                        "Unstranded (%)"
                    ]
                    sample_status_header_multiqc.text + multiqcTsvFromList(tsv_data, header)
            }
            .set { ch_fail_strand_multiqc }

        ch_multiqc_files = ch_multiqc_files.mix(ch_fail_strand_multiqc.collectFile(name: 'sample_strandedness_mqc.tsv'))
        }


    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name:  'majiq_splicing_analysis_pipeline_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }


    //
    // MODULE: MultiQC
    //
    ch_multiqc_config        = Channel.fromPath(
        "$projectDir/assets/multiqc_config.yml", checkIfExists: true)
    ch_multiqc_custom_config = params.multiqc_config ?
        Channel.fromPath(params.multiqc_config, checkIfExists: true) :
        Channel.empty()
    ch_multiqc_logo          = params.multiqc_logo ?
        Channel.fromPath(params.multiqc_logo, checkIfExists: true) :
        Channel.empty()

    summary_params      = paramsSummaryMap(
        workflow, parameters_schema: "nextflow_schema.json")
    ch_workflow_summary = Channel.value(paramsSummaryMultiqc(summary_params))
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_custom_methods_description = params.multiqc_methods_description ?
        file(params.multiqc_methods_description, checkIfExists: true) :
        file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
    ch_methods_description                = Channel.value(
        methodsDescriptionText(ch_multiqc_custom_methods_description))

    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_methods_description.collectFile(
            name: 'methods_description_mqc.yaml',
            sort: true
        )
    )

    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList(),
        [],
        []
    )



    emit:
    multiqc_report = MULTIQC.out.report.toList() // channel: /path/to/multiqc_report.html
    versions       = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

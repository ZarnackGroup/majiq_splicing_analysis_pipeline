/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { FASTQC                 } from '../modules/nf-core/fastqc/main'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { SAMTOOLS_INDEX         } from '../modules/nf-core/samtools/index/main'
include { AGAT_CONVERTSPGXF2GXF  } from '../modules/nf-core/agat/convertspgxf2gxf/main'
include { DEEPTOOLS_BAMCOVERAGE  } from '../modules/nf-core/deeptools/bamcoverage/main'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_majiq_splicing_analysis_pipeline_pipeline'
include { MAJIQ                  } from '../subworkflows/local/majiq/main'

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
    // MODULE: SAMTOOLS_INDEX
    //
    SAMTOOLS_INDEX(
        ch_bam
    )

    ch_bam
        .join(SAMTOOLS_INDEX.out.bai)
        .map { meta, bam, bai -> tuple(meta, bam, bai) }
        .set { ch_bam_with_index }

    ch_bam_with_index.view()

    ch_versions = ch_versions.mix(SAMTOOLS_INDEX.out.versions.first())

    //
    // MODULE: DEEPTOOLS_BAMCOVERAGE
    //


    ch_bigwig = DEEPTOOLS_BAMCOVERAGE(
        ch_bam_with_index,
        [],
        []
    )

    ch_versions = ch_versions.mix(DEEPTOOLS_BAMCOVERAGE.out.versions.first())


    //
    // MODULE: Run FastQC
    //
    FASTQC (
        ch_bam
    )
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]})
    ch_versions = ch_versions.mix(FASTQC.out.versions.first())

    // WORKFLOW: Run MAJIQ
    MAJIQ (
        ch_bam,
        SAMTOOLS_INDEX.out.bai,
        ch_gff,
        ch_contrasts
    )
    ch_versions = ch_versions.mix(MAJIQ.out.versions.first())


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

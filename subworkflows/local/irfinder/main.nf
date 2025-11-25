
include { IRFINDER_BAM                } from '../../../modules/local/irfinder/bam/main'
include { IRFINDER_BUILDREFPROCESS    } from '../../../modules/local/irfinder/buildrefprocess/main'
include { IRFINDER_DIFF               } from '../../../modules/local/irfinder/diff/main'

workflow IRFINDER {

    take:
    ch_gtf          // channel: [ val(meta), path(gtf) ]
    ch_fasta        // channel: path(fasta)
    ch_bam          // channel: [ val(meta), [ bam ] ]
    ch_contrasts

    main:

    ch_versions = channel.empty()

    IRFINDER_BUILDREFPROCESS ( 
        ch_gtf,
        ch_fasta
        )
    ch_versions = ch_versions.mix(IRFINDER_BUILDREFPROCESS.out.versions_irfinder.first())

    IRFINDER_BAM ( 
        ch_bam,
        IRFINDER_BUILDREFPROCESS.out.ir_finder_reference.map{ meta, file -> file }
    )
    ch_versions = ch_versions.mix(IRFINDER_BUILDREFPROCESS.out.versions_irfinder.first())


    contrast_comparison_ch = ch_contrasts
        .map { it -> [it['treatment'], it] }
        .combine ( IRFINDER_BAM.out.irfinder_bam_directory, by: 0 )
        .map { it -> it[1] + ['g1': it[2]] }
        .map { it -> [it['control'], it] }
        .combine ( IRFINDER_BAM.out.irfinder_bam_directory, by: 0 )
        .map { it -> it[1] + ['g2': it[2]] }

    IRFINDER_DIFF (
        contrast_comparison_ch
    )
    ch_versions = ch_versions.mix(IRFINDER_DIFF.out.versions_irfinder.first())

    emit:
    versions                 = ch_versions                     
}

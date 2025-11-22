
include { IRFINDER_BAM                } from '../../../modules/local/irfinder/bam/main'
include { IRFINDER_BUILDREFPROCESS    } from '../../../modules/local/irfinder/buildrefprocess/main'

workflow IRFINDER {

    take:
    ch_gtf          // channel: [ val(meta), path(gtf) ]
    ch_fasta        // channel: path(fasta)
    ch_bam          // channel: [ val(meta), [ bam ] ]

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

    emit:
    versions                 = ch_versions                     
}

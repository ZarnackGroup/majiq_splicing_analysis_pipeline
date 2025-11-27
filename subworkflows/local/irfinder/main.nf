
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

    IRFINDER_BUILDREFPROCESS ( 
        ch_gtf,
        ch_fasta
        )

    IRFINDER_BAM ( 
        ch_bam,
        IRFINDER_BUILDREFPROCESS.out.ir_finder_reference
        .map{ meta, file -> file }
        .first()
    )

    ch_dirs_by_condition = IRFINDER_BAM.out.irfinder_bam_directory
        .map { meta, dir -> 
            [meta.condition, dir]
        }
        .groupTuple()

    contrast_comparison_ch = ch_contrasts
        .map { contrast -> [contrast.treatment, contrast] }
        .combine(ch_dirs_by_condition, by: 0)
        .map { treatment_cond, contrast, treatment_dirs ->
            [contrast.control, contrast, treatment_dirs]
        }
        .combine(ch_dirs_by_condition, by: 0)
        .map { control_cond, contrast, treatment_dirs, control_dirs ->
            tuple(
                contrast.contrast,
                contrast.treatment,
                contrast.control,
                treatment_dirs,
                control_dirs
            )
        }

    IRFINDER_DIFF (
        contrast_comparison_ch
    )
    
    emit:
    irfinder_bam_directory   = IRFINDER_BAM.out.irfinder_bam_directory
    irfinder_diff_results    = IRFINDER_DIFF.out.diff_results
    ir_finder_reference      = IRFINDER_BUILDREFPROCESS.out.ir_finder_reference                   
}

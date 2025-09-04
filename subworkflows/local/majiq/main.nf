// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules

include { MAJIQ_BUILDGFF3           }       from '../../../modules/local/majiq/buildgff3/main'
include { MAJIQ_BUILDSJ             }       from '../../../modules/local/majiq/buildsj/main'
include { MAJIQ_BUILDUPDATE         }       from '../../../modules/local/majiq/buildupdate/main'
include { MAJIQ_PSICOVERAGE         }       from '../../../modules/local/majiq/psicoverage/main'
include { MAJIQ_PSI                 }       from '../../../modules/local/majiq/psi/main'
include { MAJIQ_DELTAPSI            }       from '../../../modules/local/majiq/deltapsi/main'
include { MAJIQ_HETEROGEN           }       from '../../../modules/local/majiq/heterogen/main'
include { MAJIQ_SGCOVERAGE          }       from '../../../modules/local/majiq/sgcoverage/main'
include { MAJIQ_MODULIZE as DELTAPSI_MODULIZE            }       from '../../../modules/local/majiq/modulize/main'
include { MAJIQ_MODULIZE as HETEROGEN_MODULIZE           }       from '../../../modules/local/majiq/modulize/main'

workflow MAJIQ {

    take:

    ch_bam // channel: [ val(meta), [ bam ] ]
    ch_bai // channel: [ val(meta), [ bai ] ]
    ch_gff // channel: [ val(meta), [ gff ] ]
    ch_contrasts


    main:

    ch_versions = Channel.empty()


    ch_license = Channel.fromPath(params.majiq_license, checkIfExists: true)






    //
    // MODULE: MAJIQ_BUILDGFF3
    //
    MAJIQ_BUILDGFF3(
        ch_gff,
        ch_license
    )
    ch_versions = ch_versions.mix(MAJIQ_BUILDGFF3.out.versions)

    ch_splicegraph = MAJIQ_BUILDGFF3.out.splicegraph


    ch_combine = ch_bam.combine(ch_splicegraph).combine(ch_license)


    MAJIQ_BUILDSJ(
        ch_combine
    )

    ch_versions = ch_versions.mix(MAJIQ_BUILDSJ.out.versions)

    ch_sj_condition_map = MAJIQ_BUILDSJ.out.sj
        .collect()
        .map { it.collate(2) }  // Group every 2 elements: [meta, file]
        .map { pairs ->
            pairs.collect { [ it[1].name.toString(), it[0].condition ] }
        }

    ch_sj = MAJIQ_BUILDSJ.out.sj
        .collect()
        .map { it.collate(2) }
        .map { pairs ->
            pairs.collect {  it[1]  }
        }



    //
    // MODULE: MAJIQ_BUILDUPDATE
    //

    MAJIQ_BUILDUPDATE(
        ch_sj,
        ch_splicegraph,
        ch_license,
        ch_sj_condition_map
    )
    ch_versions = ch_versions.mix(MAJIQ_BUILDUPDATE.out.versions)


    ch_finished_splicegraph = MAJIQ_BUILDUPDATE.out.splicegraph


    //
    // MODULE: MAJIQ_PSICOVERAGE
    //

    ch_combined_sj = MAJIQ_BUILDSJ.out.sj
        .combine(ch_finished_splicegraph)
        .combine(ch_license)





    MAJIQ_PSICOVERAGE(
        ch_combined_sj
    )

    ch_versions = ch_versions.mix(MAJIQ_PSICOVERAGE.out.versions)

    ch_combined_psicoverage = MAJIQ_PSICOVERAGE.out.psi_coverage
        .combine(ch_finished_splicegraph)
        .combine(ch_license)






    ch_psi_coverage = MAJIQ_PSICOVERAGE.out.psi_coverage
        .collect()



    ch_condition_samples = MAJIQ_PSICOVERAGE.out.psi_coverage
        .map { pair ->
            tuple(pair[0].condition, pair[1])  }
        .groupTuple()


    contrast_comparison_ch = ch_contrasts
        .map { it -> [it['treatment'], it] }
        .combine ( ch_condition_samples, by: 0 )
        .map { it -> it[1] + ['psicov1': it[2]] }
        .map { it -> [it['control'], it] }
        .combine ( ch_condition_samples, by: 0 )
        .map { it -> it[1] + ['psicov2': it[2]] }

    ch_contrast_input = contrast_comparison_ch.combine(ch_finished_splicegraph)
        .combine(ch_license)
        .map { it -> [it[0].contrast, it[0].treatment, it[0].control, it[0].psicov1, it[0].psicov2, it[2], it[3]] }


    //
    // MODULE: MAJIQ_SGCOVERAGE
    //

    ch_condition_samples_sj = MAJIQ_BUILDSJ.out.sj
        .map { pair ->
            tuple(pair[0].condition, pair[1])  }
        .groupTuple()

    ch_sgcoverage_input = ch_condition_samples_sj
        .combine(ch_finished_splicegraph)
        .combine(ch_license)



    MAJIQ_SGCOVERAGE(
        ch_sgcoverage_input
    )
    ch_versions = ch_versions.mix(MAJIQ_SGCOVERAGE.out.versions)


    //
    //  MAJIQ Quantification
    //



    if( !params.skip_psi ) {

        //
        // MODULE: MAJIQ_PSI
        //

        MAJIQ_PSI(
            ch_combined_psicoverage
        )

        ch_versions = ch_versions.mix(MAJIQ_PSI.out.versions)
    }


    if ( !params.skip_deltapsi ) {

        //
        // MODULE: MAJIQ_DELTAPSI
        //

        MAJIQ_DELTAPSI(
            ch_contrast_input
        )

        ch_versions = ch_versions.mix(MAJIQ_DELTAPSI.out.versions)

        //
        // MODULE: MAJIQ_MODULIZE
        //


        ch_modulize_input_deltapsi = MAJIQ_SGCOVERAGE.out.sgc_files
            .collect{  it[1]  }
            .combine(MAJIQ_DELTAPSI.out.dpsicov.collect())
            .toList()
            .combine(ch_finished_splicegraph)
            .combine(ch_license)

        DELTAPSI_MODULIZE(
            ch_modulize_input_deltapsi
    )



    ch_versions = ch_versions.mix(DELTAPSI_MODULIZE.out.versions)
    }


    if ( !params.skip_heterogen ) {
        //
        // MODULE: MAJIQ_HETEROGEN
        //

        MAJIQ_HETEROGEN(
            ch_contrast_input
        )

        ch_versions = ch_versions.mix(MAJIQ_HETEROGEN.out.versions)

        //
        // MODULE: MAJIQ_MODULIZE
        //

        ch_modulize_input_heterogen = MAJIQ_SGCOVERAGE.out.sgc_files
            .collect{  it[1]  }
            .combine(MAJIQ_HETEROGEN.out.hetcov.collect())
            .toList()
            .combine(ch_finished_splicegraph)
            .combine(ch_license)

        HETEROGEN_MODULIZE(
            ch_modulize_input_heterogen
        )



        ch_versions = ch_versions.mix(HETEROGEN_MODULIZE.out.versions)

    }









    emit:
    versions = ch_versions                     // channel: [ versions.yml ]
}

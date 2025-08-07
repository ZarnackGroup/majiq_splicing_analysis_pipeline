// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules

include { MAJIQ_BUILDGFF3      }    from '../../../modules/local/majiq/buildgff3/main'
include { MAJIQ_BUILDSJ        }       from '../../../modules/local/majiq/buildsj/main'
//include { MAJIQ_BUILDUPDATE }       from '../../../modules/local/majiq/buildupdate/main'
//include { MAJIQ_PSICOVERAGE     }   from '../../../modules/local/majiq/psicoverage/main'

workflow MAJIQ {

    take:

    ch_bam // channel: [ val(meta), [ bam ] ]
    ch_bai // channel: [ val(meta), [ bai ] ]
    ch_gff // channel: [ val(meta), [ gff ] ]

    main:

    ch_versions = Channel.empty()

    
    ch_license = Channel.fromPath(params.majiq_license, checkIfExists: true)

    ch_bam.view()

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

    //
    // MODULE: MAJIQ_BUILDSJ
    //
    /*
    MAJIQ_BUILDSJ(
        ch_bam,
        ch_gff
    )
    ch_versions = ch_versions.mix(MAJIQ_BUILDSJ.out.versions)
    */

    emit:
    versions = ch_versions                     // channel: [ versions.yml ]
}

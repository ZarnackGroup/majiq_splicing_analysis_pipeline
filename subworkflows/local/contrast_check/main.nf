//
// Check input contrastsheet and get read channels
// Adapted from nf-core/rnasplice - https://github.com/nf-core/rnasplice/blob/1.0.4/subworkflows/local/contrasts_check.nf
//

include { CONTRASTSHEET_CHECK } from '../../../modules/local/contrastsheet'

workflow CONTRASTS_CHECK {

    take:
    contrastsheet // file: /path/to/contrastsheet.csv

    main:
    CONTRASTSHEET_CHECK ( contrastsheet )
            .csv
            .splitCsv ( header:true, sep:',' )
            .set { ch_contrasts }


    emit:
    contrasts = ch_contrasts
    versions = CONTRASTSHEET_CHECK.out.versions // channel: [ versions.yml ]

}

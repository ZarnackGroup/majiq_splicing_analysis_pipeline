//
// Check input samplesheet and get read channels
// Adapted from nf-core/rnasplice - https://github.com/nf-core/rnasplice/blob/1.0.4/subworkflows/local/input_check.nf
//

include { SAMPLESHEET_CHECK } from '../../../modules/local/samplesheet'

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:


    SAMPLESHEET_CHECK ( samplesheet )
    .csv
    .splitCsv ( header:true, sep:',' )
    .map { create_genome_bam_channel(it) }
    .set { reads }





    emit:
    reads                                     // channel: [ val(meta), [ reads ] ]
    versions = SAMPLESHEET_CHECK.out.versions // channel: [ versions.yml ]

}

// Function to get list of [ meta, bam ]
def create_genome_bam_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.id         = row.sample
    meta.genome_bam = row.genome_bam
    meta.condition  = row.condition

    // add path(s) of the bam file(s) to the meta map
    def genome_bam_meta = []
    if (!file(row.genome_bam).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> genome bam file does not exist!\n${row.genome_bam}"
    }
    genome_bam_meta = [ meta, [ file(row.genome_bam) ] ]
    return genome_bam_meta
}

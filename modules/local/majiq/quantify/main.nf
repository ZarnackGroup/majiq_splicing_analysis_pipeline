process MAJIQ_QUANTIFY {
    tag "$condition"
    label 'process_low'
    secret 'MAJIQ_LICENSE'

    input:
    tuple val(condition), path(psicov), val(meta_splicegraph), path(splicegraph)          // channel: [ val(meta), path(s


    output:
    tuple val(condition), path("quantify/*.tsv"), emit: psi_tsv
    tuple val("${task.process}"), val('majiq'), eval('majiq --version | grep -oE "[0-9]+\\.[0-9]+\\.[0-9]+"'), emit: versions_majiq, topic: versions


    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${condition}"
    def majiqLicense = secrets.MAJIQ_LICENSE ?
        "export MAJIQ_LICENSE_FILE=\$(mktemp); echo -n \"\$MAJIQ_LICENSE\" >| \$MAJIQ_LICENSE_FILE; " :
        ""

    """

    $majiqLicense

    mkdir quantify

    majiq-v3 \\
        quantify \\
        --nthreads ${task.cpus} \\
        --output-tsv quantify/${prefix}.tsv \\
        ${psicov} \\
        --splicegraph $splicegraph \\
        $args

    """

    stub:
    """
    mkdir -p quantify
    echo -e "gene_id\\tpsi_value\\nGENE1\\t0.85\\nGENE2\\t0.92" > quantify/${condition}.psi.tsv

    """
}

process MAJIQ_PSICOVERAGE {
    tag "$condition"
    label 'process_single'
    secret 'MAJIQ_LICENSE'


    input:
    tuple val(condition), path(sj), val(meta_splicegraph), path(splicegraph)         // channel: [ val(meta), path(s



    output:

    tuple val(condition), path("psi-coverage/*.psicov"), emit: psi_coverage
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


    mkdir psi-coverage

    majiq \\
        psi-coverage \\
        --nthreads $task.cpus \\
        $splicegraph \\
        psi-coverage/${prefix}.psicov \\
        $sj \\
        $args

    """

    stub:
    """
    mkdir -p psi-coverage
    touch psi-coverage/${condition}.psicov

    """
}

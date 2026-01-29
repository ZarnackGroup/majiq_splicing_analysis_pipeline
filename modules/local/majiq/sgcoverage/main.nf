process MAJIQ_SGCOVERAGE {
    tag "$condition"
    label 'process_single'
    secret 'MAJIQ_LICENSE'

    input:

    tuple val(condition), path(sj_files), val(meta_splicegraph), path(splicegraph) // channel: [ splicegraph, condition, [ sj_files ] ]

    output:
    tuple val(condition), path("*.sgc"), emit: sgc_files
    tuple val("${task.process}"), val('majiq'), eval('majiq --version | grep -oE "[0-9]+\\.[0-9]+\\.[0-9]+"'), emit: versions_majiq, topic: versions


    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def majiqLicense = secrets.MAJIQ_LICENSE ?
        "export MAJIQ_LICENSE_FILE=\$(mktemp); echo -n \"\$MAJIQ_LICENSE\" >| \$MAJIQ_LICENSE_FILE; " :
        ""

    """

    $majiqLicense
    majiq-v3 \\
        sg-coverage \\
        $splicegraph \\
        ${condition}.sgc \\
        $sj_files \\
        --nthreads ${task.cpus} \\
        $args

    """

    stub:
    """
    mkdir -p sg-coverage
    echo "This is a stub .sgc file for ${condition}" > ${condition}.sgc

    """
}

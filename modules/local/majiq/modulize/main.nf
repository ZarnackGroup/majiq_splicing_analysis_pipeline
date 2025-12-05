process MAJIQ_MODULIZE {
    label 'process_high'
    secret 'MAJIQ_LICENSE'


    input:
    tuple path(voila_files), val(meta_splicegraph), path(splicegraph)

    output:
    path("modulize/*"), emit: modulize_files
    tuple val("${task.process}"), val('voila'), eval('voila --version | grep -oE "[0-9]+\\.[0-9]+\\.[0-9]+"'), emit: versions_majiq, topic: versions


    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def majiqLicense = secrets.MAJIQ_LICENSE ?
        "export MAJIQ_LICENSE_FILE=\$(mktemp); echo -n \"\$MAJIQ_LICENSE\" >| \$MAJIQ_LICENSE_FILE; " :
        ""

    """

    $majiqLicense

    mkdir modulize

    voila \\
        modulize \\
        $splicegraph \\
        $voila_files \\
        --logger module.logger.txt \\
        --directory modulize \\
        --nproc ${task.cpus} \\
        $args

    """

    stub:
    """
    mkdir -p modulize
    touch modulize/dummy_output.txt
    echo "This is a stub log file" > modulize/module.logger.txt

    """
}

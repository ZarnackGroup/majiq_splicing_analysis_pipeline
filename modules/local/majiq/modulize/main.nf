process MAJIQ_MODULIZE {
    label 'process_high'
    secret 'MAJIQ_LICENSE'


    input:
    tuple path(voila_files), val(meta_splicegraph), path(splicegraph)

    output:
    path("modulize/*"), emit: modulize_files
    path "versions.yml"           , emit: versions

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

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: \$(majiq --version)
    END_VERSIONS
    """

    stub:
    """
    mkdir -p modulize
    touch modulize/dummy_output.txt
    echo "This is a stub log file" > modulize/module.logger.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: "stub-version"
    END_VERSIONS
    """
}

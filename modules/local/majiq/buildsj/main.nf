process MAJIQ_BUILDSJ {
    tag "$meta.id"
    label 'process_single'
    secret 'MAJIQ_LICENSE'


    input:
    tuple(
        val(meta),
        path(bam),
        val(meta_splicegraph),
        path(splicegraph)
        )



    output:
    tuple val(meta), path("build/sj/*.sj") , emit: sj
    tuple val("${task.process}"), val('majiq'), eval('majiq --version | grep -oE "[0-9]+\\.[0-9]+\\.[0-9]+"'), emit: versions_majiq, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def majiqLicense = secrets.MAJIQ_LICENSE ?
        "export MAJIQ_LICENSE_FILE=\$(mktemp); echo -n \"\$MAJIQ_LICENSE\" >| \$MAJIQ_LICENSE_FILE; " :
        ""

    """

    $majiqLicense

    mkdir build

    mkdir build/sj

    majiq-build \\
        sj \\
        --nthreads $task.cpus \\
        $bam \\
        $splicegraph \\
        build/sj/${prefix}.sj \\
        --strandness AUTO \\
        $args \\

    """

    stub:
        def prefix = task.ext.prefix ?: "${meta.id}"
        """
        mkdir -p build/sj
        echo "Stub splice junction content" > build/sj/${prefix}.sj

        """
}

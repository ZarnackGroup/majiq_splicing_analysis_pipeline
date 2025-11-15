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
    path "versions.yml"           , emit: versions

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


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: $(majiq --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    END_VERSIONS
    """

    stub:
        def prefix = task.ext.prefix ?: "${meta.id}"
        """
        mkdir -p build/sj
        echo "Stub splice junction content" > build/sj/${prefix}.sj

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            majiq: "stub-version"
        END_VERSIONS
        """
}

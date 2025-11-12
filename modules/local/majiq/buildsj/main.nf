process MAJIQ_BUILDSJ {
    tag "$meta.id"
    label 'process_single'


    input:
    tuple(
        val(meta),
        path(bam),
        val(meta_splicegraph),
        path(splicegraph),
        path(license)
        )



    output:
    tuple val(meta), path("build/sj/*.sj") , emit: sj
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """

    mkdir build

    mkdir build/sj

    majiq-build \\
        sj \\
        --license $license \\
        --nthreads $task.cpus \\
        $bam \\
        $splicegraph \\
        build/sj/${prefix}.sj \\
        --strandness AUTO \\
        $args \\


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: \$(majiq --version)
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

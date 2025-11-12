process MAJIQ_BUILDGFF3 {
    tag "$meta.id"
    label 'process_single'



    input:
    tuple val(meta), path(gff)
    path license

    output:

    tuple val(meta), path("splicegraph.zarr"), emit: splicegraph
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"


    """
    majiq-build \\
        gff3 \\
        --license $license \\
        $gff \\
        splicegraph.zarr \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: \$(majiq --version)
    END_VERSIONS
    """

   stub:
        def prefix = task.ext.prefix ?: "${meta.id}"
        """
        mkdir -p splicegraph.zarr
        echo "Stub splicegraph content" > splicegraph.zarr/dummy_file.txt

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            majiq: "stub-version"
        END_VERSIONS
        """
}

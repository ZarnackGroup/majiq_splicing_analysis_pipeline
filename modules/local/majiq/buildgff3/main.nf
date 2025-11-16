process MAJIQ_BUILDGFF3 {
    tag "$meta.id"
    label 'process_single'
    secret 'MAJIQ_LICENSE'



    input:
    tuple val(meta), path(gff)


    output:

    tuple val(meta), path("splicegraph.zarr"), emit: splicegraph
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

    majiq-build \\
        gff3 \\
        $gff \\
        splicegraph.zarr \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: \$(majiq --version | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
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

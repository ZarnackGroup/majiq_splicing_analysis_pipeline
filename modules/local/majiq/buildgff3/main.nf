process MAJIQ_BUILDGFF3 {
    tag "$meta.id"
    label 'process_single'
    secret 'MAJIQ_LICENSE'



    input:
    tuple val(meta), path(gff)


    output:

    tuple val(meta), path("splicegraph.zarr"), emit: splicegraph
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

    majiq-build \\
        gff3 \\
        $gff \\
        splicegraph.zarr \\
        $args


    """

   stub:
        def prefix = task.ext.prefix ?: "${meta.id}"
        """
        mkdir -p splicegraph.zarr
        echo "Stub splicegraph content" > splicegraph.zarr/dummy_file.txt

        """
}

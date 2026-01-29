process MAJIQ_BUILDUPDATE {
    tag "$meta.id"
    label 'process_low'
    secret 'MAJIQ_LICENSE'



    input:
    path(sj)
    tuple val(meta),path(splicegraph)
    val list_conditions

    output:
    tuple val(meta), path("./build/splicegraph.zarr"), emit: splicegraph
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

    # create experiments.tsv
    echo -e "sj\\tgroup" > config.tsv # header

    # bring the list of files and conditions into the TSV
    echo "$list_conditions" \\
    | sed 's/], /\\n/g' \\
    | sed 's/\\[\\|\\]//g' \\
    | sed 's/, /\\t/g' \\
    >> config.tsv


    majiq-build \\
        update \\
        --nthreads $task.cpus \\
        --groups-tsv config.tsv \\
        $splicegraph \\
        ./build/splicegraph.zarr \\
        $args \\

    """

    stub:
    """
    mkdir -p build
    touch build/splicegraph.zarr

    """
}

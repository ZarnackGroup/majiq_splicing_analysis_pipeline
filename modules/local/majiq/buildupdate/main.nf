process MAJIQ_BUILDUPDATE {
    tag "$meta.id"
    label 'process_low'



    input:
    path(sj)
    tuple val(meta),path(splicegraph)
    path license
    val list_conditions

    output:
    tuple val(meta), path("./build/splicegraph.zarr"), emit: splicegraph
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
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
        --license $license \\
        --nthreads $task.cpus \\
        --groups-tsv config.tsv \\
        $splicegraph \\
        ./build/splicegraph.zarr \\
        $args \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: \$(majiq --version)
    END_VERSIONS
    """

    stub:
    """
    mkdir -p build
    touch build/splicegraph.zarr

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: "stub-version"
    END_VERSIONS
    """
}

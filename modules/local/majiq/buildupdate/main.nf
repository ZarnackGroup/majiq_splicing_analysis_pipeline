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
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    // TODO nf-core: If the module doesn't use arguments ($args), you SHOULD remove:
    //               - The definition of args `def args = task.ext.args ?: ''` above.
    //               - The use of the variable in the script `echo $args ` below.
    """
    echo $args

    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: \$(majiq --version)
    END_VERSIONS
    """
}

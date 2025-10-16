process MAJIQ_DELTAPSI {
    tag "$contrast"
    label 'process_medium'



    input:
    tuple val(contrast), val(treatment), val(control), path(treatment_files), path(control_files), path(splicegraph),  path(license)  // channel: [ contrast, treatment, control ]
    // channel: [ val(meta), path(splicegraph) ]


    output:

    path("deltapsi/${contrast}.deltapsi.tsv") , emit: deltapsi_tsv
    path("deltapsi/${contrast}.dpsicov")      , emit: dpsicov
    path "deltapsi/${contrast}.deltapsi.logger.txt"               , emit: logger
    path "versions.yml"                      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    //def prefix = task.ext.prefix ?: "${meta.id}"
    """

    mkdir deltapsi

    majiq \\
        deltapsi \\
        --license $license \\
        --nthreads ${task.cpus} \\
        --splicegraph $splicegraph \\
        -psi1 $control_files \\
        -psi2 $treatment_files \\
        --names $treatment $control  \\
        --output-tsv deltapsi/${contrast}.deltapsi.tsv \\
        --logger deltapsi/${contrast}.deltapsi.logger.txt \\
        --output-voila deltapsi/${contrast}.dpsicov \\
        --debug \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: \$(majiq --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    //def prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    // TODO nf-core: If the module doesn't use arguments ($args), you SHOULD remove:
    //               - The definition of args `def args = task.ext.args ?: ''` above.
    //               - The use of the variable in the script `echo $args ` below.
    """
    echo $args



    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: \$(majiq --version)
    END_VERSIONS
    """
}

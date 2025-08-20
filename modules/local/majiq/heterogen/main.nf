process MAJIQ_HETEROGEN {
    tag "$contrast"
    label 'process_medium'

    container "/storage/zar/shared/apptainer_images/majiq_v3_0_6.sif"


    input:
    tuple val(contrast), val(treatment), val(control), path(treatment_files), path(control_files), path(splicegraph),  path(license)  // channel: [ contrast, treatment, control ]


    output:

    path("heterogen/${contrast}.heterogen.tsv") , emit: heterogen_tsv
    path("heterogen/${contrast}.hetcov")        , emit: hetcov
    path "heterogen/${contrast}.heterogen.logger.txt"                , emit: logger
    path "versions.yml"                        , emit: versions


    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    //def prefix = task.ext.prefix ?: "${meta.id}"

    """

    mkdir heterogen

    majiq \\
        heterogen \\
        --license $license \\
        --nthreads ${task.cpus} \\
        --splicegraph $splicegraph \\
        -psi1 $treatment_files \\
        -psi2 $control_files \\
        --names $treatment $control  \\
        --output-tsv heterogen/${contrast}.heterogen.tsv \\
        --logger heterogen/${contrast}.heterogen.logger.txt \\
        --output-voila heterogen/${contrast}.hetcov \\
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

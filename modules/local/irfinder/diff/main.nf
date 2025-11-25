
process IRFINDER_DIFF {
    tag "$contrast"
    label 'process_medium'

    container "docker://cloxd/irfinder:2.0"

    input:
    tuple val(contrast), val(treatment), val(control), path(treatment_files), path(control_files)

    output:
    tuple val(contrast), path("diff/${contrast}"), emit: dif_results
    tuple val("${task.process}"), val('IRFinder'), eval("IRFinder --version"), topic: versions, emit: versions_irfinder

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    // Collect all control file paths 
    def control_files_list = control_files.collect { dir -> "./${dir}/IRFinder-IR-nondir.txt" }.join(' ')
    // Collect all treatment file paths 
    def treatment_files_list = treatment_files.collect { dir -> "./${dir}/IRFinder-IR-nondir.txt" }.join(' ')

    """
    mkdir -p "diff/${contrast}"

    IRFinder Diff \\
        -g:"${control}" ${control_files_list} \\
        -g:"${treatment}" ${treatment_files_list} \\
        $args \\
        -v \\
        -o "diff/${contrast}"  
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
    """
}

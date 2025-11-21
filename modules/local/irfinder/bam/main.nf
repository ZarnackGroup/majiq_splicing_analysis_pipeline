
process IRFINDER_BAM {
    tag "$meta.id"
    label 'process_high'

    container "docker://cloxd/irfinder:2.0"

    input:
    tuple val(meta), path(bam)
    path(ir_finder_reference)

    output:
    tuple val(meta), path("*.txt"), emit: bam
    tuple val("${task.process}"), val('IRFinder'), eval("IRFinder --version"), topic: versions, emit: versions_irfinder

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    IRFinder \\
        BAM \\
        -r $ir_finder_reference \\
        $args \\
        -t ${task.cpus} \\
        $bam
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch IRFinder-ChrCoverage.txt
    """
}

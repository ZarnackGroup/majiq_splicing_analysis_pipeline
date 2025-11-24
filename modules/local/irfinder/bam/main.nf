
process IRFINDER_BAM {
    tag "$meta.id"
    label 'process_high'

    container "docker://cloxd/irfinder:2.0"

    input:
    tuple val(meta), path(bam)
    path(ir_finder_reference)

    output:
    tuple val(meta), path("${meta.id}"), emit: bam
    tuple val(meta), path("${meta.id}/IRFinder-IR-nondir.txt"), emit: irfinder_nondir
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
        -d ${prefix} \\
        -t ${task.cpus} \\
        $bam
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch IRFinder-ChrCoverage.txt
    """
}


process IRFINDER_BAM {
    tag "$meta.id"
    label 'process_high'

    container "docker.io/cloxd/irfinder:2.0"
    containerOptions {
        workflow.containerEngine == 'docker' ? '--entrypoint=""' : ''
    }

    input:
    tuple val(meta), path(bam)
    path(ir_finder_reference)

    output:
    tuple val(meta), path("${meta.id}/"), emit: irfinder_bam_directory
    tuple val("${task.process}"), val('IRFinder'), eval("IRFinder --version | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+' | tail -n1"), topic: versions, emit: versions_irfinder

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


process IRFINDER_BUILDREFPROCESS {
    tag "$meta.id"
    label 'process_high'

    container "docker://cloxd/irfinder:2.0"

    input:
    tuple val(meta), path(gtf)
    path fasta

    output:
    
    tuple val(meta), path("REF/${meta.id}"), emit: ir_finder_reference
    
    tuple val("${task.process}"), val('IRFinder'), eval("IRFinder --version | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+' | tail -n1"), topic: versions, emit: versions_irfinder

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """

    mkdir -p REF/${prefix}


    mv $fasta REF/${prefix}/genome.fa
    mv $gtf REF/${prefix}/transcripts.gtf

    

    IRFinder BuildRefProcess \\
        -r REF/${prefix} \\
        $args \\
        -t ${task.cpus}
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    
    mkdir -p REF/${prefix}
    touch REF/${prefix}/genome.fa
    touch REF/${prefix}/transcripts.gtf
    

    """
}

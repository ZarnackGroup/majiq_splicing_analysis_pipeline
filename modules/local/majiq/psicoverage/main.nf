process MAJIQ_PSICOVERAGE {
    tag "$meta.id"
    label 'process_single'


    input:
    tuple val(meta), path(sj), val(meta_splicegraph), path(splicegraph), path (license)           // channel: [ val(meta), path(s



    output:

    tuple val(meta), path("psi-coverage/*.psicov"), emit: psi_coverage
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """

    mkdir psi-coverage

    majiq \\
        psi-coverage \\
        --license $license \\
        --nthreads $task.cpus \\
        $splicegraph \\
        psi-coverage/${prefix}.psicov \\
        $sj \\
        $args


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: \$(majiq --version)
    END_VERSIONS
    """

    stub:
    """
    mkdir -p psi-coverage
    touch psi-coverage/${meta.id}.psicov

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: "stub-version"
    END_VERSIONS
    """
}

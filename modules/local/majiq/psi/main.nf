process MAJIQ_PSI {
    tag "$meta.id"
    label 'process_low'
    secret 'MAJIQ_LICENSE'

    input:
    tuple val(meta), path(psicov), val(meta_splicegraph), path(splicegraph)          // channel: [ val(meta), path(s


    output:
    tuple val(meta), path("psi/*.psi.tsv"), emit: psi_tsv
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def majiqLicense = secrets.MAJIQ_LICENSE ?
        "export MAJIQ_LICENSE_FILE=\$(mktemp); echo -n \"\$MAJIQ_LICENSE\" >| \$MAJIQ_LICENSE_FILE; " :
        ""

    """

    $majiqLicense

    mkdir psi

    majiq \\
        psi \\
        --nthreads ${task.cpus} \\
        --output-tsv psi/${prefix}.psi.tsv \\
        ${psicov} \\
        --splicegraph $splicegraph \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: \$(majiq --version | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
    END_VERSIONS
    """

    stub:
    """
    mkdir -p psi
    echo -e "gene_id\\tpsi_value\\nGENE1\\t0.85\\nGENE2\\t0.92" > psi/${meta.id}.psi.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: "stub-version"
    END_VERSIONS
    """
}

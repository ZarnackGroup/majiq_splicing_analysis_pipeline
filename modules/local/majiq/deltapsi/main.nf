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
        --names $control $treatment \\
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
    """
    mkdir -p deltapsi
    echo -e "gene_id\\tdeltapsi_value\\nGENE1\\t0.5\\nGENE2\\t-0.3" > deltapsi/${contrast}.deltapsi.tsv
    touch deltapsi/${contrast}.dpsicov
    echo "This is a stub log file for ${contrast}" > deltapsi/${contrast}.deltapsi.logger.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: "stub-version"
    END_VERSIONS
    """
}

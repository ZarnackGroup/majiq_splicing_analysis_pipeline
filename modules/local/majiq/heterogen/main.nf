process MAJIQ_HETEROGEN {
    tag "$contrast"
    label 'process_medium'
    secret 'MAJIQ_LICENSE'



    input:
    tuple val(contrast), val(treatment), val(control), path(treatment_files), path(control_files), path(splicegraph)  // channel: [ contrast, treatment, control ]


    output:

    path("heterogen/${contrast}.heterogen.tsv") , emit: heterogen_tsv
    path("heterogen/${contrast}.hetcov")        , emit: hetcov
    path "heterogen/${contrast}.heterogen.logger.txt"                , emit: logger
    path "versions.yml"                        , emit: versions


    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def majiqLicense = secrets.MAJIQ_LICENSE ?
        "export MAJIQ_LICENSE_FILE=\$(mktemp); echo -n \"\$MAJIQ_LICENSE\" >| \$MAJIQ_LICENSE_FILE; " :
        ""

    """

    $majiqLicense

    mkdir heterogen

    majiq \\
        heterogen \\
        --nthreads ${task.cpus} \\
        --splicegraph $splicegraph \\
        -psi1 $control_files \\
        -psi2 $treatment_files \\
        --names $treatment $control  \\
        --output-tsv heterogen/${contrast}.heterogen.tsv \\
        --logger heterogen/${contrast}.heterogen.logger.txt \\
        --output-voila heterogen/${contrast}.hetcov \\
        --debug \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: \$(majiq --version | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+')
    END_VERSIONS
    """

    stub:
    """
    mkdir -p heterogen
    echo -e "gene_id\\theterogen_value\\nGENE1\\t0.8\\nGENE2\\t0.6" > heterogen/${contrast}.heterogen.tsv
    touch heterogen/${contrast}.hetcov
    echo "This is a stub log file" > heterogen/${contrast}.heterogen.logger.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: "stub-version"
    END_VERSIONS
    """
}

process MAJIQ_SGCOVERAGE {
    tag "$condition"
    label 'process_single'

    input:

    tuple val(condition), path(sj_files), val(meta_splicegraph), path(splicegraph),  path(license) // channel: [ splicegraph, condition, [ sj_files ] ]

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(condition), path("*.sgc"), emit: sgc_files
    // TODO nf-core: List additional required output channels/values here
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    //def prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: Where possible, a command MUST be provided to obtain the version number of the software e.g. 1.10
    //               If the software is unable to output a version number on the command-line then it can be manually specified
    //               e.g. https://github.com/nf-core/modules/blob/master/modules/nf-core/homer/annotatepeaks/main.nf
    //               Each software used MUST provide the software name and version number in the YAML version file (versions.yml)
    // TODO nf-core: It MUST be possible to pass additional parameters to the tool as a command-line string via the "task.ext.args" directive
    // TODO nf-core: If the tool supports multi-threading then you MUST provide the appropriate parameter
    //               using the Nextflow "task" variable e.g. "--threads $task.cpus"
    // TODO nf-core: Please replace the example samtools command below with your module's command
    // TODO nf-core: Please indent the command appropriately (4 spaces!!) to help with readability ;)
    """
    majiq-v3 \\
        sg-coverage \\
        --license $license \\
        $splicegraph \\
        ${condition}.sgc \\
        $sj_files \\
        --nthreads ${task.cpus} \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: \$(majiq --version)
    END_VERSIONS
    """

    stub:
    """
    mkdir -p sg-coverage
    echo "This is a stub .sgc file for ${condition}" > ${condition}.sgc

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        majiq: "stub-version"
    END_VERSIONS
    """
}

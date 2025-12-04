
process IRFINDER_DIFF {
    tag "$contrast"
    label 'process_medium'

    container "docker.io/cloxd/irfinder:2.0"
    containerOptions {
        workflow.containerEngine == 'docker' ? '--entrypoint=""' : ''
    }

    input:
    tuple val(contrast), val(treatment), val(control), path(treatment_files), path(control_files)

    output:
    tuple val(contrast), path("diff/${contrast}"), emit: diff_results
    tuple val("${task.process}"), val('IRFinder'), eval("IRFinder --version | grep -oE '[0-9]+\\.[0-9]+\\.[0-9]+' | tail -n1"), topic: versions, emit: versions_irfinder

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

    """

    mkdir -p "diff/${contrast}"
    """
}

// Adapted from nf-core/rnasplice -  https://github.com/nf-core/rnasplice/blob/1.0.4/modules/local/contrastsheet_check.nf


process CONTRASTSHEET_CHECK {
    tag "$contrastsheet"
    label 'process_single'

    conda "conda-forge::python=3.9.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'biocontainers/python:3.9--1' }"

    input:
    path contrastsheet

    output:
    path '*.csv'       , emit: csv
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script: // This script is bundled with the pipeline, in nf-core/rnasplice/bin/

    """
    check_contrastsheet.py $contrastsheet contrastsheet.valid.csv
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """

}
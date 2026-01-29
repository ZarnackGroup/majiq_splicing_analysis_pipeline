
include { QUARTONOTEBOOK as QUARTONOTEBOOK_DELTAPSI } from '../../../modules/nf-core/quartonotebook/main'

workflow DOWNSTREAM_ANALYSIS {

    take:
    deltapsi_modulize         // channel: [meta, files]

    main:

    ch_versions = channel.empty()

     // Add metadata to the directory
    ch_with_meta = deltapsi_modulize
        .map { modulize_dir ->
            def meta = [id: 'majiq_deltapsi_modulize_report']
            tuple(meta, modulize_dir)
        }

    // Prepare the Quarto notebook template
    ch_notebook_template = file("${projectDir}/assets/quarto/majiq_deltapsi_modulize_report.qmd", checkIfExists: true)

    // Input 1: tuple val(meta), path(notebook)
    ch_meta_notebook = ch_with_meta
        .map { meta, modulize_dir ->
            tuple(meta, ch_notebook_template)
        }

    // Input 2: val(parameters)
    ch_parameters = ch_with_meta
        .map { meta, modulize_dir ->
            [
                sample_id: meta.id,
                modulize_dir: modulize_dir.name,
                artifact_dir: "tables",
                analysis_date: new Date().format('yyyy-MM-dd'),
                output_prefix: meta.id
            ]
        }

    // Input 3: path(input_files) - pass the directory
    ch_input_files = ch_with_meta
        .map { meta, modulize_dir -> modulize_dir }

    // Input 4: path(extensions) - empty list
    ch_extensions = ch_with_meta
        .map { meta, modulize_dir -> [] }

    // Run QUARTONOTEBOOK
    QUARTONOTEBOOK_DELTAPSI (
        ch_meta_notebook,
        ch_parameters,
        ch_input_files,
        ch_extensions
    )

    // Extract the overview_table.tsv from the artifacts output
    ch_overview_table = QUARTONOTEBOOK_DELTAPSI.out.artifacts
        .map { meta, artifacts ->
            // Handle both single file and list of files
            def tsv_file = artifacts.find { it.name == 'overview_table_mqc.tsv' }
            tuple(meta, tsv_file)
        }

    ch_versions = QUARTONOTEBOOK_DELTAPSI.out.versions

    emit:
    ch_versions = ch_versions
    ch_deltapsi_table = ch_overview_table
}

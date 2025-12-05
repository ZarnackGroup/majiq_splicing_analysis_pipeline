
include { QUARTONOTEBOOK as QUARTONOTEBOOK_DELTAPSI } from '../../../modules/nf-core/quartonotebook/main'

workflow DOWNSTREAM_ANALYSIS {

    take:
    deltapsi_modulize         // channel: [meta, files]

    main:
    
     // Add metadata to the directory
    ch_with_meta = deltapsi_modulize
        .map { modulize_dir ->
            def meta = [id: 'deltapsi_analysis']
            tuple(meta, modulize_dir)
        }
    
    // Prepare the Quarto notebook template
    ch_notebook_template = file("${projectDir}/assets/quarto/deltapsi_report.qmd", checkIfExists: true)
    
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
                artifact_dir: "artifacts",
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
    
    emit:
    deltapsi_params_yml = QUARTONOTEBOOK_DELTAPSI.out.params_yaml
}
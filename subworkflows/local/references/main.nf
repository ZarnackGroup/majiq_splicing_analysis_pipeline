include { AGAT_CONVERTSPGXF2GXF  } from '../../../modules/nf-core/agat/convertspgxf2gxf/main'
include { AGAT_CONVERTGFF2BED    } from '../../../modules/nf-core/agat/convertgff2bed/main'
include { AGAT_CONVERTSPGFF2GTF  } from '../../../modules/nf-core/agat/convertspgff2gtf/main'     
include { GUNZIP as GUNZIP_ANNOTATION                 } from '../../../modules/nf-core/gunzip/main'
include { GUNZIP as GUNZIP_GENOME                     } from '../../../modules/nf-core/gunzip/main'

workflow REFERENCES {

    take:
    ch_annotation_input // channel: [ val(meta), path(annotation) ]
    ch_genome_input     // channel: [ val(meta), path(genome) ]
    
    main:
    ch_versions = Channel.empty()

    //
    // Branch annotation based on compression
    //
    ch_annotation_input
        .branch { meta, file ->
            compressed: file.name.endsWith('.gz')
                return [ meta, file ]
            uncompressed: true
                return [ meta, file ]
        }
        .set { annotation_branched }

    //
    // MODULE: GUNZIP ANNOTATION
    //
    ch_annotation_decompressed = GUNZIP_ANNOTATION( annotation_branched.compressed ).gunzip
    ch_versions = ch_versions.mix(GUNZIP_ANNOTATION.out.versions.first())

    // Combine decompressed and already uncompressed
    ch_annotation = ch_annotation_decompressed.mix(annotation_branched.uncompressed)

    //
    // Branch annotation based on format
    //
    ch_annotation
        .branch { meta, file ->
            gtf: file.name.endsWith('.gtf')
                return [ meta, file ]
            gff3: file.name.endsWith('.gff3') || file.name.endsWith('.gff')
                return [ meta, file ]
            other: true
                return [ meta, file ]
        }
        .set { annotation_format }

    //
    // MODULE: AGAT_CONVERTSPGXF2GXF (GTF to GFF3)
    //
    ch_gff3_converted = AGAT_CONVERTSPGXF2GXF( annotation_format.gtf ).output_gff
    ch_versions = ch_versions.mix(AGAT_CONVERTSPGXF2GXF.out.versions.first())

    //
    // MODULE: AGAT_CONVERTSPGFF2GTF (GFF3 to GTF)
    //
    ch_gtf_converted = AGAT_CONVERTSPGFF2GTF( annotation_format.gff3 ).output_gtf
    ch_versions = ch_versions.mix(AGAT_CONVERTSPGFF2GTF.out.versions.first())

    // Combine GTF outputs: original GTF + converted from GFF3
    ch_gtf = annotation_format.gtf.mix(ch_gtf_converted)

    // Combine GFF3 outputs: original GFF3 + converted from GTF
    ch_gff3 = annotation_format.gff3.mix(ch_gff3_converted)

    //
    // MODULE: AGAT_CONVERTGFF2BED
    //
    ch_bed = AGAT_CONVERTGFF2BED( ch_gff3 ).bed
    ch_versions = ch_versions.mix(AGAT_CONVERTGFF2BED.out.versions.first())

    //
    // Branch genome based on compression
    //
    ch_genome_input
        .branch { meta, file ->
            compressed: file.name.endsWith('.gz')
                return [ meta, file ]
            uncompressed: true
                return [ meta, file ]
        }
        .set { genome_branched }

    //
    // MODULE: GUNZIP GENOME
    //
    ch_genome_decompressed = GUNZIP_GENOME( genome_branched.compressed ).gunzip
    ch_versions = ch_versions.mix(GUNZIP_GENOME.out.versions.first())

    // Combine decompressed and already uncompressed
    ch_genome = ch_genome_decompressed.mix(genome_branched.uncompressed)

    emit:
    gtf              = ch_gtf                // channel: [ val(meta), [ path(gtf)    ] ]
    gff3             = ch_gff3               // channel: [ val(meta), [ path(gff3)   ] ]
    bed              = ch_bed                // channel: [ val(meta), [ path(bed)    ] ]
    genome_fasta     = ch_genome             // channel: [ val(meta), [ path(fasta)  ] ]
    versions         = ch_versions           // channel: version information
}

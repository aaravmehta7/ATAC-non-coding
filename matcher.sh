#!/bin/bash

fimo --motif ATGTTGSCCAGGCTGGTCTYGAACTCCT --text --thresh 1e-16 top_50K_motifs/meme.txt top_50K_peaks.fa > fimo_results_7_GENE.txt #replce with real motif and fimo number

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <fimo_file>"
    exit 1
fi

# Input files
fimo_file="$1"                              # FIMO file as input
matcher_file="./fimo_results_old/ensg_to_gene.txt"  # Matcher file (ENSG to gene name mapping)
sequences_file="noncoding_genomic_transcripts.fa"   # Sequence file with ENSG IDs in headers
output_file="genes_list.txt"                # Output file for gene names


if [[ ! -f "$fimo_file" || ! -f "$matcher_file" || ! -f "$sequences_file" ]]; then
    echo "Error: One or more input files are missing."
    exit 1
fi

# Extract transcript IDs (ENSTs) from the FIMO file
awk '{print $3}' "$fimo_file" | sort -u > fimo_transcripts.txt
echo "DEBUG: Extracted transcript IDs:"
cat fimo_transcripts.txt

# Map transcripts (ENSTs) to ENSG IDs using the sequence file
> ensg_ids.txt  # Initialize ENSG output
while read enst; do
    # Debug: Current ENST being processed
    echo "DEBUG: Processing transcript: $enst"
    
    # Find ENSG ID corresponding to the ENST in the sequence file
    ensg=$(grep -m 1 ">$enst" "$sequences_file" | awk '{for (i=1; i<=NF; i++) if ($i ~ /ENSG/) {print $i; exit}}' | cut -d'.' -f1)
    
    # Debug: ENSG found
    echo "DEBUG: Found ENSG for $enst: $ensg"
    
    if [[ -n "$ensg" ]]; then
        echo "$ensg" >> ensg_ids.txt
    else
        echo "DEBUG: No ENSG found for transcript: $enst"
    fi
done < fimo_transcripts.txt

# Deduplicate the list of ENSG IDs
sort -u ensg_ids.txt -o ensg_ids.txt
echo "DEBUG: Extracted ENSG IDs:"
cat ensg_ids.txt


> "$output_file"  
while read ensg; do
   
    echo "DEBUG: Processing ENSG: $ensg"
    
    
    gene_name=$(grep "$ensg" "$matcher_file" | awk '{print $2}')
    
    # Debug: Gene name found
    if [[ -n "$gene_name" ]]; then
        echo "DEBUG: Found gene name for $ensg: $gene_name"
        echo "$gene_name" >> "$output_file"
    else
        echo "DEBUG: No gene name found for ENSG: $ensg"
    fi
done < ensg_ids.txt


sort -u "$output_file" -o "$output_file"
echo "DEBUG: Final gene list:"
cat "$output_file"


rm fimo_transcripts.txt ensg_ids.txt

echo "Gene list generated: $output_file"

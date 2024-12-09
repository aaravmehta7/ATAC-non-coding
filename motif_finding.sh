sort -k5nr BRCA_peakCalls.txt > sorted_peaks.txt
head -n 50000 sorted_peaks.txt > top_peaks.txt
awk '{print $1"\t"$2"\t"$3"\t"$4}' top_peaks.txt > top_50K_peaks.bed
meme top_50K_peaks.fa -dna -mod zoops -nmotifs 20 -o top_50K_motifs

#ChIP-seq - in-silico spike-in free method 

#Reference
#https://github.com/stjude/ChIPseqSpikeInFree

#load libraries
library(devtools)
install_github("stjude/ChIPseqSpikeInFree")
library("ChIPseqSpikeInFree")

#read in sample details
metaFile <- "sample_meta_h3k4me3.txt"
#read in bam files
bams = c("H3K4me3_WT_n1.bam","H3K4me3_WT_n2.bam","H3K4me3_WT_n3.bam","H3K4me3_PreM_n1.bam","H3K4me3_PreM_n2.bam","H3K4me3_PreM_n3.bam","H3K4me3_Mal_n1.bam","H3K4me3_Mal_n2.bam","H3K4me3_Mal_n3.bam")

#run the analysis
#exclude X, Y, MT and rDNA
ChIPseqSpikeInFree(bamFiles = bams, chromFile = "genome.chrom.edited.sizes", metaFile = metaFile, prefix = "h3k4me3-1-19-only")



# ChIP-seq-spikein

This repository details the modifications to the standard ChIP-seq data analysis workflow to incorporate scaling factors where a global change in specific factor/modification is observed across different conditions. 

The scaling factors were calculated either based on an external spike-in control or an in-silico based approach. 

### Method 1 - ChIP-seq external spike-in normalisation

Egan *et al*. (2016) have described an external spike-in normalisation approach where a chromatin from a second species       
(e.g. *Drosophila melanogaster*) is added together with an antibody that identifies *D. melanogaster* specific histone variant 
H2Av to all ChIP samples prior to immunoprecipitation. 

The amount of spike-in chromatin and antibody added are adjusted based on the amount of experimental chromatin and kept constant for each target across different conditions. 


#### Schematic representation of the ChIP-seq spike-in protocol (Egan *et al*., 2016)


<img width="400" alt="Screen Shot 2022-01-25 at 10 50 52 pm" src="https://user-images.githubusercontent.com/36429476/150971942-31770056-1186-4eaa-8d98-a44c486d54af.png">



Reference: 

1. Egan, B. *et al*. (2016). An Alternative Approach to ChIP-Seq Normalization Enables Detection of Genome-Wide Changes in Histone H3 Lysine 27 Trimethylation upon EZH2 Inhibition. PloS one, 11(11), e0166438. https://doi.org/10.1371/journal.pone.0166438

2. Active motif - https://www.activemotif.com/catalog/1091/chip-normalization


The following workflow illustrates the ChIP-seq external spike-in normalisation approach. 


<img width="600" alt="Screen Shot 2022-01-14 at 2 51 22 am" src="https://user-images.githubusercontent.com/36429476/149363171-f86dff2a-c626-4833-9d68-b8ff5ab6f60c.png">


#### Extract unmapped reads from the initial alignment to mouse reference genome

1. Extract unmapped reads from the bam file - Samtools

```console
samtools view -b -f 4 sample_01_sorted.bam > sample_01_unmapped.bam
```

2. Convert unmapped reads to fastq format - Samtools

```console
samtools fastq -1 sample_01_unmapped_R1.fastq -2 sample_01_unmapped_R2.fastq sample_01_unmapped.bam
```

3. Repair paired-end reads if necessary - BBMap

```console
repair.sh in=sample_01_unmapped_R1.fastq in2=sample_01_unmapped_R2.fastq out1=s01_unmapped_fixed_R1.fastq out2=s01_unmapped_fixed_R2.fastq
```

#### Alignment to the spike-in (Drosophila) genome

4. Align the reads to spike in genome using local alignment mode in Bowtie2.

```console
bowtie2 -x ref_genome -1 s01_unmapped_R1.fastq -2 s01_unmapped_R2.fastq -S s01_spikein.sam --local 
--very-sensitive-local --no-mixed --no-discordant --phred33 --no-unal
```

#### Calculation of scaling factors 
- Scaling factors (SF) are calculated based on the number of uniquely aligned reads to spike in genome in each sample and separately for each factor of interest or input control. 

```console
SF = number of reads in sample 01 / number of reads in reference sample
```

- reference is the sample with lowest number of reads aligned to spike-in genome 


### Method 2- ChIP-seq in-silico spike-in free normalisation

ChIPseqSpikeInFree is an in-silico normalisation method that does not rely on exogenous spike-in material and does not require any modifications to the ChIP-seq experimental protocol. This method relies on the enrichment signal of samples across the genome for calculating normalisation factors and can also be used to detect the complete loss of enrichment or ChIP failure indicated by poor enrichment (Jin *et al*. 2019).

Reference: 

1. Jin, H. *et al*. (2020). ChIPseqSpikeInFree: a ChIP-seq normalization approach to reveal global changes in histone modifications without spike-in. Bioinformatics (Oxford, England), 36(4), 1270–1272. https://doi.org/10.1093/bioinformatics/btz720

2. Github repository of R bioconductor package - https://github.com/stjude/ChIPseqSpikeInFree

<img width="600" alt="Screen Shot 2022-01-14 at 2 51 51 am" src="https://user-images.githubusercontent.com/36429476/149363181-711a649c-b0aa-45ad-a8d3-681c5593d127.png">

#### Example R script

```R
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
```

#### Example output 


<img width="500" alt="Screen Shot 2022-01-26 at 2 32 41 am" src="https://user-images.githubusercontent.com/36429476/151007551-2349bd59-48ba-4811-b1cd-28c597be25df.png">
<img width="400" alt="Screen Shot 2022-01-26 at 2 33 08 am" src="https://user-images.githubusercontent.com/36429476/151007561-fbdc9233-46df-4bef-aecd-0260db6433a6.png">



|ID | ANTIBODY| GROUP |COLOR| QC|  TURNS| SF|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|H3K4me3_WT_n1.bam	 |H3K4me3  |WT	  |black	  |pass	|4.55,0.4216,57.35,0.9552	|1.46
|H3K4me3_WT_n2.bam	 |H3K4me3	|WT	  |black	  |pass	|1,0.4281,44.45,0.9583	    |1.21
|H3K4me3_WT_n3.bam	 |H3K4me3	|WT	  |black	  |pass	|0.3,0.3691,40.15,0.9583	    |1
|H3K4me3_PreM_n1.bam	|H3K4me3	    |PreM	|orange	|pass	|0.35,0.2983,62.75,0.9521	|1.41
|H3K4me3_PreM_n2.bam	|H3K4me3	    |PreM	|orange	|pass	|5,0.4192,62.65,0.9529	    |1.6
|H3K4me3_PreM_n3.bam	|H3K4me3	    |PreM	|orange	|pass	|0.4,0.3533,51.65,0.9549	  |1.26
|H3K4me3_Mal_n1.bam  |H3K4me3	     |Mal	|red	    |pass	|1.25,0.2976,71.35,0.9569	|1.57
|H3K4me3_Mal_n2.bam	|H3K4me3	     |Mal	|red	    |pass	|4.5,0.4195,55.6,0.9513	  |1.42
|H3K4me3_Mal_n3.bam	|H3K4me3	     |Mal	|red	    |pass	|12.75,0.4947,56.65,0.9499	|1.43






Normalisation factors calculated using either of the above two methods can be incorporated for downstream analysis. 



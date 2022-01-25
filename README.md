# ChIP-seq-spikein

This repository details the modifications to the standard ChIP-seq analysis workflow to incorporate an external normalisation factor, calculated either based on a spike-in control or an in-silico based approach. 

### ChIP-seq external spike-in normalisation

Egan *et al*. (2016) have described an external spike-in normalisation approach where a chromatin from a second species       
(e.g. *Drosophila melanogaster*) is added together with an antibody that identifies *D. melanogaster* specific histone variant 
H2Av to all ChIP samples prior to immunoprecipitation. 

The amount of spike-in chromatin and antibody added are adjusted based on the amount of experimental chromatin and kept constant for each target across different conditions. 

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

#### Calculation of normalisation factors 
- Spike in normalisation factors are calculated based on the number of uniquely aligned reads to spike in genome in each sample and separately for each factor of interest or input control. 

E.g. 


### ChIP-seq in-silico spike-in free normalisation

ChIPseqSpikeInFree is an in- silico normalisation method that does not rely on exogenous spike-in material and does not require any modifications to the ChIP-seq experimental protocol. This method relies on the enrichment signal of samples across the genome for calculating normalisation factors and can also be used to detect the complete loss of enrichment or ChIP failure indicated by poor enrichment (Jin *et al*. 2019).

Reference: 

1. Jin, H. *et al*. (2020). ChIPseqSpikeInFree: a ChIP-seq normalization approach to reveal global changes in histone modifications without spike-in. Bioinformatics (Oxford, England), 36(4), 1270–1272. https://doi.org/10.1093/bioinformatics/btz720

2. Github repository - https://github.com/stjude/ChIPseqSpikeInFree

<img width="600" alt="Screen Shot 2022-01-14 at 2 51 51 am" src="https://user-images.githubusercontent.com/36429476/149363181-711a649c-b0aa-45ad-a8d3-681c5593d127.png">


Normalisation factors calculated using either of the above two methods can be incorporated for downstream analysis as follows. 



# ChIP-seq-spikein

### ChIP-seq external spike-in normalisation

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


### ChIP-seq in-silico spike-in free normalisation

<img width="600" alt="Screen Shot 2022-01-14 at 2 51 51 am" src="https://user-images.githubusercontent.com/36429476/149363181-711a649c-b0aa-45ad-a8d3-681c5593d127.png">

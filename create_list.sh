#!/bin/bash

cat /mnt/efs/home/shared/datasets/genomes/GRCh38_with_SIRV/v105/gencode.v39.annotation_tRNA_SIRV-set3.sorted.gtf | awk '$3=="exon"'| /mnt/efs/home/jlagarde/julien_utils_public//extractGffAttributeValue.pl transcript_id gene_type > tmp1
awk '$2=="Mt_tRNA"' tmp1 > mttrna
awk '$2=="Mt_rRNA"' tmp1 > mtrrna
awk '$2=="rRNA"' tmp1 > rrna
awk '$2=="rRNA_pseudogene"' tmp1 > rrnapseudogene
cat mttrna mtrrna rrna rrnapseudogene > tmp2
cut -f 1 tmp2 > tmp3
sort -u tmp3 > tmp4

awk '$1=="M"' /mnt/efs/home/shared/datasets/genomes/GRCh38_with_SIRV/v105/gencode.v39.annotation_tRNA_SIRV-set3.sorted.gtf > tmpM
cat tmpM | awk '$3=="exon"'| /mnt/efs/home/jlagarde/julien_utils_public/extractGffAttributeValue.pl transcript_id > tmpM1

cat tmp4 tmpM1 > tmp5
sort -u tmp5 > ids.txt

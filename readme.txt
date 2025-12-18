prepare:
install rfmix
-vcf vcf.gz
-msp train.msp.tsv(prepare by RFMix2.sh)
-pheno train.pheno
-covar covar.txt(make document all default 1)

example: SDPR_admix -vcf chr22_train.vcf.gz -msp chr22_train.msp.tsv -pheno train.pheno -covar covar.txt -iter 100 -burn 0  -out res.txt
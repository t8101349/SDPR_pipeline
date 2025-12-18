prepare:
install rfmix, gsl
-vcf vcf.gz
-msp msp.tsv(prepare by RFMix2.sh)
-pheno train.pheno
-covar covar.txt(make document all default 1)

example: bash SDPR.sh -r ref.vcf.gz -t chr22_train.vcf.gz -g genetic_map_chr22.txt -s sample_map.txt -c 22 -ph train.pheno -co covar.txt

RFMix2.sh: rfmix + 格式轉換
convert_rfmix_msp_to_sdpr.py: 格式轉換(rfmix結果到sdpr輸入)
#!/bin/bash

# === Help ===
Help() {
    echo "
使用方式: $(basename "$0") [參數]

必要參數:
  -r, --ref            reference vcf
  -t, --target         target vcf
  -g, --genetic_map    chrmosome genetic_map
  -s, --sample_map     sample_map 
  -c, --chr            chromosome number
  -ph                  phenotype
  -co                  covar.txt

其他:
  -h, --help   
  
  example: SDPR.sh -r ref.vcf.gz -t chr22_train.vcf.gz -g genetic_map_chr22.txt -s sample_map.txt -c 22 -ph train.pheno -co covar.txt

"
  }


# === 參數解析 ===
re='^(--help|-h)$'
if [[ $1 =~ $re ]]; then
    Help
else
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -r|--ref) ref="$2"; shift 2;;
            -t|--target) target="$2"; shift 2;;
            -g|--genetic_map) genetic_map="$2"; shift 2;;
            -s|--sample_map) sample_map="$2"; shift 2;;
            -c|--chr) CHR="$2"; shift 2;;
            -ph|--pheno) pheno="$2"; shift 2;;
            -co|--covar) covar="$2"; shift 2;;
            *) echo "unknown option: $1" >&2; exit 1;;
        esac
    done

    # === 檢查必要參數 ===
    if [[ -z "$ref" ]]; then
        echo "❌ 必要參數缺失，請確認 --ref 是否有指定。" >&2
        exit 1
    fi
    if [[ -z "$target" ]]; then
        echo "❌ 必要參數缺失，請確認 --target 是否有指定。" >&2
        exit 1
    fi
    if [[ -z "$genetic_map" ]]; then
        echo "❌ 必要參數缺失，請確認 --genetic_map 是否有指定。" >&2
        exit 1
    fi
    if [[ -z "$sample_map" ]]; then
        echo "❌ 必要參數缺失，請確認 --sample_map 是否有指定。" >&2
        exit 1
    fi
    if [[ -z "$CHR" ]]; then
        echo "❌ 必要參數缺失，請確認 --CHR 是否有指定。" >&2
        exit 1
    fi
    if [[ -z "$pheno" ]]; then
        echo "❌ 必要參數缺失，請確認 --pheno 是否有指定。" >&2
        exit 1
    fi
    if [[ -z "$covar" ]]; then
        echo "❌ 必要參數缺失，請確認 --covar 是否有指定。" >&2
        exit 1
    fi
fi


# === run RFMix2 ===
OUTDIR="output_chr${CHR}"
echo "Running RFMix2 for chromosome $CHR..."
bash /home/Weber/Pipeline/SDPR/RFMix2.sh \
    -r "$ref" -t "$target" -g "$genetic_map" -s "$sample_map" -c "$CHR"


MSP_FILE="${OUTDIR}/chr${CHR}_sdpr.msp.tsv"
if [[ ! -f "$MSP_FILE" ]]; then
    echo "❌ MSP file not found: $MSP_FILE" >&2
    exit 1
fi

# === run SDPR ===
echo "Running SDPR_admix..."
/home/Weber/SDPR_admix/SDPR_admix \
    -vcf "$target" \
    -msp "$MSP_FILE" \
    -pheno "$pheno" \
    -covar "$covar" \
    -iter 100 \
    -burn 0 \
    -out "chr${CHR}_sdpr.txt"

echo "✅ Finished PRS training for chromosome $CHR"

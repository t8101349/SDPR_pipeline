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

其他:
  -h, --help   
  
  example: RFMix2.sh -r ref.vcf.gz -t target.vcf.gz -g genetic_map_chr22.txt -s sample_map.txt -c 22

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
        echo "❌ 必要參數缺失，請確認 --chr 是否有指定。" >&2
        exit 1
    fi
fi


# === OUTPUT DIR ===
OUTDIR="output_chr${CHR}"
mkdir -p ${OUTDIR}

# === STEP 1: convert VCF to phased VCF and Viterbi format ===
# （ phasing & VCF ready）

# === STEP 2: run RFMix2 ===
rfmix \
  --chromosome=${CHR} \
  --genetic-map=${genetic_map} \
  --samples-file=${sample_map} \
  --vcf-reference=${ref} \
  --vcf-target=${target} \
  --output-basename=${OUTDIR}/chr${CHR} \
  --n-threads=4

# === STEP 3: postprocess .msp.tsv into summary ===
python /home/Weber/Pipeline/SDPR/convert_rfmix_msp_to_sdpr.py \
  --input ${OUTDIR}/chr${CHR}.msp.tsv \
  --output ${OUTDIR}/chr${CHR}_sdpr.msp.tsv

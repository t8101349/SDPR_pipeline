import pandas as pd
import numpy as np
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--input', required=True)
parser.add_argument('--output', required=True)
args = parser.parse_args()

# 正確讀入包含 header 的 tsv
df = pd.read_csv("chr22_train.msp.tsv", sep="\t", skiprows=1)  
df.columns = [col.lstrip("#") for col in df.columns]          
print(df.columns.tolist())  


# 基本欄位
chrom = df['chm'].iloc[0]
min_pos = df['spos'].min()
max_pos = df['epos'].max()

# 將整段染色體分 3 段
breakpoints = np.linspace(min_pos, max_pos, 4)

# 取得 perX.Y 欄位
per_cols = [col for col in df.columns if col.startswith('per')]

rows = []
for i in range(3):
    start = breakpoints[i]
    end = breakpoints[i+1]
    seg_df = df[(df['spos'] >= start) & (df['epos'] <= end)]

    if seg_df.empty:
        continue

    # SNP 數總和
    n_snps = seg_df['n snps'].sum()

    # 平均祖先機率
    avg_prop = seg_df[per_cols].mean().mean()

    # 判定 dominant ancestry
    dominant = 1 if avg_prop > 0.5 else 0

    rows.append({
        'segment': i + 1,
        'chrom': chrom,
        'start': int(start),
        'end': int(end),
        'n_snps': int(n_snps),
        'avg_ancestry': avg_prop,
        'dominant_ancestry': dominant
    })

out_df = pd.DataFrame(rows)
out_df.to_csv(args.output, sep='\t', index=False)

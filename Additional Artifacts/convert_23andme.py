#!/usr/bin/env python3
"""
Convert 23andMe raw data to PLINK format for ancient ancestry analysis
"""

import pandas as pd
import sys
import os

def convert_23andme_to_plink(input_file, output_prefix):
    """Convert 23andMe raw data to PLINK .ped/.map format"""
    
    print(f"Reading {input_file}...")
    
    # Read 23andMe file, skipping comment lines
    data = []
    with open(input_file, 'r') as f:
        for line in f:
            if not line.startswith('#'):
                data.append(line.strip().split('\t'))
    
    # Convert to DataFrame
    df = pd.DataFrame(data, columns=['rsid', 'chromosome', 'position', 'genotype'])
    
    # Filter out non-standard chromosomes and missing genotypes
    df = df[df['chromosome'].isin([str(i) for i in range(1, 23)] + ['X', 'Y'])]
    df = df[df['genotype'] != '--']
    
    # Convert genotypes to PLINK format (space-separated alleles)
    df['allele1'] = df['genotype'].str[0]
    df['allele2'] = df['genotype'].str[1]
    
    print(f"Processing {len(df)} SNPs...")
    
    # Create MAP file (chromosome, rsid, genetic distance, position)
    map_df = df[['chromosome', 'rsid', 'position']].copy()
    map_df['genetic_distance'] = 0  # Set to 0 as we don't have genetic map info
    map_df = map_df[['chromosome', 'rsid', 'genetic_distance', 'position']]
    map_df.to_csv(f"{output_prefix}.map", sep='\t', header=False, index=False)
    
    # Create PED file (family_id, individual_id, father, mother, sex, phenotype, genotypes...)
    # Prepare genotype data
    genotype_data = []
    for _, row in df.iterrows():
        genotype_data.extend([row['allele1'], row['allele2']])
    
    # Create single row for PED file
    ped_row = ['FAM1', 'IND1', '0', '0', '0', '-9'] + genotype_data
    
    with open(f"{output_prefix}.ped", 'w') as f:
        f.write('\t'.join(ped_row) + '\n')
    
    print(f"Created {output_prefix}.ped and {output_prefix}.map")
    print(f"Total SNPs: {len(df)}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python convert_23andme.py <23andme_file> <output_prefix>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_prefix = sys.argv[2]
    
    convert_23andme_to_plink(input_file, output_prefix)

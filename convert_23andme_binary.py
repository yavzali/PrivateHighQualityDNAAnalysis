#!/usr/bin/env python3

"""
Enhanced 23andMe to Binary PLINK Converter
Creates .bed, .bim, .fam files that ADMIXTOOLS 2 can read directly
"""

import sys
import struct
import os
from collections import defaultdict

def create_binary_plink(input_file, output_prefix):
    """Convert 23andMe format to binary PLINK format (.bed, .bim, .fam)"""
    
    print(f"Reading {input_file}...")
    
    # Data structures
    snps = []
    genotypes = []
    
    # Read 23andMe file
    with open(input_file, 'r') as f:
        for line_num, line in enumerate(f, 1):
            if line_num % 100000 == 0:
                print(f"Processed {line_num:,} lines...")
                
            line = line.strip()
            if line.startswith('#') or not line:
                continue
                
            parts = line.split('\t')
            if len(parts) < 4:
                continue
                
            rsid, chrom, pos, genotype = parts[:4]
            
            # Skip invalid chromosomes
            if chrom in ['0', 'MT', 'Y']:
                continue
                
            # Convert chromosome to numeric
            try:
                if chrom == 'X':
                    chrom_num = 23
                else:
                    chrom_num = int(chrom)
            except ValueError:
                continue
                
            # Convert position to integer
            try:
                pos_int = int(pos)
            except ValueError:
                continue
                
            # Process genotype
            if genotype == '--':
                # Missing genotype
                allele1, allele2 = '0', '0'
            elif len(genotype) == 2:
                allele1, allele2 = genotype[0], genotype[1]
            else:
                continue
                
            # Store SNP info
            snps.append({
                'rsid': rsid,
                'chrom': chrom_num,
                'pos': pos_int,
                'allele1': allele1,
                'allele2': allele2
            })
    
    print(f"Processing {len(snps):,} SNPs...")
    
    # Create .fam file (family file)
    fam_file = f"{output_prefix}.fam"
    with open(fam_file, 'w') as f:
        # Format: FamilyID IndividualID PaternalID MaternalID Sex Phenotype
        f.write("Zehra_Raza Zehra_Raza 0 0 2 -9\n")  # Sex=2 (female), Phenotype=-9 (missing)
    
    # Create .bim file (variant information)
    bim_file = f"{output_prefix}.bim"
    with open(bim_file, 'w') as f:
        for snp in snps:
            # Determine major/minor alleles
            alleles = [snp['allele1'], snp['allele2']]
            unique_alleles = list(set(alleles))
            
            if '0' in unique_alleles:
                # Missing data - use common alleles
                a1, a2 = 'A', 'T'
            elif len(unique_alleles) == 1:
                # Homozygous - create artificial second allele
                a1 = unique_alleles[0]
                a2 = 'A' if a1 != 'A' else 'T'
            else:
                # Heterozygous
                a1, a2 = unique_alleles[0], unique_alleles[1]
            
            # Format: Chr SNP_ID Genetic_Distance Physical_Position Allele1 Allele2
            f.write(f"{snp['chrom']} {snp['rsid']} 0 {snp['pos']} {a1} {a2}\n")
    
    # Create .bed file (binary genotype data)
    bed_file = f"{output_prefix}.bed"
    with open(bed_file, 'wb') as f:
        # Write magic number for binary PLINK format
        f.write(b'\x6c\x1b\x01')  # Magic number: 0x6c1b01
        
        # Process genotypes for each SNP
        for snp in snps:
            # Convert genotype to binary format
            # PLINK binary format: 2 bits per genotype
            # 00 = homozygous major, 01 = missing, 10 = heterozygous, 11 = homozygous minor
            
            a1, a2 = snp['allele1'], snp['allele2']
            
            if a1 == '0' or a2 == '0':
                # Missing genotype
                genotype_bits = 0b01
            elif a1 == a2:
                # Homozygous - assume major allele
                genotype_bits = 0b00
            else:
                # Heterozygous
                genotype_bits = 0b10
            
            # Pack into byte (4 genotypes per byte, but we only have 1 individual)
            # Pad with missing genotypes (01) for the remaining 3 positions
            byte_value = genotype_bits | (0b01 << 2) | (0b01 << 4) | (0b01 << 6)
            f.write(struct.pack('B', byte_value))
    
    print(f"Created binary PLINK files:")
    print(f"  {fam_file} (family information)")
    print(f"  {bim_file} (variant information)")
    print(f"  {bed_file} (binary genotype data)")
    print(f"Total SNPs: {len(snps):,}")
    
    return len(snps)

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 convert_23andme_binary.py <input_file> <output_prefix>")
        print("Example: python3 convert_23andme_binary.py genome.txt Results/Zehra_Raza")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_prefix = sys.argv[2]
    
    if not os.path.exists(input_file):
        print(f"Error: Input file {input_file} not found")
        sys.exit(1)
    
    try:
        snp_count = create_binary_plink(input_file, output_prefix)
        print(f"✅ Conversion completed successfully!")
        print(f"   {snp_count:,} SNPs converted to binary PLINK format")
        print(f"   Files ready for ADMIXTOOLS 2 analysis")
    except Exception as e:
        print(f"❌ Error during conversion: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 
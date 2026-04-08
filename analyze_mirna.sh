#!/bin/bash
set -euo pipefail

# --- DEPENDENCY CHECK ---
for cmd in wget seqkit awk; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "Error: required command '$cmd' not found." >&2
        exit 1
    }
done
# --- Configurable organism and gene targets via CLI arguments
# defaults: cel, let-7|lin-4

ORGANISM="${1:-cel}"
GENES="${2:-let-7|lin-4}"
# --- Build the regex pattern dynamically from the two parameters.
PATTERN=""
IFS='|' read -ra GENE_LIST <<< "$GENES"
for gene in "${GENE_LIST[@]}"; do
    PATTERN+="${ORGANISM}-.*${gene}|"
done
PATTERN="${PATTERN%|}"   # strip trailing pipe

# --- CONFIGURATION ---
DATA_DIR="cel_analysis_v22"
# Static version 22 URL for reproducibility
MIRBASE_URL="https://www.mirbase.org/download_version_files/22/hairpin.fa"
INPUT_FILE="hairpin.fa"
OUTPUT_FILE="cel_mirna_v22_results.tsv"

# --- 1. SETUP ---
echo -e "\e[34m[1/4]\e[0m Creating workspace: $DATA_DIR"
mkdir -p "$DATA_DIR"
BASEDIR="$(pwd)/$DATA_DIR"
mkdir -p "$BASEDIR"
INPUT_FILE="$BASEDIR/hairpin.fa"
OUTPUT_FILE="$BASEDIR/cel_mirna_v22_results.tsv"

# --- 2. DOWNLOAD ---
if [ ! -s "$INPUT_FILE" ]; then
    echo -e "\e[34m[2/4]\e[0m Downloading miRBase v22 data..."
    # Using -c to resume if interrupted and -L for redirects
    wget -c -L -q --show-progress "$MIRBASE_URL" -O "$INPUT_FILE"
else
    echo -e "\e[32m[2/4]\e[0m $INPUT_FILE already exists. Skipping download."
fi

# --- 3. FILTER & PROCESS ---
echo -e "\e[34m[3/4]\e[0m Processing C. elegans sequences..."
# Filtering, converting to DNA, and outputting Name, Length, and GC%
# -i: Ignore case
# -r: Use regex
# Pattern: finds any header containing "cel-" followed by "let-7" or "lin-4"
seqkit grep -i -r -p "cel-.*let-7|cel-.*lin-4" "$INPUT_FILE" | \
seqkit seq --rna2dna | \
seqkit fx2tab --name --length --gc > "$OUTPUT_FILE"

# --- 4. Sequence Count

COUNT=$(wc -l < "$OUTPUT_FILE")
echo -e "Sequences found: $COUNT"

# --- 5. ANALYSIS & REPORT ---
echo -e "\e[34m[4/4]\e[0m Generating Summary Statistics..."
echo -e "\n--- BIOCHEMISTRY REPORT: C. elegans miRNA (miRBase v22) ---"
echo -e "Generated on: $(date)"
echo -e "---------------------------------------------------------"
printf "%-60s %-10s %-10s\n" "Sequence_ID" "Length" "GC_Content"

# Formatting the TSV output for a professional look
awk -F'\t' '{printf "%-60s %-10s %-10.2f%%\n", $1, $2, $3}' "$OUTPUT_FILE"

echo -e "---------------------------------------------------------"
echo -e "\e[32mSUCCESS:\e[0m Static analysis complete."

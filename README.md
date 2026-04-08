# Cel-miRNA-Sequence-Analysis-Pipeline
This is an automated Bash pipeline for reproducible miRNA analysis from miRBase v22. I used C. elegans (lin-4/let-7) precursors using SeqKit for biochemical metric extraction.

## Biological Context
MicroRNAs are small non-coding RNA molecules (~22nt) that play a critical role in post-transcriptional gene regulation. This pipeline focuses on:

**cel-lin-4:** The first miRNA discovered, essential for larval development.

**cel-let-7:** A highly conserved regulator of developmental timing.

The script automates the extraction of these precursors, converts the RNA sequences to DNA for downstream compatibility, and calculates key biochemical metrics such as GC Content.

## Features
**Automation:** One-touch execution from download to final report.

**Efficiency:** Optimized for multi-core processing (Intel i5-1235U) using SeqKit.

**Data Transformation:** Converts raw FASTA data into structured TSV tables.

**Configurable Organism and Gene Targets:** The pipeline now accepts two optional command-line arguments, replacing the hardcoded C. elegans pattern. Any organism prefix and any set of gene targets available in miRBase can be queried without editing the script.

**Default behaviour (unchanged): C. elegans, let-7 and lin-4**
./analyze_mirna.sh

**Human (hsa), default gene targets**
./analyze_mirna.sh hsa

**Human, custom gene panel**
./analyze_mirna.sh hsa "mir-21|mir-155|mir-122"

**Drosophila, single gene**
./analyze_mirna.sh dme "bantam"

The terminal report and the exported Markdown file now include a summary row showing the mean sequence length and mean GC content across all matched sequences. This is calculated inline by the awk block that formats the per-sequence table, adding no extra processing overhead.

The regex pattern is constructed dynamically at runtime (e.g. cel-.*let-7|cel-.*lin-4) and echoed to the terminal at the start of each run for transparency. The output directory name also reflects the organism prefix, so results from different organisms never overwrite each other.

**Aggregate Summary Statistics:** The terminal report and the exported Markdown file now include a summary row showing the mean sequence length and mean GC content across all matched sequences. This is calculated inline by the awk block that formats the per-sequence table, adding no extra processing overhead.

Sequence_ID                                                  Length     GC_Content
cel-let-7                                                    99         52.53%
cel-let-7-5p                                                 88         50.00%
...
MEAN (n=8)                                                   93.5       51.26%

**Markdown Report Export:** After the terminal summary, the pipeline writes a human-readable report to:

<organism>_analysis_v22/<organism>_mirna_v22_report.md

Why Markdown? The format renders automatically on GitHub (making results immediately shareable via the repository), is fully readable as plain text with no tooling, and matches the documentation style already used in this project. Unlike CSV or TSV, it includes the run metadata alongside the data.
The report contains:

A metadata header (organism, gene targets, miRBase version, run date, sequence count, mean length, mean GC%)


A formatted sequence table with all per-sequence metrics


A methods note summarising the filtering pattern and transformations applied

**Example Output:**
(cel_analysis_v22/cel_mirna_v22_report.md):


# miRNA Analysis Report

| Field        | Value        |
|--------------|--------------|
| Organism     | `cel`        |
| Gene targets | `let-7|lin-4`|
| miRBase ver. | v22          |
| ...          | ...          |

## Sequence Table

| Sequence ID | Length (nt) | GC%    |
|-------------|-------------|--------|
| cel-let-7   | 99          | 52.53% |
| ...         | ...         | ...    |

## Installation & Usage
### Prerequisites
Ensure you have seqkit installed on your Ubuntu system:

Bash:
sudo apt update && sudo apt install seqkit -y

## Execution
Clone the repository:

Bash

git clone git@github.com:CharlesDexterW/cel-mirna-seqkit-pipeline.git


cd cel-mirna-seqkit-pipeline


Set permissions and run:

Bash

chmod +x analyze_mirna.sh


./analyze_mirna.sh
## Output
The pipeline generates a directory cel_analysis_v22/ containing:

**hairpin.fa:** The raw miRBase dataset.

**cel_mirna_v22_results.tsv:** A tab-separated file.
## Output Preview

<div align="center">
  <img src="https://github.com/CharlesDexterW/C.-elegans-miRNA-Sequence-Analysis-Pipeline/blob/main/Summary_stats.png?raw=true" width="100%">
  <br>
  <p><b>Figure 1</b>: Summary Statistics of C. elegans miRNA (miRBase v22)</p>
</div>

## Built With
**Bash:** Shell scripting for process automation.

**SeqKit:** Ultra-fast toolkit for FASTA/Q manipulation.

**AWK:** For terminal report formatting.

## Bibliographic Sources
*Kozomara, A., et al. (2019). miRBase: from microRNA sequences to function. Nucleic Acids Research, 47(D1).*

*Shen, W. (2016). SeqKit: A Cross-Platform and Ultrafast Toolkit for FASTA/Q Manipulation. PLOS ONE.*

*Ambros, V. (1993). The C. elegans heterochronic gene lin-4. Cell.*

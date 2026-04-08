# C.-elegans-miRNA-Sequence-Analysis-Pipeline
This is an automated Bash pipeline for reproducible miRNA analysis from miRBase v22. I used C. elegans (lin-4/let-7) precursors using SeqKit for biochemical metric extraction.

## Biological Context
MicroRNAs are small non-coding RNA molecules (~22nt) that play a critical role in post-transcriptional gene regulation. This pipeline focuses on:

**cel-lin-4:** The first miRNA discovered, essential for larval development.

**cel-let-7:** A highly conserved regulator of developmental timing.

The script automates the extraction of these precursors, converts the RNA sequences to DNA for downstream compatibility, and calculates key biochemical metrics such as GC Content.

## Features
**Reproducibility:** Targets a static version of the miRBase database (v22).

**Automation:** One-touch execution from download to final report.

**Efficiency:** Optimized for multi-core processing (Intel i5-1235U) using SeqKit.

**Data Transformation:** Converts raw FASTA data into structured TSV tables.

## Installation & Usage
### Prerequisites
Ensure you have seqkit installed on your Ubuntu system:

Bash:
sudo apt update && sudo apt install seqkit -y

## Execution
Clone the repository:

Bash

git clone git@github.com:CharlesDexterW/cel-mirna-seqkit-pipeline.git
cd miRNA-analysis-pipeline
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

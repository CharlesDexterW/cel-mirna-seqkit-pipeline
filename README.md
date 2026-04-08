# cel-mirna-seqkit-pipeline

> An automated Bash pipeline for reproducible miRNA sequence analysis using miRBase v22 and SeqKit. Filters precursor sequences by organism and gene target, converts RNA to DNA, and extracts biochemical metrics into structured TSV and Markdown reports.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/shell-bash-blue.svg)](https://www.gnu.org/software/bash/)
[![miRBase](https://img.shields.io/badge/miRBase-v22-green.svg)](https://www.mirbase.org/)

---

## Table of Contents

- [Biological Context](#biological-context)
- [Pipeline Overview](#pipeline-overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [Basic usage](#basic-usage)
  - [Custom organism](#custom-organism)
  - [Custom gene targets](#custom-gene-targets)
- [Output](#output)
  - [Directory structure](#directory-structure)
  - [TSV data file](#tsv-data-file)
  - [Markdown report](#markdown-report)
  - [Terminal summary](#terminal-summary)
- [Example Results](#example-results)
- [Technical Details](#technical-details)
- [Limitations](#limitations)
- [Built With](#built-with)
- [References](#references)
- [License](#license)

---

## Biological Context

MicroRNAs (miRNAs) are small (~22 nt) non-coding RNA molecules that regulate gene expression post-transcriptionally by binding to complementary sequences in target mRNAs, typically suppressing their translation or triggering degradation. They are among the most studied regulatory molecules in molecular biology.

This pipeline focuses by default on two landmark miRNAs in *Caenorhabditis elegans*:

**cel-lin-4** — The first miRNA ever discovered (Lee et al., 1993). It regulates larval developmental timing in *C. elegans* by repressing the LIN-14 protein. Its discovery established the existence of a new class of gene regulators.

**cel-let-7** — A highly conserved miRNA (Reinhart et al., 2000) that controls the transition from late larval to adult cell fates. The *let-7* family is present across bilaterians, making it one of the most studied non-coding RNAs in biology.

GC content is a key biochemical property of nucleic acid sequences. Higher GC content correlates with greater thermal stability (due to the three hydrogen bonds in G:C pairs vs. two in A:T pairs), which is relevant for understanding secondary structure formation in miRNA precursors and their interactions with Dicer and Argonaute proteins.

---

## Pipeline Overview

```
miRBase v22 (hairpin.fa)
        │
        ▼
[seqkit grep]  — filter sequences by organism + gene pattern
        │
        ▼
[seqkit seq]   — convert RNA → DNA (U → T)
        │
        ▼
[seqkit fx2tab] — extract name, length, GC%
        │
        ├──▶  cel_mirna_v22_results.tsv   (raw data)
        └──▶  cel_mirna_v22_report.md     (formatted report)
```

The pipeline runs in six steps:

1. **Setup** — creates a versioned working directory and resolves all file paths
2. **Download** — fetches `hairpin.fa` from miRBase v22 (skipped if already present)
3. **Filter & process** — applies a regex pattern, converts RNA to DNA, and extracts metrics
4. **Sequence count** — validates results and reports the number of matched sequences
5. **Terminal report** — prints a formatted summary table with aggregate statistics
6. **Markdown export** — writes a portable, GitHub-renderable report file

---

## Features

**Configurable organism and gene targets** — pass any miRBase organism prefix and any pipe-separated list of gene names as command-line arguments. No script editing required. Defaults to *C. elegans* (`cel`) with `let-7` and `lin-4`.

**Reproducibility** — targets a static, versioned miRBase release (v22) via a pinned URL, ensuring results are identical across runs and machines.

**FASTA validation** — verifies the downloaded file is a real FASTA before processing, preventing silent failures from network errors or HTML error pages.

**Aggregate statistics** — the terminal report and exported file include mean sequence length and mean GC% across all matched sequences, computed in a single `awk` pass.

**Dual output formats** — raw data is saved as a TSV for downstream analysis; a human-readable Markdown report is generated for documentation and sharing.

**Isolated output directories** — each organism gets its own directory (e.g. `cel_analysis_v22/`, `hsa_analysis_v22/`), so runs for different organisms never overwrite each other.

**Resume-safe download** — `wget -c` resumes interrupted downloads automatically.

---

## Requirements

| Tool | Version | Purpose |
|------|---------|---------|
| `bash` | ≥ 4.0 | Script runtime |
| `wget` | any | Download miRBase data |
| `seqkit` | ≥ 2.0 | FASTA filtering and metric extraction |
| `awk` | any (gawk/mawk) | Report formatting |

The script checks for all required commands at startup and exits with a clear error message if any are missing.

---

## Installation

**1. Clone the repository**

```bash
git clone https://github.com/CharlesDexterW/cel-mirna-seqkit-pipeline.git
cd cel-mirna-seqkit-pipeline
```

**2. Install SeqKit**

On Ubuntu/Debian:

```bash
sudo apt update && sudo apt install seqkit -y
```

Via Conda:

```bash
conda install -c bioconda seqkit
```

Or download a pre-built binary from the [SeqKit releases page](https://github.com/shenwei356/seqkit/releases).

**3. Make the script executable**

```bash
chmod +x analyze_mirna.sh
```

---

## Usage

### Basic usage

Runs the default analysis: *C. elegans* `let-7` and `lin-4` precursors.

```bash
./analyze_mirna.sh
```

### Custom organism

Pass a miRBase organism prefix as the first argument. The prefix must match the two- or three-letter code used in miRBase sequence headers (e.g. `hsa` for *Homo sapiens*, `mmu` for *Mus musculus*, `dme` for *Drosophila melanogaster*).

```bash
# Human sequences, default gene targets (let-7 and lin-4)
./analyze_mirna.sh hsa

# Mouse sequences
./analyze_mirna.sh mmu
```

### Custom gene targets

Pass a pipe-separated list of gene name patterns as the second argument. Patterns are matched case-insensitively as regular expressions against miRBase sequence headers.

```bash
# Human mir-21 and mir-155
./analyze_mirna.sh hsa "mir-21|mir-155"

# C. elegans let-7 family only
./analyze_mirna.sh cel "let-7"

# Multiple targets across a custom organism
./analyze_mirna.sh dme "bantam|mir-8|mir-14"
```

The pattern being used is always printed to the terminal at the start of each run:

```
       Organism : hsa
       Targets  : mir-21|mir-155
       Pattern  : hsa-.*mir-21|hsa-.*mir-155
```

---

## Output

### Directory structure

```
cel_analysis_v22/
├── hairpin.fa                    # Raw miRBase v22 download (all organisms)
├── cel_mirna_v22_results.tsv     # Per-sequence metrics (tab-separated)
└── cel_mirna_v22_report.md       # Formatted Markdown report
```

The directory name reflects the organism prefix. Running with `hsa` produces `hsa_analysis_v22/` with correspondingly named files.

### TSV data file

`cel_mirna_v22_results.tsv` is a three-column, tab-separated file suitable for import into R, Python (pandas), or any spreadsheet application:

```
cel-let-7	99	52.53
cel-let-7-5p	88	50.00
cel-lin-4	78	47.44
...
```

Columns: `sequence_id`, `length_nt`, `gc_percent`

### Markdown report

`cel_mirna_v22_report.md` renders as a formatted table on GitHub and is readable as plain text. It contains:

- A metadata header (organism, targets, miRBase version, run date, sequence count, mean length, mean GC%)
- A complete per-sequence table
- A methods note documenting the regex pattern and transformations applied

This file is suitable for inclusion in lab notebooks, supplementary materials, or repository documentation.

### Terminal summary

The terminal report prints during step 5 and includes a `MEAN` row at the bottom:

```
--- BIOCHEMISTRY REPORT: cel miRNA (miRBase v22) ---
Generated on: Mon Apr  7 12:00:00 UTC 2026
---------------------------------------------------------
Sequence_ID                                                  Length     GC_Content
cel-let-7                                                    99         52.53%
cel-let-7-5p                                                 88         50.00%
cel-lin-4                                                    78         47.44%
...
MEAN (n=8)                                                   93.5       51.26%
---------------------------------------------------------
```

---

## Example Results

The `cel_mirna_v22_results.tsv` file committed to this repository contains the output from the default run (organism: `cel`, targets: `let-7|lin-4`). A rendered preview:

<div align="center">
  <img src="https://github.com/CharlesDexterW/cel-mirna-seqkit-pipeline/blob/main/Summary_stats.png?raw=true" width="90%">
  <br>
  <p><b>Figure 1</b>: Terminal summary — C. elegans miRNA metrics (miRBase v22)</p>
</div>

---

## Technical Details

**RNA to DNA conversion** — miRBase stores sequences as RNA (uracil, `U`). SeqKit's `--rna2dna` flag replaces all `U` with `T`, producing DNA sequences compatible with most downstream tools (primers, BLAST, alignment pipelines).

**GC content calculation** — GC% is calculated by SeqKit's `fx2tab` as `(G + C) / total_length × 100`. It operates on the DNA-converted sequence, which is biochemically equivalent to the original RNA GC content since the only substitution is `U → T`.

**Regex pattern construction** — the pattern is built by iterating over the pipe-separated gene list and prefixing each gene with the organism code. For example, `cel` + `let-7|lin-4` produces `cel-.*let-7|cel-.*lin-4`. The `-i` (case-insensitive) and `-r` (regex) flags are passed to `seqkit grep`.

**Idempotent download** — the script checks for a non-empty `hairpin.fa` before downloading. Re-running the script reuses the existing file, making the pipeline fast to re-execute after the initial download.

---

## Limitations

- The pipeline targets miRBase **v22** specifically. This is intentional for reproducibility, but means it does not reflect additions or corrections made in later releases (the current release at time of writing is v22.1).
- Only **hairpin precursor** sequences are analysed. Mature miRNA sequences (from `mature.fa`) are not included.
- The miRBase v22 download URL (`mirbase.org/download_version_files/22/hairpin.fa`) may become unavailable if the miRBase website restructures. If the download fails, the FASTA validation step will catch it and exit cleanly.
- Multi-threaded processing is not explicitly configured. SeqKit uses all available cores by default via its internal concurrency model.

---

## Built With

- **Bash** — shell scripting and pipeline orchestration
- **[SeqKit](https://bioinf.shenwei.me/seqkit/)** — ultra-fast FASTA/Q toolkit for filtering, conversion, and metric extraction
- **AWK** — terminal report formatting and aggregate statistics
- **wget** — robust, resume-safe file download

---

## References

Kozomara, A., Birgaoanu, M., & Griffiths-Jones, S. (2019). miRBase: from microRNA sequences to function. *Nucleic Acids Research*, 47(D1), D155–D162. https://doi.org/10.1093/nar/gky1141

Shen, W., Le, S., Li, Y., & Hu, F. (2016). SeqKit: A cross-platform and ultrafast toolkit for FASTA/Q file manipulation. *PLOS ONE*, 11(10), e0163962. https://doi.org/10.1371/journal.pone.0163962

Lee, R. C., Feinbaum, R. L., & Ambros, V. (1993). The *C. elegans* heterochronic gene *lin-4* encodes small RNAs with antisense complementarity to *lin-14*. *Cell*, 75(5), 843–854. https://doi.org/10.1016/0092-8674(93)90529-Y

Reinhart, B. J., et al. (2000). The 21-nucleotide *let-7* RNA regulates developmental timing in *Caenorhabditis elegans*. *Nature*, 403, 901–906. https://doi.org/10.1038/35002607

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

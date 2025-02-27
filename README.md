# wgsimc

## Introduction

**Wgsimc** is a small tool for simulating sequence reads from a reference genome.
It is capable of simulating diploid genomes with SNPs and insertion/deletion (INDEL)
polymorphisms and generating reads with uniform substitution sequencing errors.
While it does not generate INDEL sequencing errors, this can be partially
compensated by simulating INDEL polymorphisms. The tool can simulate reads
from both linear and circular genomes.

**Wgsimc** outputs the simulated polymorphisms and writes the true read coordinates
as well as the number of polymorphisms and sequencing errors in read names.
One can evaluate the accuracy of a mapper or a SNP caller with `wgsim_eval.pl`
that comes with the package.

## Compilation

You can compile **wgsimc** using the provided `Makefile`:

```bash
make
```

This will generate the `wgsimc` executable.

Alternatively, you can compile manually using:

```bash
gcc -g -O2 -Wall -o wgsimc wgsimc.c -lz -lm
```

## Usage

To simulate reads using **wgsimc**, run:

```bash
wgsimc [options] <in.ref.fa> <out_prefix>
```

The program will output two FASTQ files:
- `<out_prefix>.read1.fq`: Contains the first reads of each pair
- `<out_prefix>.read2.fq`: Contains the second reads of each pair

Use the `-c` option to simulate reads from circular genomes, allowing reads to span across the sequence end and beginning.

### Example for Circular Genome:

```bash
wgsimc -c -N1000000 -1 150 -2 150 circular.fa output_prefix
```

### Coverage-based Simulation

You can specify the desired coverage using the `-f` option instead of explicitly setting the number of read pairs:

```bash
wgsimc -c -f 100 -1 150 -2 150 circular.fa output_prefix
```

This will generate enough read pairs to achieve approximately 100x coverage of the reference genome.

## Evaluation

### Simulation and Evaluation

The command line for simulation:

```bash
wgsimc [-c] -f <coverage> -1 <read_length> -d0 -S11 -e0 -r <error_rate> reference.fa output_prefix
```

- Replace `<coverage>` with the desired coverage (or use `-N <number_of_reads>` for exact read count)
- Replace `<read_length>` with the length of the reads (default is 150)
- Replace `<error_rate>` with the desired error rate

By default, 15% of polymorphisms are INDELs, and their lengths are drawn from a
geometric distribution with density \( 0.7 \times 0.3^{l-1} \).

The command line for evaluation:

```bash
wgsim_eval.pl unique aln.sam | wgsim_eval.pl alneval -g 20
```

The `-g` option may be changed with mappers.

## Circular Genome Mode by Lifu Song [songlf@tib.cas.cn]

When simulating reads from circular genomes (e.g., bacterial chromosomes,
plasmids, mitochondrial DNA), use the `-c` option. In this mode:

- Reads are allowed to wrap around from the end to the beginning of the sequence.
- The length restriction (sequence length > fragment size + 3 * std_dev) is ignored.
- Position generation and read extraction handle the circular nature of the sequence.

### Example for Circular Genome:

```bash
wgsimc -c -f 50 circular.fa output_prefix
```

This will generate paired-end reads with default 150bp length and approximately 50x coverage.

## Options Summary

- `-e FLOAT`: Base error rate [0.020]
- `-d INT`: Outer distance between the two ends [500]
- `-s INT`: Standard deviation [50]
- `-N INT`: Number of read pairs [1000000]
- `-1 INT`: Length of the first read [150]
- `-2 INT`: Length of the second read [150]
- `-r FLOAT`: Rate of mutations [0.0010]
- `-R FLOAT`: Fraction of indels [0.15]
- `-X FLOAT`: Probability an indel is extended [0.30]
- `-S INT`: Seed for random generator [-1]
- `-A FLOAT`: Discard if fraction of ambiguous bases is higher than FLOAT [0.05]
- `-f FLOAT`: Coverage of read pairs (overrides -N) [100]
- `-h`: Haplotype mode
- `-c`: Circular genome mode

## Makefile

A `Makefile` is provided for easy compilation. Run `make` in the terminal to compile **wgsimc**.

```Makefile
CC = gcc
CFLAGS = -g -O2 -Wall
LDFLAGS = -lz -lm
TARGET = wgsimc
SRC = wgsimc.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC) $(LDFLAGS)

clean:
	rm -f $(TARGET)
```

## History

**Wgsimc** was modified from MAQ's read simulator by dropping dependencies on other
source codes in the MAQ package and incorporating patches from Colin Hercus,
which allow simulation of INDELs longer than 1bp. It was originally released
as **wgsim** in the SAMtools software package, then forked out in 2011 as a standalone
project. The circular genome simulation capability was added later, leading to
the rename to **wgsimc**.

## System Requirements

- **Compiler:** GCC 4.1.2 or later

## Notes

- Ensure that `wgsimc.c` is in the same directory as the `Makefile` when compiling.
- If you have additional source files or headers, you can modify the `SRC` variable in the `Makefile` accordingly.
- You can adjust the `CFLAGS` and `LDFLAGS` in the `Makefile` as needed for your specific environment or compiler requirements.


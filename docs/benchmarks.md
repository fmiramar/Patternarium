# Finite numerical benchmarks

Run `scripts/test.sh "$PWD/Tests/benchmarks.scd"`. These are small server-free workloads, including collection of all outputs. The script reports wall-clock elapsed time after class compilation; no throughput guarantee or CI threshold is implied.

One local SuperCollider 3.14.1 run on 2026-11-17 produced:

| Workload | Outputs | Seconds |
| --- | ---: | ---: |
| Pscan accumulation | 10000 | 0.002754 |
| Binary De Bruijn order 12 | 4096 | 0.001615 |
| Gray radices [10,10,10] | 1000 | 0.000707 |
| 3D Halton | 10000 | 0.036561 |
| Constant-interval renewal | 10000 | 0.015652 |
| Scalar Hawkes, seed 42 | 5000 | 0.029604 |
| Six-position distinct-value constraints | 20 solutions | 0.000142 |
| Three-node graph cycle | 10000 | 0.023798 |

Timing includes interpreter, allocation and scheduling effects in this execution environment. Re-run on the intended performance machine and representative application inputs before drawing performance conclusions. These workloads do not establish peak memory usage, numerical accuracy or audio scheduling quality.

The experimental-system workloads were added and measured in a later local 3.14.1 run on the same date:

| Workload | Outputs | Seconds |
| --- | ---: | ---: |
| PPM-C, four-symbol corpus, order 3 | 10000 | 0.234045 |
| Two-transition Petri cycle | 10000 | 0.051077 |
| Four-oscillator RK4 Kuramoto | 1000 | 0.033150 |
| Binary branching through depth 10 | 2047 | 0.002853 |
| Seeded random-drive 8x8 sandpile | 1000 | 0.035240 |

These measurements include collection of the complete output and are not peak-memory audits or real-time scheduling guarantees.

After the Pwindow ring-buffer cleanup, two additional local workloads measured:

| Workload | Outputs | Seconds |
| --- | ---: | ---: |
| Sliding size 64, step 1, source length 4096 | 4033 | 0.028929 |
| Size 1024, step 512, source length 20000 | 38 | 0.008729 |

These include output copying/collection and do not establish a speedup against the old implementation. The structural improvement is removal of repeated shifts of retained references.

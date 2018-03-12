---
vim: spell spelllang=en fo+=t tw=80
title: Concurrent Program Verification With Invariant-guided Underapproximation
author:
    - presented by Jan Mrázek
header-includes:
    - \usepackage{pgf, pgffor}
    - \usepackage{listings}
    - \usepackage{lstlinebgrd}
lang: english
date: 12th March 2018
...

## Bounded Model Checking

Basic idea of BMC for a system and a property $\phi$:

- unroll the system up to $k$-step
    - number of context switches
    - number of loop iteration
    - \...
- transition function of the unrolled system as SAT or SMT
- if $\neg\phi\wedge P$ is:
    - unsat, property holds up to $k$ steps
    - sat, property is violated

. . .

Observations:

- satisfiability check is the bottle neck
- solvers work the best when formula is under- or over-specified

## Main Idea

Add more constraints to overspecify the formula.

. . .

- good candidates: program invariants
- possible candidates: likely invariants

. . .

- simply add them to the conjunction
- the result might be underapproximation

## BMC Underapproximation

\centering
\includegraphics[page=4, clip, trim=4.5cm 15cm 10.5cm 3cm, width=0.8\textwidth]{paper1}

## Definition-Use Likely Invariants

- paper: Do I Use the Wrong Definition? (Yao Shi et. al.)
- tool DefUse

. . .

- invariants for reads and writes (load/store):
    - LR invariants
    - follower invariants
    - DSet invariants

- capturing likely invariants:
    - instrument a program
    - run it multiple times
    - collect data
    - statistically choose good candidates

## Local/Remote Invariant Motivation

\centering
\includegraphics[page=3, clip, trim=1.9cm 21.7cm 10.5cm 3.5cm, width=\textwidth]{paper2}

\centering
\includegraphics[page=3, clip, trim=11.1cm 21.7cm 1.9cm 3.5cm, width=\textwidth]{paper2}

## Local/Remote Invariant Motivation

\centering
\includegraphics[page=3, clip, trim=1.9cm 18.2cm 10.5cm 6.7cm, width=\textwidth]{paper2}

\centering
\includegraphics[page=3, clip, trim=11.1cm 18.2cm 1.9cm 6.7cm, width=\textwidth]{paper2}

## Local/Remote Invariant

\centering
\includegraphics[page=6, clip, trim=1.9cm 22.3cm 11.5cm 2cm, width=0.8\textwidth]{paper2}

- read should get data **only** from writes:
    - in the same threads
    - in other threads

## Follower Invariant Motivation

\centering
\includegraphics[page=3, clip, trim=1.9cm 14.9cm 10.5cm 10.2cm, width=\textwidth]{paper2}

\centering
\includegraphics[page=3, clip, trim=11.1cm 14.9cm 1.9cm 10.2cm, width=\textwidth]{paper2}

## Follower Invariant

\centering
\includegraphics[page=6, clip, trim=10cm 22.3cm 6.8cm 2cm, width=0.5\textwidth]{paper2}

- atomicity assumption
- two following reads should get data from the same write

## Definition Set Invariant Motivation

\centering
\includegraphics[page=3, clip, trim=1.9cm 11.8cm 10.5cm 13.3cm, width=\textwidth]{paper2}

\centering
\includegraphics[page=3, clip, trim=11.1cm 11.8cm 1.9cm 13.3cm, width=\textwidth]{paper2}

## Definition Set Invariant

\centering
\includegraphics[page=6, clip, trim=14.7cm 22.3cm 2cm 2cm, width=0.5\textwidth]{paper2}

- restricts the possible values a read can get
- define a set of writes

## Implementation

- instrument reads and writes in the verified program
    - PIR instrumentation framework
- run it with random inputs
    - possibly with guided thread scheduling: CHESS, CTrigger
- construct the likely invariants based on ranks

## Implementation Challenges

- monitored memory locations
    - granularity (DefUse: a byte)
    - memory location (DefUse: heap only)
- external definitions
    - external functions might loose invariants (`memset`, `memcpy`)
    - add annotation
- virtual address recycle
    - due to deallocations
    - intercept deallocation
- context sensitivity
    - small uninlined functions used by different threads
- training noise
    - incorrect oraculum

## Results

- 50 random inputs and random interleaving for invariant mining
- LI = tool from the paper
- NoR = encoding without unnecessary writes

\includegraphics[page=7, clip, trim=5.2cm 18.9cm 5cm 3.5cm, width=\textwidth]{paper1}

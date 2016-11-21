---
title: The SeaHorn Verification Framework
titleshort: SeaHorn
author:
    - Arie Gurfinkel
    - Temesghen Kahasai
    - Anvesh Komuravelli
    - Jorge A. Navas
authorshort: Arie Gurfinkel et al.
header-includes:
    - \usepackage{mathtools}
    - \newcommand{\columnsbegin}{\begin{columns}}
    - \newcommand{\columnsend}{\end{columns}}
    - \newcommand{\centerbegin}{\begin{center}}
    - \newcommand{\centerend}{\end{center}}
    - \setbeamertemplate{caption}{\raggedright\insertcaption\par}
lang: english
date: 21th November 2016
...

## SeaHorn

\columnsbegin

\column{.62\textwidth}

- LLVM-based verification framework
- safety properties (CAV 2015)
    - assertions
    - memory safety (simple heap)
- termination extension (TACAS 2016)
    - loop ranking function synthesis
- no concurrency support

- SV-COMP
    - 2016 bronze in Termination
    - 2015 gold in Simple
    - 2015 silver in DeviceDrivers, CF

\column{.38\textwidth}

![](logo.png)

\columnsend

## Architecture

![](architecture.png)

## Frontend

**Legacy front-end**

- C source code $\xrightarrow{GCC}$ CIL
- add stubs for built-ins (malloc)
- initialize all local variables (prevent optimizations)
- CIL $\xrightarrow{llvm-gcc}$ LLVM-bit code
- optimize
    - dead code
    - inline
    - aggregates into scalars

## Frontend

**Inter-procedural front-end**

- C source code $\xrightarrow{Clang}$ LLVM bitcode
- LLVM-to-LLVM transformations
    - optimizations
    - stubs for built-ins
    - lower `switch` to `if-then-else`
    - one exit block per function
    - move global initializers into `main`
    - lift assertions into `main`
    - buffer overflow instrumentation

## Lifting Assertions

**Allow assertions only in `main`**

- call to function P either:
    - fails and P does not return, or
    - P returns successfully

. . .

**Transformation**

- make copy of P body in main if P can fail
- replace assertions with assumes in original function
- when calling non-deterministically choose if P fails
    - if P fails, jump to copy
    - if P does not fail, call P

. . .

- reachability and non-termination preserved
- all function calls are safe $\rightarrow$ easy translation
- easier verification (context-sensitivity)

## Lifting Assertions

\includegraphics[page=6, clip, trim=4.5cm 20cm 4.5cm 4cm, width=\textwidth]{paper}

- make copy of P body in main if P can fail
- replace assertions with assumes in original function
- non-deterministically choose if P fails
- if P fails, jump to copy
- if P does not fail, call P

## Buffer Overflow Instrumentation

- idea: replace pointers with a structure:

     - ```C
        struct {
            void *p;
            size_t offset;
            size_t size;
        };
    ```
- replace `*p` with `*p.p` and add assertions:
    - `assert(p.offset >= 0)`
    - `assert(p.offset < p.size)`

## Middle-end

- translate LLVM to Constrained Horn Clauses (CHC)
    - specifies semantics of the language and verification precision
    - small step encoding vs. large block encoding
- included translations:
    - registers only in Linear Integer Arithmetics (LIA)
    - registers + pointers (without content) in LIA
    - registers + pointers + memory in LIA with array theory
- function calls are problematic:
    - inlining (assert lifting)
    - interprocedural translation

## Constrained Horn Clauses (CHC)

- sets $\mathcal{F}$ of functions, $\mathcal{P}$ of predicates and $\mathcal{V}$ of variables
- CHC is a formula: $\forall\mathcal{V}(\varphi\wedge p_1[X_1]\wedge\cdots\wedge p_k[X_k]\rightarrow h[X])$
    - $\varphi$: a constraint over $\mathcal{F}$ and $\mathcal{V}$ with respect to a  theory
    - $X_i$: vectors of variables
    - $p, h$: predicates
- usually written as $h[X] \leftarrow\varphi,p_1[X_1],\cdots, p_k[X_k]$
    - head $\leftarrow$ body
    - empty body = fact
    - otherwise = rule
- satisfiable if there exist an interpretation of $\mathcal{P}$ s.t. $\varphi$ is true
- reachability can be encoded

## Simple Translation

**No failing function calls, small-step encoding**

- encode rechability of a single error location

. . .

- construct control flow-graph (LLVM basic blocks)
- add self-loop for end nodes
- add node for error location
- for each transition, construct a CHC:
    - reachability of a CF location with variables' valuation
    - constraints model variables' valuation transformation

. . .

- verification = satisfiability of CHC for error location

## Simple Translation

\includegraphics[page=7, clip, trim=4.5cm 17cm 4.5cm 4cm, width=\textwidth]{paper}

## Interprocedural Translation

- inlining of procedures can lead to an exponential blowup
- assertion lifting breaks for recursion and indirect branches

. . .

**Interprocedural translation**

- similar to simple translation
    - encode reachability of a single error location
- summary rule for each function call
- cannot "jump" to error location from multiple locations
- need to propagate errors back
    - 2 extra flag parameters for summary rules
    - flag 1 if error occurred before call
    - flag 2 if error occurred in the call
    - propagate error back to main

## Interprocedural Translation

\centering
\includegraphics[page=9, clip, trim=4.5cm 15cm 5cm 4cm, width=\textwidth]{paper}

## Back-end

- satisfiability of a set of CHC
- any solver supporting CHC can be used
    - BMC
    - SMT-based approach (SPACER)
    - abstract interpretation-based approach (IKOS)
    - IC3-based approach
    - ...

## Conclusion

\columnsbegin

\column{.62\textwidth}

**SeaHorn Verification Framework**

- C $\rightarrow$ LLVM $\rightarrow$ LLVM $\rightarrow$ CHC
- CHC verification using:
    - SMT-based
    - AI-based
- strenghts:
    - fast verification (`mnav` verification)
    - can synthetize numerical invariants
- weaknesses:
    - limited heap (no linked structures)
    - no concurrency

\column{.38\textwidth}

![](logo.png)

\columnsend

. . .

**Unpublished work:** executable witnesses, new backend

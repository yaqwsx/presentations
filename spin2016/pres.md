---
title: SymDIVINE
subtitle: Tool for Control-Explicit Data-Symbolic State Space Exploration
titleshort: SymDIVINE
author:
    - Jan Mrázek
    - Petr Bauch
    - Henrich Lauko
    - Jiří Barnat
authorshort: Mrázek J., Bauch P., Lauko H., Barnat J.
header-includes:
    - \usepackage{divine}
    - \usepackage{multirow}
    - \usepackage{tikz}
    - \usepackage{graphicx}
    - \usetikzlibrary{shapes, arrows, shadows, positioning, calc, fit, backgrounds, decorations.pathmorphing}
    - \usetikzlibrary{trees}
    - \newcommand{\LTLg} {\mathcal{G}}
    - \newcommand{\LTLf} {\mathcal{F}}
lang: english
date: 8th April 2016
aspectratio: 169
...

# Motivation

## DIVINE

- tool produced by ParaDiSe Laboratory

- explicit-state model checker with a focus on verification of real-world parallel C/C++ code

- can verify:

    - safety properties (memory safety, assertion safety)

    - LTL properties
  
- efficiently utilizes all available resources to speed up the verification
  tasks
  
. . .

- can be used as a runtime for unit tests of parallel code
    - complete standard C/C++ library
    
    - detection of all race conditions
    
    - memory safety with greater precision than Valgrind

- for more details see http://divine.fi.muni.cz/

## Why "Another DIVINE"?

DIVINE is an **explicit** model checker

- verified code cannot have non-deterministic input

- sufficient for unit tests of parallel programs

. . .

We would like to make it more powerful:

- allow non-deterministic values $\rightarrow$ verify all runs for all possible input values

- keep the ideology of DIVINE
    - real-world code verification with no manual modifications
    
    - precise verification (bit-precise math operations, detection of all race conditions)


## Example

```C
std::vector<int> data;
for (size_t i = 0; i != 42; i++)
    data.push_back(24);
assert(data.size() == 42); // Safe
data.erase(data.begin() + 12);
assert(data.size() == 41); // Safe
```

. . .

Ideal situation:

```C
std::vector<int> data; size_t SIZE = nondet(); assume(SIZE > 0)
for (size_t i = 0; i != SIZE; i++)
    data.push_back(nondet());
assert(data.size() == SIZE); // Safe
data.erase(data.begin() + nondet()); // Possible memory corruption
assert(data.size() == SIZE - 1);
```

# SymDIVINE

## Short Overview

- Control-Explicit Data-Symbolic model checker for parallel C/C++ programs

    - assertion safety
    
    - LTL properties

- **can verify programs with nondeterministic values**

- bitprecise verification

- prototype under development

- can be downloaded at [https://github.com/yaqwsx/SymDivine](https://github.com/yaqwsx/SymDivine)

## Verification Workflow

ToDo: Úžasný obrázek s Cčkovským kódem, clangem, llvmkem a SymDIVINEm. 

## Control-Explicit Data-Symbolic approach

Combination of ideas of symbolic execution and explicit model-checking.

Main idea: keep control flow explicit, treat data symbolically when exploring the state space.

- state-space of verified program consists of multi-states

- each multi-state represents a single control flow location and a set
  of possible data valuations
  
    - one multi-state represents multiple explicit states (set-based reduction)
  
- set of data valuations can be represented by:
    
    - BDDs
    
    - SMT formulae

- **it is possible to decide whether two states represent the same
  data valuation**
  
- these properties of multi-states allows us to reuse existing algorithms
  from explicit model checking

## Set-based Reduction

    int a = __VERIFIER_nondet_int();
    if (a < 65535) {
        ...
    }
    else {
        ...
    }
        
\pause

    %a = call i32 @__VERIFIER_nondet_int()
    %b = icmp sge i32 %a, 65535
    br i1 %b, label %5, label %6
    
## Set-based Reduction

DIVINE

\begin{latex}
\begin{center}
\resizebox{0.7 \textwidth}{!}{
\begin{tikzpicture}[]
    \tikzstyle{every node}=[align=center, minimum width=1.75cm, minimum height=0.6cm]
    \tikzset{empty/.style = {minimum width=0cm,minimum height=1cm}}
    \tikzset{tnode/.style = {rectangle,draw=black!50,fill=black!10,thick}}
    \tikzset{dots/.style = {draw=none}}
    \tikzset{>=latex}
    \tikzstyle{outer}=[draw, dotted, thick]
    
    \tikzstyle{wave}=[decorate, decoration={snake, post length=0.1 cm}]
    %divine
    \node [tnode] (s) {\texttt{init}};
    \node [right = 2cm of s] (mid) {};
    
    \node [tnode, above = -0.25 cm of mid, minimum width=2cm] (s65534){\texttt{a = 65534}};
    \node [tnode, below = -0.25 cm of mid, minimum width=2cm] (s65535){\texttt{a = 65535}};
    
    \node [dots, above = 0 cm of s65534] (dots1){\LARGE$\vdots$};
    \node [dots, below = -0.2 cm of s65535] (dots2){\LARGE$\vdots$};
    
    \node [tnode, above = -0.2 cm of dots1, minimum width=2cm] (s0) {\texttt{a = 0}};
    \node [tnode, below = 0 cm of dots2, minimum width=2cm] (sn) {\texttt{a = 2\textasciicircum32}};
    
    \node [tnode, right = 1.5 cm of s65534, minimum width=3cm] (s65534_icmp){\texttt{a = 65534; b = 0}};
    \node [tnode, right = 1.5 cm of s65535, minimum width=3cm] (s65535_icmp){\texttt{a = 65535; b = 1}};
    
    \node [dots, above = 0.0 cm of s65534_icmp] (dots1_icmp){\LARGE$\vdots$};
    \node [dots, below = -0.2 cm of s65535_icmp] (dots2_icmp){\LARGE$\vdots$};
    
    \node [tnode, right = 1.5 cm of s0, minimum width=3cm] (s0_icmp) {\texttt{a = 0; b = 0}};
    \node [tnode, right = 1.5 cm of sn, minimum width=3cm] (sn_icmp) {\texttt{a = 2\textasciicircum32; b = 1}};
        
    \node [empty, left  = 1 cm of s]  (start) {};
    \node [empty, right = 1 cm of s0_icmp] (s0end) {};
    \node [empty, right = 1 cm of s65534_icmp] (s65534end) {};
    \node [empty, right = 1 cm of s65535_icmp] (s65535end) {};
    \node [empty, right = 1 cm of sn_icmp] (snend) {};
    
    \begin{pgfonlayer}{background}[]
    \node[outer, fit = (s) (s0) (sn) (start) (s0end) (snend) (s0_icmp)] (tool) {};
    \end{pgfonlayer}

    \draw [->] (s.east) -| ($(s.east) !0.3! (s0.west)$) |- (s0.west) node [near end, above=1pt] {\texttt{call}} ;
    \draw [->] (s.east) -| ($(s.east) !0.3! (s65534.west)$) |- (s65534.west) node [near end, above=1pt] {\texttt{call}} ;;
    \draw [->] (s.east) -| ($(s.east) !0.3! (s65535.west)$) |- (s65535.west) node [near end, above=1pt] {\texttt{call}} ;
    \draw [->] (s.east) -| ($(s.east) !0.3! (sn.west)$) |- (sn.west) node [near end, above=1pt] {\texttt{call}} ;
    
    \draw [->] (s0) -- (s0_icmp) node [midway, above=0pt] {\texttt{icmp}};
    \draw [->] (s65534) -- (s65534_icmp) node [midway, above=0pt] {\texttt{icmp}};
    \draw [->] (s65535) -- (s65535_icmp) node [midway, above=0pt] {\texttt{icmp}};
    \draw [->] (sn) -- (sn_icmp) node [midway, above=0pt] {\texttt{icmp}};
    
    \draw [wave, ->] (s0_icmp.east) -- (s0end) node [empty, midway, above=2pt] {};
    \draw [wave, ->] (s65534_icmp.east) -- (s65534end) node [empty, midway, above=2pt] {};
    \draw [wave, ->] (s65535_icmp.east) -- (s65535end) node [empty, midway, above=2pt] {};
    \draw [wave, ->] (sn_icmp.east) -- (snend) node [empty, midway, above=2pt] {};
    
    \draw [wave, ->] (start) -- (s);
\end{tikzpicture}
}
\end{center}
\end{latex}

SymDIVINE

\begin{latex}
\begin{center}
    \resizebox{0.7\textwidth}{!}{
    \begin{tikzpicture}[]
      \tikzstyle{every node}=[align=center, minimum width=1.75cm, minimum height=0.6cm]
      \tikzset{empty/.style = {minimum width=0cm,minimum height=1cm}}
      \tikzset{tnode/.style = {rectangle,draw=black!50,fill=black!10,thick,align=left}}
      \tikzset{dots/.style = {draw=none}}
      \tikzset{>=latex}
      \tikzstyle{outer}=[draw, dotted, thick]
      
      \tikzstyle{wave}=[decorate, decoration={snake, post length=0.1 cm}]  
      %symdivine
      \node [tnode] (s_sym) {\texttt{init}};
      \node [tnode, right = 1.2 cm of s_sym, minimum width=2cm] (s_nd_sym) {\texttt{a = \{0,\dots,2\textasciicircum32\}}};
      
      \node [empty, right = 3cm of s_nd_sym] (mid_sym) {};
       
      \node [tnode, above = -0.45 cm of mid_sym, minimum width=3.7cm] (s1_sym) { \texttt{a = \{0,\dots,65534\}}\\\texttt{b = \{0\}}};
      \node [tnode, below = -0.45 cm of mid_sym, minimum width=3.7cm] (s2_sym){\texttt{a = \{65535,\dots,2\textasciicircum32\}}\\\texttt{b = \{1\}}};
            
      \node [empty, left  = 0.75 cm of s_sym]  (start_sym) {};
      \node [empty, right = 0.75 cm of s1_sym] (s1end_sym) {};
      \node [empty, right = 0.75 cm of s2_sym] (s2end_sym) {};
      
      \begin{pgfonlayer}{background}[]
      	\node[outer, fit = (s_sym) (s1_sym) (s2_sym) (start_sym) (s1end_sym) (s2end_sym)] (tool) {};
      \end{pgfonlayer}
	  
      \draw [->] (s_sym.east) -- (s_nd_sym.west) node [midway, above=0pt] {\texttt{call}};
      
      \draw [->] (s_nd_sym.east) -| ($(s_nd_sym.east) !0.2! (s1_sym.west)$) |- (s1_sym.west) node [near end, above=0pt] {\texttt{icmp}};
      \draw [->] (s_nd_sym.east) -| ($(s_nd_sym.east) !0.2! (s2_sym.west)$) |- (s2_sym.west) node [near end, above=0pt] {\texttt{icmp}};
      
      \draw [wave, ->] (start_sym) -- (s_sym);
      \draw [wave, ->] (s1_sym) -- (s1end_sym);
      \draw [wave, ->] (s2_sym) -- (s2end_sym);
      
    \end{tikzpicture}
    }
\end{center}
\end{latex}

## Input Language Overview

SymDIVINE supports LLVM as an input formalism

- in theory any programming language with LLVM frontend is supported

    - tested only with C and C++

- subset of pthread library (threads, mutexes) is supported

- SV-COMP notation adopted

    - input represented by \texttt{\_\_VERIFIER\_nondet\_\{type\}} functions

    - atomic sections of code can be represented by \texttt{\_\_VERIFIER\_atomic\_\{begin,end\}} functions

- C-style assertions are supported

## Input Language Restriction

- SymDIVINE supports almost all LLVM instructions except:
    - floating point instructions
    
    - bitcast instructions
    
    - exceptions
    
- SymDIVINE does not support:
    - heap allocation (malloc, operator new)
    
    - symbolic pointers

# Demonstration

## Example of Usage -- Assertion Reachability

- benchmark \texttt{stateful01\_true-unreach-call}

- call \texttt{./symdivine reachability stateful01\_true-unreach-call.ll}

## Example of Usage -- LTL

- benchmark \texttt{acqrel}

- property $\mathcal{G}(A\Rightarrow\mathcal{F}R)$ (property can refer to any global variable)

 - call \texttt{./symdivine ltl "G([seg1\_off1 != 0(32)] => F [seg1\_off0 != 0(32)])" acqrel.ll}
 
# Benchmarks & Results

## Benchmarking Overview

- we have benchmarked SymDIVINE on:
    - C benchmarks by Byron Cook (for LTL)
    
    - SV-COMP Concurrency set (for reachability)

## LTL Properties Verification Results

C benchmarks by Byron Cook

\begin{table}[]
\centering
\begin{tabular}{cc|c|c|c|c|}
\cline{3-6}
                                                 &                                       & \multicolumn{2}{c|}{Iterative deepening DFS}  & \multicolumn{2}{c|}{Simple DFS} \\ \cline{3-6} 
                                                 &                                       & -O0                   & -O2                   & -O0            & -O2            \\ \hline\hline
\multicolumn{1}{|c|}{\multirow{2}{*}{acqrel}}    & $\LTLg(a\Rightarrow\LTLf b)$          & $>120 s$              & $>120 s$              & $>120 s$       & $>120 s$       \\ \cline{2-6} 
\multicolumn{1}{|c|}{}                           & $\neg\LTLg(a\Rightarrow\LTLf b)$      & $8.79 s$              & $0.57 s$              & $>120 s$       & $0.55 s$       \\ \hline\hline
\multicolumn{1}{|c|}{\multirow{2}{*}{apache}}    & $\LTLg(a\Rightarrow\LTLg\LTLf b)$     & $>120 s$              & $13.39 s$             & $>120 s$       & $97.92 s$      \\ \cline{2-6} 
\multicolumn{1}{|c|}{}                           & $\neg\LTLg(a\Rightarrow\LTLg\LTLf b)$ & $>120 s$              & $12.60 s$             & $>120 s$       & $>120 s$       \\ \hline\hline
\multicolumn{1}{|c|}{\multirow{2}{*}{pgarch}}    & $\LTLg\LTLf a$                        & $12.69 s$             & $6.33 s$              & $>120 s$       & $6.43 s$       \\ \cline{2-6} 
\multicolumn{1}{|c|}{}                           & $\neg\LTLg\LTLf a$                    & $3.76 s$              & $1.19 s$              & $5.81 s$       & $1.13 s$       \\ \hline\hline
\multicolumn{1}{|c|}{\multirow{2}{*}{win1}}      & $\LTLg(a\Rightarrow\LTLf a)$          & $>120 s$              & $>120 s$              & $>120 s$       & $>120 s$       \\ \cline{2-6} 
\multicolumn{1}{|c|}{}                           & $\neg\LTLg(a\Rightarrow\LTLf a)$      & $6.29 s$              & $0.71 s$              & $>120 s$       & $0.68 s$       \\ \hline\hline
\multicolumn{1}{|c|}{\multirow{2}{*}{win3}}      & $\LTLf\LTLg a$                        & $1.58 s$              & $1.26 s$              & $1.39 s$       & $1.00 s$       \\ \cline{2-6} 
\multicolumn{1}{|c|}{}                           & $\neg\LTLf\LTLg a$                    & $2.16 s$              & $2.13 s$              & $2.39 s$       & $1.68 s$       \\ \hline
\end{tabular}
\end{table}


## SV-COMP Results

- SV-COMP 2016 score: -136

- later after small bugfixes we achieved score up to 400 
    - false results caused by inling of `__VERIFIER_atomic_*` functions
    
    - absence of atomic sections caused state-space explosion and we usually run out of memory

. . .

- both our tools were submited for SV-COMP

- expectations: SymDIVINE beats DIVINE -- DIVINE cannot handle non-deterministic input well

. . .

- DIVINE score: 951

## SV-COMP: DIVINE vs. SymDIVINE

Why did DIVINE beat SymDIVINE at SV-COMP?

. . .

SV-COMP Concurrency benchamarks contain a little or none non-determinism

- DIVINE is up to 500× faster than SymDIVINE on benchmarks with no non-determinism
  (no multistates are used when no non-determinism is present)

- models with single (or more) 32bit input values cannot be verified by DIVINE, SymDIVINE
  handles them well

## State Equality -- Is It Worth It?

Disadvantages:

- one of the most expensive operations

- bigger the state space, the more costly the equality is

- almost no benefits for single-threaded programs

. . .

Advantages:

- easy adaptation of classic model checking algorithms (LTL BA model checking)

- huge state space reduction for parallel programs (up to 95 %)

- can verify programs with infinite behavior unlike symbolic execution

# Conclusion

## Advantages of SymDIVINE

Compared to explicit model checkers:

- non-deterministic input can be handled

. . .

Compared to classic symbolic model checkers:

- real world code verification with no need for modelling

. . .

Compared to symbolic execution:

- can verify programs with infinite behavior

. . .

Other verification tools for C/C++ code:

- bitprecise verification

    - other tools often use integral instead of bitvector representation
    
- atomicity level on LLVM instructions (`i++` on shared variable is not atomic)

- in theory no false positives nor false negatives

## Disadvantages of SymDIVINE

- it is a prototype tool for proof-of-concept:
    - no support for LLVM debug information: counterexamples and properties are
      referred to LLVM code and internal representation of the multistates
    
    - no advanced optimizations (strong $\tau$-reduction, memory compression etc.)

- no support for symbolic pointer arithmetics and dynamic memory (yet)

- some loops that depend on an input value may need unrolling

- possible state space explosion

## Conclusion & Future work

- SymDIVINE's approach to verification of program with input was proofed to be
  working quite well, however it lacks strong background for:

    - full LLVM support & its efficient execution
    
    - dynamic memory
    
    - counterexamples refering to source code

. . .

Future plans:

- merge SymDIVINE into DIVINE

- implement loop analysis techniques

- add support for symbolic pointers 

. . .

SymDIVINE can be downloaded at [https://github.com/yaqwsx/SymDivine](https://github.com/yaqwsx/SymDivine)

. . .

Thank you

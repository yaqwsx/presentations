---
title: SymDIVINE
subtitle: Tool for Control-Explicit Data-Symbolic State Space Exploration
titleshort: SymDIVINE
author:
    - "**Jan Mrázek**"
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

- tool produced by the ParaDiSe Laboratory

- explicit-state model checker which focuses on real-world parallel C/C++ code

- can verify:

    - safety properties (memory safety, assertion safety, ...)

    - LTL properties
  
- efficient utilization of all available resources

. . .

- unit tests verification of parallel code
    - complete standard C/C++ library
    
    - detection of race conditions
    
    - memory safety with greater precision than Valgrind

- for more details see http://divine.fi.muni.cz/

## Why "Another DIVINE"?

DIVINE is an **explicit-state** model checker

- non-deterministic input causes enormous state-space explosion $\rightarrow$ in practise no or bounded input

- sufficient for unit tests of parallel programs

. . .

We would like to make it more powerful:

- allow non-deterministic values $\rightarrow$ verify all runs for all possible input values

- keep the ideology of DIVINE
    - real-world code verification with no manual modifications
    
    - precise verification (bit-precise math operations, detection of race conditions)
    
    - effect of compiler optimizations


## Motivation Example

```CPP
std::vector<int> data;
for (size_t i = 0; i != 42; i++)
    data.push_back(24);
assert(data.size() == 42); // Safe
data.erase(data.begin() + 12);
assert(data.size() == 41); // Safe
```

. . .

Ideal situation:

```CPP
std::vector<int> data; size_t SIZE = nondet(); assume(SIZE > 0)
for (size_t i = 0; i != SIZE; i++)
    data.push_back(nondet());
assert(data.size() == SIZE); // Safe
data.erase(data.begin() + nondet()); // Possible memory corruption
assert(data.size() == SIZE - 1);
```

# SymDIVINE

## Short Overview

- control-explicit data-symbolic model checker for parallel C/C++ programs

    - assertion safety
    
    - LTL properties

- **can verify programs with nondeterministic values**

- bitprecise verification

- prototype under development

- [https://github.com/yaqwsx/SymDivine](https://github.com/yaqwsx/SymDivine)

## Verification Workflow

\begin{latex}
    \medskip
    \footnotesize
    \makebox[\textwidth][c]{
    \begin{tikzpicture}[ ->, >=stealth', shorten >=1pt, auto, node distance=3cm
                       , semithick
                       , scale=0.7
                       , state/.style={ rectangle, draw=black, very thick,
                         minimum height=2em, minimum width = 4em, inner
                         sep=2pt, text centered, node distance = 2em }
                       ]

      \node[state, anchor = north west] (cpp) {C/C++};
      \node[state, right = 4em of cpp, rounded corners] (clang) {Clang};
      \node[state, right = 4em of clang] (llvm) {LLVM IR};
      \node[state, right = 4em of llvm, rounded corners] (divine) {SymDIVINE};

      \node[state, above = of divine.north, minimum width = 15em] (ltl) {Verified property: reachability, LTL};
      \node[state, right = of divine, anchor = west, minimum width = 8em] (valid) {\color{paradisegreen!70!black}OK};
      \node[state, below = of valid, minimum width = 8em] (ce) {\color{red!70!black}Counterexample};

      \path (ltl.south) edge (divine.north)
            (cpp) edge (clang)
            (clang) edge (llvm)
            (llvm) edge (divine)
            (divine) edge (valid) edge[out=0,in=180] (ce)
            ;
    \end{tikzpicture}
    }
\end{latex}

```{.bash}
echo clang -S $CFLAGS -emit-llvm -o model.ll model.c
symdivine reachability model.ll
symdivine ltl `cat property.ltl` model.ll
```

## Control-Explicit Data-Symbolic approach

- ideas from symbolic execution and explicit-state model-checking

. . .

Main idea: control flow explicit, data symbolic

- multi-state: single control flow location and a set of possible data valuations
  
    - one multi-state represents multiple explicit states (set-based reduction)
    
    - multiple multi-states per single control flow location
  
- set of data valuations represented by:
    
    - BDDs (does not work well in practise)
    
    - SMT formulae

- **decision procedure for data valuations equality** (quantified SMT query)

. . .

Multi-state equality allows us to reuse algorithms from explicit-state model checking

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

\begin{latex}
\begin{center}
\resizebox{0.95 \textwidth}{!}{
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
    \node [above = 0.2cm  of s] (lab) {DIVINE};
    \node [right = 2cm of s] (mid) {};
    
    \node [tnode, above = -0.25 cm of mid, minimum width=2.2cm] (s65534){\texttt{a = 65534}};
    \node [tnode, below = -0.25 cm of mid, minimum width=2.2cm] (s65535){\texttt{a = 65535}};
    
    \node [dots, above = 0 cm of s65534] (dots1){\LARGE$\vdots$};
    \node [dots, below = -0.2 cm of s65535] (dots2){\LARGE$\vdots$};
    
    \node [tnode, above = -0.2 cm of dots1, minimum width=2.2cm] (s0) {\texttt{a = 0}};
    \node [tnode, below = 0 cm of dots2, minimum width=2.2cm] (sn) {\texttt{a = $2^{32}-1$}};
    
    \node [tnode, right = 1.5 cm of s65534, minimum width=4.2cm] (s65534_icmp){\texttt{a = 65534; b = 0}};
    \node [tnode, right = 1.5 cm of s65535, minimum width=4.2cm] (s65535_icmp){\texttt{a = 65535; b = 1}};
    
    \node [dots, above = 0.0 cm of s65534_icmp] (dots1_icmp){\LARGE$\vdots$};
    \node [dots, below = -0.2 cm of s65535_icmp] (dots2_icmp){\LARGE$\vdots$};
    
    \node [tnode, right = 1.5 cm of s0, minimum width=4.2cm] (s0_icmp) {\texttt{a = 0; b = 0}};
    \node [tnode, right = 1.5 cm of sn, minimum width=4.2cm] (sn_icmp) {\texttt{a = $2^{32}-1$; b = 1}};
        
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

\begin{latex}
\begin{center}
    \resizebox{0.95\textwidth}{!}{
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
      \node [above = 0.2cm  of s_sym] (lab_sym) {SymDIVINE};
      \node [tnode, right = 1.2 cm of s_sym, minimum width=2cm] (s_nd_sym) {\texttt{a = \{0,\dots,$2^{32}-1$\}}};
      
      \node [empty, right = 3.5cm of s_nd_sym] (mid_sym) {};
       
      \node [tnode, above = -0.45 cm of mid_sym, minimum width=4.6cm] (s1_sym) { \texttt{a = \{0,\dots,65534\}}\\\texttt{b = \{0\}}};
      \node [tnode, below = -0.45 cm of mid_sym, minimum width=4.6cm] (s2_sym) { \texttt{a = \{65535,\dots,$2^{32}-1$\}}\\\texttt{b = \{1\}}};
            
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

## State Equality

ToDo

## Input Language Overview

SymDIVINE supports LLVM as an input formalism

- in theory supports any programming language with LLVM frontend

    - tested only with C and C++

- subset of pthread library (threads, mutexes)

- SV-COMP notation adopted

    - input represented by \texttt{\_\_VERIFIER\_nondet\_\{type\}} functions

    - atomic sections of code can be represented by \texttt{\_\_VERIFIER\_atomic\_\{begin,end\}} functions

- C-style assertions are supported

## Input Language Restriction

SymDIVINE cannot handle input code with:

- heap allocation (malloc, operator new)

- pointer casts

- symbolic pointers

- exceptions

- floating point arithmetics

## Property Verification

Assertion safety

- reachability of error states (assertion does not hold)

- exhaustive enumeration of multi-state space
    - the same states are merged (may become costly in theory)
    
    - all thread interleavings ($\tau$-reduction incorporated)
    
. . .

LTL

- standard automata-based algorithm (iterative Nested DFS)

- atomic propositions
    - can refer to any global variable
    
    - can contain arithmetic operations, relations operators (eg. $x+y > 5$)

## State Equality -- Is It Worth It?

Disadvantages (compared to symbolic execution):

- expensive operation

- almost no benefits for single-threaded programs with finite behavior

. . .

Advantages (compared to symbolic execution):

- easy adaptation of classic model checking algorithms (LTL)

- each state is visited only once -- up to 98 % reduction compared to exploration without merging 

- can verify programs with infinite behavior

. . .

In practise only small number of multi-states per control-flow location ($<20$), so advantages outweight disadvantages
 
# Benchmarks & Results

## Benchmarking Overview

- we have benchmarked SymDIVINE on:
    - C benchmarks by Byron Cook (for LTL)
    
    - SV-COMP Concurrency set (for reachability)

## LTL Properties Verification Results

C benchmarks by Byron Cook

\begin{table}[]
\centering
\begin{tabular}{cc|c|c|}
\cline{3-4}
                                              &                                       & -O0                   & -O2                  \\ \hline
\multicolumn{1}{|c|}{\multirow{2}{*}{acqrel}} & $\LTLg(a\Rightarrow\LTLf b)$          & $>120 s$              & $>120 s$             \\ \cline{2-4} 
\multicolumn{1}{|c|}{}                        & $\neg\LTLg(a\Rightarrow\LTLf b)$      & $8.79 s$              & $0.57 s$             \\ \hline
\multicolumn{1}{|c|}{\multirow{2}{*}{apache}} & $\LTLg(a\Rightarrow\LTLg\LTLf b)$     & $>120 s$              & $13.39 s$            \\ \cline{2-4} 
\multicolumn{1}{|c|}{}                        & $\neg\LTLg(a\Rightarrow\LTLg\LTLf b)$ & $>120 s$              & $12.60 s$            \\ \hline
\multicolumn{1}{|c|}{\multirow{2}{*}{pgarch}} & $\LTLg\LTLf a$                        & $12.69 s$             & $6.33 s$             \\ \cline{2-4} 
\multicolumn{1}{|c|}{}                        & $\neg\LTLg\LTLf a$                    & $3.76 s$              & $1.19 s$             \\ \hline
\multicolumn{1}{|c|}{\multirow{2}{*}{win1}}   & $\LTLg(a\Rightarrow\LTLf a)$          & $>120 s$              & $>120 s$             \\ \cline{2-4} 
\multicolumn{1}{|c|}{}                        & $\neg\LTLg(a\Rightarrow\LTLf a)$      & $6.29 s$              & $0.71 s$             \\ \hline
\multicolumn{1}{|c|}{\multirow{2}{*}{win3}}   & $\LTLf\LTLg a$                        & $1.58 s$              & $1.26 s$             \\ \cline{2-4} 
\multicolumn{1}{|c|}{}                        & $\neg\LTLf\LTLg a$                    & $2.16 s$              & $2.13 s$             \\ \cline{2-4} \hline
\end{tabular}
\end{table}

. . .

DIVINE can verify only win3 benchmark (with nearly the same time), others cause timeout or memory overflow.

## SV-COMP Results

- SV-COMP 2016 score: $-136$

- later after small bugfixes we achieved score up to 400 
    - wrong results caused by inling of `__VERIFIER_atomic_*` functions
    
    - absence of atomic sections caused state-space explosion

. . .

- both our tools were submited for SV-COMP

. . .

- DIVINE score: 951

## SV-COMP: DIVINE vs. SymDIVINE


SV-COMP Concurrency benchamarks contain a little or none non-determinism

- DIVINE up to 500× faster than SymDIVINE on benchmarks with no non-determinism
  (no non-determinism $\rightarrow$ no multi-states nor SMT solver calls)

- models with integral input values
    - cannot be verified by DIVINE in reasonable time and memory
    
    - can be easily verified by SymDIVINE
  
. . .

SV-COMP benchmarks exploits mainly technical imperfections of SymDIVINE, not its approach

# Conclusion

## Advantages of SymDIVINE

Compared to explicit-state model checkers:

- non-deterministic input can be handled

. . .

Compared to symbolic execution:

- can verify programs with infinite behavior
- more efficient on parallel programs

. . .

Other verification tools for C/C++ code:
    
- atomicity level on LLVM instructions (closely matches real-world architectures)

- in theory no false positives nor false negatives

## Disadvantages of SymDIVINE

- a prototype tool for proof-of-concept:
    - no support for LLVM debug information: counterexamples and properties
      refer to LLVM code and internal representation of the multistates
    
    - no advanced optimizations (strong $\tau$-reduction, memory compression etc.)

- no support for symbolic pointer arithmetics and dynamic memory (yet)

- some loops that depend on an input value may need unrolling $\rightarrow$ possible state space explosion

## Conclusion & Future work

SymDIVINE's approach to verification of program with input was proofed to 
work quite well, however it lacks strong background for:

- full LLVM support & its efficient execution

- counterexamples refering to source code

. . .

Future plans:

- merge SymDIVINE into DIVINE

- implement loop analysis techniques

- add support for symbolic pointers 

. . .

SymDIVINE can be downloaded at [https://github.com/yaqwsx/SymDivine](https://github.com/yaqwsx/SymDivine)

. . .

\hfill Thank you

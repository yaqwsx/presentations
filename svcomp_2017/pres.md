---
title: "Optimizing and Caching SMT Queries in SymDIVINE"
titleshort: SymDIVINE
author:
    - Jan Mrázek
    - Martin Jonáš
    - Vladimír Štill
    - Henrich Lauko
    - Jiří Barnat
header-includes:
    - \usepackage{divine}
    - \usepackage{multirow}
    - \usepackage{tikz}
    - \usepackage{graphicx}
    - \usepackage{pbox}
    - \usepackage{booktabs}
    - \usepackage{siunitx}
    - \usetikzlibrary{shapes, arrows, shadows, positioning, calc, fit, backgrounds, decorations.pathmorphing}
    - \usetikzlibrary{trees}
    - \setbeamertemplate{caption}{\raggedright\insertcaption\par}
    - \newcommand{\columnsbegin}{\begin{columns}}
    - \newcommand{\columnsend}{\end{columns}}
    - \newcommand{\centerbegin}{\begin{center}}
    - \newcommand{\centerend}{\end{center}}
lang: english
date: 27th April 2017
aspectratio: 169
...


## SymDIVINE

- verification tool for C/C++ multi-threaded programs via LLVM

- control-explicit data-symbolic approach

```{.C}
unsigned a = input(); if (a >= 42) { ... } else { ... }
```

\begin{center}
    \resizebox{\textwidth}{!}{
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
      \node [tnode, right = 1.2 cm of s_sym, minimum width=2cm] (s_nd_sym) {\texttt{a = \{0,\dots,$2^{32}-1$\}}};

      \node [empty, right = 4.5cm of s_nd_sym] (mid_sym) {};

      \node [tnode, above = -0.45 cm of mid_sym, minimum width=4.6cm, align=right] (s1_sym) { \texttt{a = \{0,\dots,41\}}\\\texttt{br = \{false\}}};
      \node [tnode, below = -0.45 cm of mid_sym, minimum width=4.6cm] (s2_sym) { \texttt{a = \{42,\dots,$2^{32}-1$\}}\\\texttt{br = \{true\}}};

      \node [empty, left  = 0.75 cm of s_sym]  (start_sym) {};
      \node [empty, right = 0.75 cm of s1_sym] (s1end_sym) {};
      \node [empty, right = 0.75 cm of s2_sym] (s2end_sym) {};



      \draw [->] (s_sym.east) -- (s_nd_sym.west) node [midway, above=0pt] {\texttt{input}};

      \draw [->] (s_nd_sym.east) -| ($(s_nd_sym.east) !0.2! (s1_sym.west)$) |- (s1_sym.west) node [near end, above=0pt] {\texttt{a < 42}};
      \draw [->] (s_nd_sym.east) -| ($(s_nd_sym.east) !0.2! (s2_sym.west)$) |- (s2_sym.west) node [near end, above=0pt] {\texttt{a >= 42}};

      \draw [wave, ->] (start_sym) -- (s_sym);
      \draw [wave, ->] (s1_sym) -- (s1end_sym);
      \draw [wave, ->] (s2_sym) -- (s2end_sym);

    \end{tikzpicture}
    }
\end{center}

. . .

**Goal: Optimize state representation and related machinery**

## Set Representation and Related Machinery

Multiple possible state representations: intervals, BDDs, **formulas**

. . .

- first order logic formula $\varphi$ represents a set of memory configurations
- emptiness test
    - quantifier-free query to an SMT solver
    - fairly cheap

- equality test
    - quantified query to an SMT solver
    - expensive


## Optimizing Equality Queries in SymDIVINE

**Caching**

- naive approach has no effect $\rightarrow$ need for smaller queries
- approaches inspired by symbolic execution  do not work
- formula slicing
    - leverage fixed query format and pre-computed data dependencies
    - split state representation into multiple independent parts

. . .

**Simplifications**

- observation: SSA form of LLVM $\rightarrow$ many unconstrained variables
- incorporate simplification from the SMT solver Q3B

## Future of SymDIVINE

SymDIVINE

- is a prototype of the CEDS approach
- shown advantages and limits of the CEDS approach
- suffers from implementation imperfections

. . .

Development effort now focused on **DIVINE 4**

- initial support for semi-symbolic model checking and abstractions (SymDIVINE)
- extended support for language/system features and standard libraries
    - threads, processes, exceptions, \...
    - libc, libc++, Pthread, Posix filesystem\...

. . .

\hfill{}Thank You!
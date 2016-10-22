---
title: SMT Query Decomposition and Caching in Data-Symbolic Model Checking
titleshort: SymDIVINE
author:
    - Jan Mrázek
    - Jiří Barnat
header-includes:
    - \usepackage{divine}
    - \usepackage{multirow}
    - \usepackage{tikz}
    - \usepackage{graphicx}
    - \usepackage{pbox}
    - \usepackage{booktabs}
    - \usepackage{siunitx}
    - \usepackage{changepage}
    - \usetikzlibrary{shapes, arrows, shadows, positioning, calc, fit, backgrounds, decorations.pathmorphing}
    - \usetikzlibrary{trees}
    - \setbeamertemplate{caption}{\raggedright\insertcaption\par}
    - \newcommand{\columnsbegin}{\begin{columns}}
    - \newcommand{\columnsend}{\end{columns}}
    - \newcommand{\centerbegin}{\begin{center}}
    - \newcommand{\centerend}{\end{center}}
lang: english
date: 22nd October 2016
aspectratio: 43
...

## Motivation

- automated formal verification
    - could lower development costs
    - ensure higher quality software products

- explicit state model checking is one of the traditional approaches

\pause

- in practice not applicable to large real-world code (yet)
    - state-space explosion
    - control flow non-determinism
    - input data non-determinism
- reductions and symbolization as a solution

## Control-Explicit Data-Symbolic Approach

```C
uint a = nondet(); if (a < 65535) { ... } else { ... }
```

\begin{latex}
\begin{center}
\resizebox{\textwidth}{!}{
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
    \node [above = 0.2cm  of s] (lab) {Explicit};
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
      \node [above = 0.2cm of s_sym] (lab_sym) {CEDS};
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

## SymDIVINE

- prototype implementation of CEDS approach
    - verification of C/C++ programs
    - parallelism support
- open source on GitHub

. . .

**Bottleneck: multi-state representation & related machinery**

## Set Representation and Related Machinery

- first order formula over the bit-vector theory
- models of formula map to memory valuations
- free variables map to input values
\begin{equation}
    a_0 < 10 \wedge b_1 = a_0 + 42 \wedge a_0 \% 1 = 0 \wedge a_1 = a_0+1 \nonumber
\end{equation}

. . .

- emptiness test
    - check if there are any memory valuations
    - quantifier-free query to an SMT solver
    - fairly cheap (10 % of the verification time)

. . .

- equality test
    - check if two formulas represent the same memory valuations
    - quantified query to an SMT solver
    - expensive (80 % of the verification time)

## Equality Test in SymDIVINE

- for 2 multi-states $s_1$ and $s_2$ with formulas $\varphi$ and $\psi$:

\begin{equation}
  \mathrm{notsubseteq}(s_1, s_2) = \varphi~\land~ \forall y_1 \ldots y_m
  \, \big ( \psi \Rightarrow \bigvee_{p \in \mathit{vars}} (x^p \not =
  y^p) \big) \nonumber
\end{equation}

- $s_1$ and $s_2$ are equal iff $\mathrm{notsubseteq}(s_1, s_2)$ and $\mathrm{notsubseteq}(s_2,
  s_1)$ are not satisfiable.

. . .

Caching might be a reasonable optimization...

. . .

\hfill{} ...but traditional approaches do not work.

## State Slicing

- decompose multi-state into multiple independent parts

\begin{figure}[!ht]
\begin{center}
\resizebox{0.55\textwidth}{!}{
    \begin{tikzpicture}[ ->, >=stealth', shorten >=1pt, auto, node distance=1.5cm
                       , semithick
                       , scale=0.7
                       , font=\sffamily
                       , stateprog/.style={ rectangle, draw=black, very thick,
                         minimum height=2em, minimum width = 10em, inner
                         sep=6pt, text centered, node distance = 2em, align = left,  rounded corners }
                       ]

        \node[stateprog, label=Original configuration] (p1)
            {Program counter: x \\
             $a < 42~\wedge $ \\
             $a > 0~\wedge $ \\
             $b = a + 4~\wedge $ \\
             $c > 42$
             };

        \node[text centered, align = left, above right = -2.1em and 6em of p1] (pc)
            {Program counter: x};
        \node[stateprog, below = 0.5em of pc] (p2)
            {$a < 42~\wedge $ \\
             $a > 0~\wedge $ \\
             $b = a + 4$};
        \node[stateprog, below = 0.5em of p2] (p3)
            {$c > 42$};

        \node[stateprog, fit = (pc) (p2) (p3), label=New configuration] {};
    \end{tikzpicture}
    }
\end{center}
\end{figure}

. . .

- emptiness test can be performed for each part independently

. . .

- new equality test
    - transforms states to the same slices (matching form)
    - performs equal test independently for each matching parts

## Effects of State Slicing

**Hypothesis:**

- slicing comes with an overhead
- more simple queries for the solver
- program execution changes multi-state locally
    - both tests are performed on multi-state parts independently
    - caching of the results
    - detection of syntactic equality

**Evaluation:**

- SV-COMP benchmarks
- 10 minutes timeout

## Benchmark Results

\begin{adjustwidth}{-2em}{-2em}
\begin{table}[t!]
    \setlength{\tabcolsep}{4pt}
    \begin{tabular}{lrrrr}
         &
        \multicolumn{2}{c}{\pbox{20cm}{\relax\ifvmode\centering\fi SMTStore \\ no cache}} &
        \multicolumn{2}{c}{\pbox{20cm}{\relax\ifvmode\centering\fi PartialStore \\ with cache}} \\
        \addlinespace
        \addlinespace

        \pbox{20cm}{Category} & time[s] & solved & time[s] & solved
        \\ \toprule

        Concurrency& 1828 & 40 & 1506 & 42 \\ \midrule
        DeviceDrivers & 12156 & 241 & 763 & 298 \\ \midrule
        ECA & 20794 & 230 & 21606 & 211 \\ \midrule
        ProductLines & 19571 & 276 & 11995 & 293 \\ \midrule
        Sequentialized & 3710 & 44 & 1735 & 47 \\ \bottomrule
        \textbf{summary} & 58061 & 831 & 37607 & 891
    \end{tabular}
\end{table}
\end{adjustwidth}

## Benchmark Results

\centering
\input{graphics/summary/dots.tex}

## Conclusion

**State slicing combined with caching proofed to be efficient**

- overall nearly half of the verification time was saved

- on real-world-code-like benchmarks highly efficient

- when no speed-up is observed, usually only small overhead

- opens possibilities of further optimizations

. . .

**Future work:**

- integrate state slicing into DIVINE

- further improve formulas machinery (simplifications, subset testing)

. . .

\hfill{}Thank You!

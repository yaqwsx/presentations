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

Basic idea of BMC:

- transition function of a system as SAT or SMT
- property $P$
- if $\phi\wedge\neg P$ is:
    - unsat, property holds up to $k$ steps
    - sat, property is violated

. . .

Observations:

- satisfiability check is the bottle neck
- solvers work best when formula in under- or over-specified

## Main Idea

Add more constraints to overspecify the formula.

. . .

- good candidates: program invariants
- possible candidates: likely invariants

. . .

- simply add them to the conjunction

## BMC Underapproximation

\centering
\includegraphics[page=4, clip, trim=4.5cm 15cm 10.5cm 3cm, width=0.8\textwidth]{paper1}

## Definition-Use Likely Invariants

- paper: Do I Use the Wrong Definition? (Yao Shi et. al.)
- tool DefUse

. . .

- capturing likely invariants:
    - instrument a program
    - run it multiple time
    - collect data
    - statistically choose good candidates
- 3 types of invariants:
    - LR invariants
    - follower invariants
    - DSet invariants

## Local/Remote Invariant Motivation

\centering
\includegraphics[page=3, clip, trim=1.9cm 21.7cm 10.5cm 3.5cm, width=0.8\textwidth]{paper2}

\centering
\includegraphics[page=3, clip, trim=11.1cm 21.7cm 1.9cm 3.5cm, width=0.8\textwidth]{paper2}

## Local/Remote Invariant Motivation

\centering
\includegraphics[page=3, clip, trim=1.9cm 18.2cm 10.5cm 6.7cm, width=0.8\textwidth]{paper2}

\centering
\includegraphics[page=3, clip, trim=11.1cm 18.2cm 1.9cm 6.7cm, width=0.8\textwidth]{paper2}

## Local/Remote Invariant

\centering
\includegraphics[page=6, clip, trim=1.9cm 22.3cm 11.5cm 2cm, width=0.8\textwidth]{paper2}

- read should get data **only** from writes:
    - in the same threads
    - in other threads

## Follower Invariant Motivation

\centering
\includegraphics[page=3, clip, trim=1.9cm 14.9cm 10.5cm 10.2cm, width=0.8\textwidth]{paper2}

\centering
\includegraphics[page=3, clip, trim=11.1cm 14.9cm 1.9cm 10.2cm, width=0.8\textwidth]{paper2}

## Follower Invariant

\centering
\includegraphics[page=6, clip, trim=10cm 22.3cm 6.8cm 2cm, width=0.5\textwidth]{paper2}

- atomicity assumption
- two following reads should get data from the same write

## Definition Set Invariant Motivation

\centering
\includegraphics[page=3, clip, trim=1.9cm 11.8cm 10.5cm 13.3cm, width=0.8\textwidth]{paper2}

\centering
\includegraphics[page=3, clip, trim=11.1cm 11.8cm 1.9cm 13.3cm, width=0.8\textwidth]{paper2}

## Definition Set Invariant

\centering
\includegraphics[page=6, clip, trim=14.7cm 22.3cm 2cm 2cm, width=0.5\textwidth]{paper2}

- restricts the possible values a read can get
- define a set of writes

## Implementation Challenges

- monitored memory locations
    - granularity (DeFuse: a byte)
    - memory location (DeFuse: heap only)
- external definitions
    - external functions might loose invariants (`memset`, `memcpy`)
    - add annotation
- virtual address recycle
    - due to deallocations
    - intercept deallocation
- context sensitivity
    - small uninlined functions used by different threads
- training nose
    - incorrect oraculum


## Results

- 50 random inputs and random interleaving for invariant mining
- LI = tool from the paper
- NoR = encoding without unnecessary writes

\includegraphics[page=7, clip, trim=5.2cm 18.9cm 5cm 3.5cm, width=\textwidth]{paper1}

## Motivation Example

\lstset{basicstyle=\ttfamily}
\lstset{language=C, numbers=left}
\begin{columns}

\begin{column}{0.45\textwidth}
\begin{lstlisting}[
    linebackgroundcolor={%
        \ifnum\value{lstnumber}=1
            %
        \else\ifnum\value{lstnumber}=2
            \color<2->{green!35}
        \else\ifnum\value{lstnumber}=3
            \color<3->{green!35}
        \else\ifnum\value{lstnumber}=4
            \color<4->{green!35}
        \else\ifnum\value{lstnumber}=5
            \color<5->{green!35}
        \else\ifnum\value{lstnumber}=6
            \color<10->{green!35}
        \else\ifnum\value{lstnumber}=7
            \color<11->{green!35}
        \else\ifnum\value{lstnumber}=8
            \color<12->{green!35}
        \else\ifnum\value{lstnumber}=9
            %
        \fi\fi\fi\fi\fi\fi\fi\fi\fi
  }]
void* foo() {
  while( r_y() < NUM ) {
    int f1, f2;
    f1 = r_y();
    w_y( f1 + 1 );
    f1 = r_x();
    f2 = r_y();
    w_x( f1 + f2 );
  } }
\end{lstlisting}
\end{column}

\begin{column}{0.45\textwidth}
\begin{lstlisting}[
    linebackgroundcolor={%
        \ifnum\value{lstnumber}=1
            %
        \else\ifnum\value{lstnumber}=2
            \color<6->{green!35}
        \else\ifnum\value{lstnumber}=3
            \color<6->{green!35}
        \else\ifnum\value{lstnumber}=4
            \color<7->{green!35}
        \else\ifnum\value{lstnumber}=5
            \color<8->{green!35}
        \else\ifnum\value{lstnumber}=6
            \color<9->{green!35}
        \else\ifnum\value{lstnumber}=7
            \color<13->{green!35}
        \else\ifnum\value{lstnumber}=8
            \color<14->{green!35}
        \else\ifnum\value{lstnumber}=9
            \color<14->{green!35}
        \fi\fi\fi\fi\fi\fi\fi\fi\fi
  }]
void* boo() {
  int b, b1, b2;
  while( r_y() < NUM );
  b = r_y();
  b1 = r_x();
  b2 = r_y();
  w_y( b1 + b2 );
  assert( r_y() ==
    b + r_x() );
}
\end{lstlisting}
\end{column}
\end{columns}

\begin{table}[]
\centering
\begin{tabular}{lllll|l}
\multicolumn{1}{l|}{\textbf{x}} & \only<1-11>{5}\only<12->{47}  &
\multicolumn{1}{l|}{\textbf{f1}} & \only<4-9>{41}\only<10->{5}  &
\textbf{b}  &  \only<7->{42} \\
\multicolumn{1}{l|}{\textbf{y}} & \only<1-4>{41}\only<5-12>{42}\only<13->{47} &
\multicolumn{1}{l|}{\textbf{f2}} & \only<11->{42} &
\textbf{b1} & \only<8->{5}  \\&  &
\textbf{} &  &
\textbf{b2} & \only<9->{42}
\end{tabular}
\end{table}
---
title: DIVINE 4
author:
    - Jan Mrázek
    - Henrich Lauko
    - Petr Ročkai
    - Vladimír Štill
header-includes:
    - \usepackage{divine}
    - \usepackage{multirow}
    - \usepackage{tikz}
    - \usepackage{graphicx}
    - \usetikzlibrary{shapes, arrows, shadows, positioning, calc, fit, backgrounds, decorations.pathmorphing}
    - \usetikzlibrary{trees}
    - \input{defs.tex}
lang: english
date: 25th January 2017
aspectratio: 169
...

## DIVINE 4

- explicit model checker
- different state representation compared to DIVINE 3
- tightly coupled to \llvm IR (high-level assembly)
    - no other input formalism is supported
    - no CESMI
- DIVINE core -- DiVM
    - most of the functionality is implemented in user-space
    - better modularity
- better support for counterexamples

## DIVINE Architecture

\resizebox{\textwidth}{!}{

\begin{tikzpicture}[>=stealth,shorten >=1pt,auto,node distance=4em, <->]

\tikzstyle{bcomponent} = [
     color=pruss,
    fill=white,
    thick,
    draw,
    text centered,
    minimum height= 1cm,
    minimum width=2.2 cm,
    text width=6 cm,
];

\node [bcomponent] (input) {User's program $+$ libraries};
\node [clabel, above = 0cm of input] (renv) {Runtime environment};
\node [bcomponent, below = 0cm of input] (runtime) {C++ standard libraries, \texttt{pthreads}};
\node [fnlabel, right = 1.7cm of runtime] (syslabel) {syscalls};
\node [color = pruss, left = 2cm of runtime] (divine) {DIVINE};
\node [bcomponent, below = 0cm of runtime] (dios) {DIOS};

\node [clabel, below = 0.4cm of dios] (venv) {Verification core};
\node [fnlabel, left = 3.2cm of venv] (hyplabel) {hypercalls};
\node [bcomponent, below = 0cm of venv] (divm) {DIVM};
\node [bcomponent, below = 0cm of divm] (vc) {Verification algorithm};


\begin{pgfonlayer}{background}
     \node[runtime, outer, fit = (renv) (input) (runtime) (dios)] (runtimebox) {};
\end{pgfonlayer}

\begin{pgfonlayer}{background}
  \node[verification, outer, fit = (venv) (divm) (vc)] (verificationbox) {};
\end{pgfonlayer}

\draw [-,dashed, very thick, color = pruss] ([xshift=4cm]input.south east) -- ([xshift=-4cm]input.south west);
\draw [flow,rectangle connector=1.5cm] (input.east) to (dios.east);
\draw [flow,rectangle connector=0.75cm] (runtime.east) to (dios.east);

\draw [flow,rectangle connector=-1.5cm] (runtime.west) to (divm.west);
\draw [flow,rectangle connector=-0.75cm] (dios.west) to (divm.west);
\end{tikzpicture}
}

## Traditional DIVINE Workflow

\resizebox{\textwidth}{!}{
\begin{tikzpicture}[>=stealth',shorten >=1pt,auto,node distance=4em, <->]
\tikzset{>=latex}

    \tikzstyle{smt}=[fill=ucla!40]
    \node [component](cc) {DIVINE compiler};
    \node [clabel, above = 0.7 cm of cc] (preprocessing) {Preprocessing};
    \node [component, right = 0.5 cm of cc](lart) {LART};
    \node [emptycomponent, dashed, thick, below = 0.6 cm of cc] (dios) {DiOS and libraries};

    \node [component, right = 0.6 cm of lart, ](interpreter) {Interpreter};
    \node [component, right = 0.5 cm of interpreter, minimum width=1 cm](generator) {State space generator};

    \node [component, below = 0.6 cm of generator, minimum width=1 cm](exploration) {Exploration algorithm};
    \node [clabel, right = 3 cm of preprocessing] (divine) {DIVINE};

    \node [right = 0.5 cm of exploration ] (res)
    {\color{apple}{Valid}\color{pruss}/\color{orioles}{Error}};

    \node [clabel, above = 0.9 cm of interpreter.west, anchor = west] (divml)
    {DiVM};
    \node[emptycomponent, dashed, fit = (interpreter) (generator) (divml)] (divm) {};

    \begin{pgfonlayer}{background}
        \node[runtime, outer, fit = (cc) (lart) (preprocessing)(dios)] (prepbox) {};
    \end{pgfonlayer}

    \begin{pgfonlayer}{background}
        \node[verification, outer, fit = (interpreter) (generator) (exploration) (divine) (divm) ] (di) {};
    \end{pgfonlayer}

    \node [left = 1.5 cm of cc, color=pruss] (start) {C++ program};
    \node [right = 2 cm of exploration] (end) {};
    \node [below = 2.3 cm of start, color=pruss, text width = 1.5 cm] (property) {\centering property and\\ options};

    \draw [flow] (cc) -- (lart);

    \draw [flow] (dios) -- (cc);

    \draw [flow] (lart) -- (interpreter);

    \draw [flow, <->] (interpreter) -- (generator);

    \draw [flow] (generator) -- (exploration);

    \draw [flow, dashed] (start) -- (cc);
    \draw [flow, dashed] (property) -| (interpreter);
    \draw [flow, dashed] (property) -| (lart);
    \draw [flow, dashed] (exploration) -- (res);
\end{tikzpicture}
}

. . .

**Required changes for Simulink verification:**

- synchronous systems
- symbolic data

# Support for Synchronous Systems

## Concurrency in DIVINE 4

- DiVM has not built-in support for threads/processes
- concurrency is implemented as a user space extension
    - structure for concurrency primitives (threads/processes)
    - user-defined scheduler (asynchronous)
- to support synchronous systems we simply define
    - task as a primitive
    - synchronous scheduler

## Synchronous Tasks

```{.cpp}
volatile bool pin1 = false;
volatile bool pin2 = false;

void square() {
    pin1 = true; __dios_yield(); pin1 = false; __dios_yield();
}

void inverter() {
    pin2 = !pin1;  __dios_yield();
}

int main() {
    auto comp1 = __dios_start_task( square, nullptr, 0 );
    auto comp2 = __dios_start_task( inverter, nullptr, 0 );
    __dios_task_dependency( comp1, comp2 );
}
```

## Proposed Mapping Synchronous Tasks to Simulink

- each Simulink "box" is one task
- tasks have dependencies based on connections between pins
- at each systick:
    - each task makes a step (continues until `__dios_yield`)
    - task dependencies are respected
    - new state is produced

# Symbolic Data Support

## Symbolic Data Support

- DiVM can manipulate only explicit data
    - no direct support for programs with inputs

. . .

**Symbolic manipulations are encoded to program**

- program under verification can describe its own data in a symbolic manner
    - the program is still explicit (can be executed by DiVM)
    - program interprets instructions on symbolic values in itself

## Symbolic Data Representation

```{.cpp}
int x = input(); // x in {MIN_INT,..., MAX_INT}

if ( x < 42 ) {
    ... // x in {MIN_INT,...,41}
} else {
    ... // x in {42,...,MAX_INT}
}
```
. . .

- annotate symbolic variables and run `divine check --symbolic`
- program is transformed before verification

```{.cpp}
int input() {
    _SYM int i; // i will be replaced by symbolic representation
    return i;
}
```

## Capabilities

- integers and arithmetic

```{.cpp}
    _SYM int x;
    int y = x * x;
```
. . .

- structures with symbolic values

```{.cpp}
    struct Node { int value; } node;
    node.value = x;
```
. . .

- explicit pointers to symbolic values

```{.cpp}
    int *p = &x;
```
. . .

- function calls

```{.cpp}
    foo( x );
```
## Current Limits

- arrays of symbolic data

```{.cpp}
    int arr[10];
    arr[0] = x;
```
. . .

- arrays of symbolic size

```{.cpp}
    int arr[x];
```
. . .

- symbolic pointers

```{.cpp}
    _SYM int *p;
```
. . .

- symbolic values on the heap

```{.cpp}
    int *p = malloc(sizeof(int));
    *p = x;
```
. . .

**Future plans to eliminate all these limits**

## Generic framework

- symbolic verification is only single use case
- framework can implement data and predicate abstractions

```{.cpp}
    _INTERVAL int x;
```
# Towards Verification of Simulink

## How it All Fits Together

\resizebox{\textwidth}{!}{
\begin{tikzpicture}[>=stealth',shorten >=1pt,auto,node distance=4em, <->]
\tikzset{>=latex}

    \tikzstyle{smt}=[fill=ucla!40]
    \node [component, draw = red, text=red, thick](cc) {Simulink compiler};
    \node [clabel, above = 0.7 cm of cc] (preprocessing) {Preprocessing};
    \node [component, right = 0.5 cm of cc, draw = red, text =red, thick ](lart) {LART};
    \node [emptycomponent, dashed, thick, below = 0.6 cm of cc, thick, draw = red, text = red] (dios) {DiOS and libraries};

    \node [component, right = 0.6 cm of lart, ](interpreter) {Interpreter};
    \node [component, right = 0.5 cm of interpreter, minimum width=1 cm](generator) {State space generator};

    \node [component, below = 0.6 cm of generator, minimum width=1 cm, draw = red, text =red ](exploration) {Symbolic exploration};
    \node [clabel, right = 3 cm of preprocessing] (divine) {DIVINE};

    \node [right = 0.5 cm of exploration ] (res)
    {\color{apple}{Valid}\color{pruss}/\color{orioles}{Error}};

    \node [clabel, above = 0.9 cm of interpreter.west, anchor = west] (divml)
    {DiVM};
    \node[emptycomponent, dashed, fit = (interpreter) (generator) (divml)] (divm) {};

    \begin{pgfonlayer}{background}
        \node[runtime, outer, fit = (cc) (lart) (preprocessing)(dios)] (prepbox) {};
    \end{pgfonlayer}

    \begin{pgfonlayer}{background}
        \node[verification, outer, fit = (interpreter) (generator) (exploration) (divine) (divm) ] (di) {};
    \end{pgfonlayer}

    \node [left = 1.5 cm of cc, color=pruss] (start) {Simulink diagram};
    \node [right = 2 cm of exploration] (end) {};
    \node [below = 2.3 cm of start, color=pruss, text width = 1.5 cm] (property) {\centering property and\\ options};

    \draw [flow] (cc) -- (lart);

    \draw [flow] (dios) -- (cc);

    \draw [flow] (lart) -- (interpreter);

    \draw [flow, <->] (interpreter) -- (generator);

    \draw [flow] (generator) -- (exploration);

    \draw [flow, dashed] (start) -- (cc);
    \draw [flow, dashed] (property) -| (interpreter);
    \draw [flow, dashed] (property) -| (lart);
    \draw [flow, dashed] (exploration) -- (res);
\end{tikzpicture}
}

## Where Are We Standing?

- all components (tasks, symbolic data) are implemented independently
- they need to be tested together
- we have no adapter for Simulink diagrams

. . .

**What needs to be done with Honeywell cooperation:**

- figure out transformation of Simulink diagrams into C++/LLVM IR
- get benchmarks and evaluate

# Relaxed Memory

## Verification of Parallel Programs

- design of parallel programs is hard
- easy to make mistakes -- data races, deadlocks

  . . .

- **memory behaviour is very complex**

  - effects of caches, out-of-order and speculative execution

  . . .

```{.cpp}
int x, y = 0;
void thread0() {
    y = 1;
    int a = x;
}

void thread1() {
    x = 1;
    int b = y;
}
```

- is it possible to end with `a == 0 && b == 0`? \pause{} **yes** (even on Intel
  CPUs)

## Relaxed Memory Example

```{.cpp}
int x, y = 0;
void thread0() {              void thread1() {
    y = 1;                        x = 1;
    int a = x;                    int b = y;
}                                 int c = x;
                              }

```

. . .

\begin{latex}
    \makebox[\textwidth][c]{
    \begin{tikzpicture}[ ->, >=stealth', shorten >=1pt, auto, node distance=3cm
                       , semithick
                       , scale=0.65
                       ]

      \useasboundingbox (-10,1) (7.3,-6);

      \draw [-] (-10,0) rectangle (-7,-6);
      \draw [-] (-10,-1) -- (-7,-1)
                (-10,-2) -- (-7,-2)
                (-10,-3) -- (-7,-3)
                (-10,-4) -- (-7,-4)
                (-10,-5) -- (-7,-5);
      \draw [-] (-9,0) -- (-9,-6);
      \node () [anchor=west] at (-10,0.5) {memory};
      \node () [anchor=west] at (-10,-2.5)  {\texttt{x}};
      \node () [anchor=west] at (-9,-2.5) {\only<-8>{\texttt{0}}\only<9->{\texttt{1}}};

      \node () [anchor=west] at (-10,-3.5)  {\texttt{y}};
      \node () [anchor=west] at (-9,-3.5)  {\texttt{\only<-9>0\only<10->1}};

      \node () [anchor=center] at (-2,-5.5) {store buffer of t. 0};
      \node () [anchor=center] at (4,-5.5) {store buffer of t. 1};

      \draw [-] (-4,-4) rectangle (0,-5);
      \draw [-] (2,-4) rectangle (6,-5);
      \draw [-] (-2,-4) -- (-2,-5);
      \draw [-] (4,-4) -- (4,-5);

      \node<3-9> () [anchor=west] at (-4,-4.5)  {\texttt{y}};
      \node<3-9> () [anchor=west] at (-2,-4.5)  {\texttt{1}};

      \node<5-8> () [anchor=west] at (2,-4.5)  {\texttt{x}};
      \node<5-8> () [anchor=west] at (4,-4.5)  {\texttt{1}};

      \node () [] at (-4, 0.5) {thread 0};
      \draw [->] (-4,0) -- (-4,-2.3);
      \node () [anchor=west, onslide={<3> font=\bf, color=red}] at (-3.5, -0.5) {\texttt{y = 1;}};
      \node () [anchor=west, onslide={<4> font=\bf, color=red}] at (-3.5, -1.5) {\texttt{load x;}};

      \node () [] at (2, 0.5) {thread 1};
      \draw [->] (2,0) -- (2,-3.3);
      \node () [anchor=west, onslide={<5> font=\bf, color=red}] at (2.5, -0.5) {\texttt{x = 1;}};
      \node () [anchor=west, onslide={<6> font=\bf, color=red}] at (2.5, -1.5) {\texttt{load y;}};
      \node () [anchor=west, onslide={<7> font=\bf, color=red}] at (2.5, -2.5) {\texttt{load x;}};

      \draw<3-7> [->, dashed] (0.3,-0.5) to[in=0, out=0] (0,-4.5);
      \draw<4-7> [->, dashed] (-7,-2.5) to[in=0, out=0, out looseness = 3, in looseness=0.5] (-0.7,-1.5);
      \draw<5-7> [->, dashed] (6.3,-0.5) to[in=0, out=0] (6,-4.5);
      \draw<6-7> [->, dashed] (-7,-3.5) to[in=0, out=0, out looseness = 0.2, in looseness = 0.7] (5.3,-1.5);
      \draw<7-7> [->, dashed] (6,-4.5) to[in=0, out=0] (5.3,-2.5);

      \draw<-2> [->] (-4,-0.3) to (-3.4,-0.3);
      \draw<3> [->] (-4,-0.7) to (-3.4,-0.7);
      \draw<4-> [->] (-4,-1.7) to (-3.4,-1.7);

      \draw<-4> [->] (2,-0.3) to (2.6,-0.3);
      \draw<5> [->] (2,-0.7) to (2.6,-0.7);
      \draw<6> [->] (2,-1.7) to (2.6,-1.7);
      \draw<7-> [->] (2,-2.7) to (2.6,-2.7);
  \end{tikzpicture}
  }
\end{latex}

## Why Relaxed Memory?

- memory is significantly slower than processor cores
- processor has caches to speed up execution

  . . .

- optimizations of cache coherency protocols\
  $\rightarrow$ observable effects

  . . .

- reordering of instructions might be also observable

  . . .

- overall behaviour described by a **(relaxed) memory model**

## Memory-Model-Aware Analysis

- encode the memory model into the program
- verify it using a verifier without memory model support

    - e.g. DIVINE, a lot of other verifiers
    - program transformation instead of modification of the verifier
    - on the level of LLVM

. . .

```{.cpp}
x = 1;
int a = y;
```

$\rightsquigarrow$

```{.cpp}
_store( &x, 1 );
int a = _load( &y );
```

- `_load`, `_store` simulate the memory model

## Memory-Model-Aware Analysis in DIVINE

- still rather incomplete

- primarily detection of errors (assertions, memory errors) under given relaxed
  memory mode

    - i.e. not detection of behaviour different from sequential consistency
    - in future also possibly race detection

- focus on performance, correctness of memory model simulation

- soon: `x86`-TSO, PSO, and Non-Speculative Writes


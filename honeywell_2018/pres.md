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
- "micro-kernel" DIVINE -- DiVM
    - most of the functionality is implemented in user-space
    - better modularity
- better support for counterexamples

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

## DIVINE Workflow for Simulink Verification

- ToDo Image

# Support for Synchronous Systems

## Concurrency in DIVINE 4

- DiVM is not aware of threads/processes
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

void foo() {
    pin1 = true; __dios_yield(); pin1 = false; __dios_yield();
}

void boo() {
    pin2 = !pin2;  __dios_yield();
}

int main() {
    auto cmp1 = __dios_start_task( foo, nullptr, 0 );
    auto cmp2 = __dios_start_task( boo, nullptr, 0 );
    __dios_task_dependency( cmp1, cmp2 );
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

## DIVINE Workflow for Symbolic Verification

TODO image

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

# Weak Memory

# Conclusion

## How it All Fits Together

TODO

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

## Where Are We Standing?

- all components (tasks, symbolic data, memory models) are implemented
  independently
- they need to be tested together
- we have no adapter for Simulink diagrams
- is there a use for weak memory models for Honeywell?

. . .

- figure out transformation of Simulink diagrams into C++/LLVM IR
- get benchmarks and evaluate

\pause

**Thank you**

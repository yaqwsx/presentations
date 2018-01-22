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
- "micro-kernel" DIVINE - DiVM
    - most of the functionality is implemented in user-space
    - better modularity
- better support for counterexamples

## Traditional DIVINE Workflow

- ToDo Image

## DIVINE Workflow for Simulink Verification

- ToDo Image

# Support for Synchronous Systems

## Threads in DiOS

- DiVM is not aware of threads
- threads are implemented as a user-space extension
    - user-defined scheduler
- to support synchronous systems we simply define a new scheduler

## Semantics of Synchronous Tasks

- ToDo: Example & show mapping to Simulink diagram

# Symbolic Data Support

## Example

- ToDo

- DiVM can manipulate only explicit data
    - no direct support for open programs
- program under verification can describe its own data in a symbolic manner
    - the program is still explicit (can be executed by DiVM)
    - exploration algorithms can treat it symbolically

## Limits (ToDo)

- symbolic pointers (no problem for Simulink)
- arrays

# Weak Memory

# Conclusion

## How it All Fits Together

- ToDo

## Where Are We Standing?

- all components are implemented independently
- they need to be tested together
- we have no adapter for Simulink diagrams
- is there a use for weak memory models for Honeywell?

. . .

- get Simulink & and C/C++/LLVM counterpart examples
- benchmark it

\pause

Thank you

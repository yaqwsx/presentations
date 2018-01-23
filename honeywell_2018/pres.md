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

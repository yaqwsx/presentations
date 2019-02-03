---
title: RoFI -- Distributed Metamorphic Robots
titleshort: RoFI
author:
    - Jan Mrázek
header-includes:
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
date: 4th February 2019
aspectratio: 169
...


## Metamorphic Robots -- What Are They?

\columnsbegin
\column{.5\textwidth}
    \textbf{Robots built out of modules}
    \begin{latex}
        \begin{itemize}
            \item modules are rather high-level
            \item modules are mainly the same
            \item modules are semi-independent
        \end{itemize}

        \bigskip
        \begin{center}
        \textbf{=\\robots built out of robots}
        \end{center}
    \end{latex}

\column{.5\textwidth}

![Replicator from Stargate](img/replicator.jpg)

\columnsend

## Examples of Existing Metamorphic Robots

\columnsbegin

\column{.5\textwidth}

![M-TRANS](img/mtran.jpg)

\column{.5\textwidth}

![S-MORES](img/smores.jpg)

\columnsend

. . .

**Problems:**

- narrow topic of the platforms
- hard to reproduce

## The RoFI Platform

\columnsbegin

\column{.65\textwidth}

**A new platform of distributed metamorphic robots**

\bigskip

**Goals:**

- create a bridge between reconfiguration algorithms and physical robots
- allow for reproducibility of the results


\column{.35\textwidth}

![RoFI module](img/rofi_tall.jpg)

\columnsend

## The RoFI Platform Is:

1. a grid system with a module shape requirements,
2. a docking system,
3. an inter-module communication and
4. formalism for module and system descriptors.

## 1: Shape Requirements

**Goal: variety of modules, many useful configurations**

. . .

\bigskip

\centering
![](img/rofi_shapes.pdf){ width=60% }

## 1: Grid Awareness

\centering
![](img/grid_aware.pdf){ width=90% }

## 2: Docking System

**Goal: Uniform way of connecting modules**

**Challenge: Point contact of module bodies**

. . .

\bigskip

\centering
![](img/dock_overview.pdf){ width=80% }

## 2: Docking System Features

\columnsbegin

\column{.6\textwidth}

- self-contained module
    - controlled over an SPI bus
    - reusable
- data communication \& power sharing
- consumes energy only when changing a state
- easy to build

\column{.4\textwidth}

![First prototypes](img/dock_test_setup.jpg)

\columnsend

## 3: Inter-module Communication

**Goal: Exchange information in a scalable and a fault-tolerant manner**

. . .

\bigskip

**Existing projects:**

- RS-485 or CAN
- custom protocol

. . .

**RoFI:**

- docks can exchange binary blobs
- traditional TCP/IP networking as a protocol
    - custom L1 \& L2 using the docks

**Benefits:**

- seamless interpolation of a wired and a wireless connection
- easy adaptation of state-of-the-art research
- easy cooperation with existing devices

## 3: Inter-module Communication -- Proof of Concept

\columnsbegin

\column{.5\textwidth}

- setup prepared on table
- implementation of a network interface driver for lwIP
- successful TCP \& UDP connection

\column{0.5\textwidth}

![](img/com_setup.jpg)

\columnsend

## 4: Formalism For Describing Configurations

\centerbegin

![](img/um_descriptor.pdf)

\centerend

- basic notation (e.g. module, system, configuration, topology, etc.)
- simple graph-based formalism for describing various modules
    - descriptors can be chained (a whole system descriptor)
- canonic description of a system topology
- procedure to get a physical position of a module

# Application Of The RoFI Platform Definition

## Universal Module

\columnsbegin

\column{.5\textwidth}

![](img/um_axis.pdf)

\column{0.5\textwidth}

![](img/um_side.jpg)

\columnsend

- 3 degrees of freedom
- 6 docks

Current state: physical prototype on an "umbilical cord"

## Universal Module By-products

\columnsbegin

\column{.5\textwidth}

**Automatic Firmware Upgrades**

\column{0.5\textwidth}

**Library for Asynchronous Events**

\columnsend

\columnsbegin

\column{.5\textwidth}

- challenge of firmware updates in a RoFI system
- low-level protocol based on RoFI docking system
- when a single module with new firmware appears, it it distributed to others

\column{0.5\textwidth}

- "do A, then B, and handle errors"
- similar to JavaScript asyc/await or observables in C#
- C++ implementation
- suitable for microcontrollers
- can handle hardware interrupts

\columnsend

\bigskip

Current state: designed, ready to be implemented

## Conclusion

**RoFI takes inspiration in number of existing projects, but differs in:**

- being the bridge between physical robots and high-level algorithms,
- being open-source and open-hardware,
- defining a stand-alone, reusable docking mechanism.

. . .

**Possible future work:**

- finish the hardware setup, introduce specialized modules,
- develop "RoFI middleware",
    - better routing algorithms
    - make inter-module communication opaque to the programmer
- explore reconfiguration algorithms
- and much more.

. . .

\hfill{}Thank You!
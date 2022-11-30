# Intro

Welcome to this strange meeting. My name is Honza and in the next 15 minutes, I
will introduce what I do as my PhD.

# Robot & Automatization

Robots are one of the essential building blocks of the modern society. I am not
talking about a robotic vacuum cleaner you have at home. I am talking mainly
about automatization & robotics that make nearly all production cheap and also
allow for production of more advanced components. Without robots, the bread in
the stores would be more expensive and you couldn't buy a computer, since we
cannot simply manufacture such complex device without robots.

However, even what I said before might sound exciting, there is a sad truth that
the robots we use are pretty dumb - they usually explicitly follow prescribed
instructions and more-less ignore environment. Also to build a robot you need an
expert personal and many, many manhours. These are the challenges the robotic
research community is dealing with.

There are some trends to deal with the last two challenges

# Modular Robotics

One of the promising way is a modular robots. What does it mean?

You could take specification and design a new robot from scratch. This is
extremely time consuming and expensive. You do it toady only for high
performance tasks where you cannot make compromises. For example Mars rover.

What is already done is that you take some commonly used units like motors,
sensors, drivers a package them hidden by well-defined interface. If you want a
biology analogy - you make organs and build out of organs. What you get is
basically a "lego for adults". However, you still have to design how to connect
the modules and you have to build the robot manually.

Now we turn into the research phase. What if we make universal modules and build
everything out of them? This is what is called metamorphic robots. We aim for
designing small rather simple robots out of which we build larger robots. The
biology analogy of these robots are cells. We want the cells to self-assemble
according to the task, we don't care if one of the cells dies - it can be easily
replaced.

Also, we can make one step further - make really tiny modules even with less
features and build everything out of them - this is what is called a smart or a
programmable matter.

In my research I focus on metamorphic robots as they seem to be promising
compared to smart matter which is still rather utopic.

# Why Metamorphic Over Modular

It is a good question to ask why we should uniform the modules. Why not just
continue with the current approach.

Metamorphic robots could bring several interesting features. One of them is the
self-assembly. Traditional modules are too single purpose, which prevents the
self-assembly - they simply cannot move, cannot communicate enough to
self-assemble.

Most of the publications out there stress the extreme versatility of metamorphic
robots. They say you can send bunch of these modules to rescue people and
explore. You send a bunch of modules, they assemble to a spider walk to
destination. When they reach a narrow opening, they reassemble to a snake, get
thought it. Although, it is a possible use case, I agree with the following XKCD
comic. I personally see much bigger potential in serving as a mean for rapid,
efort-less prototyping of robots - just like 3D printers. 3D printers cannot
produce high-quality components fast and cheap, but they are good for
prototyping. Similarly, I thing that a robot explicitly built for a single
purpose will be cheaper and more effective, however you have to put a mental
effort in developing it.

Also as all the modules are the same, you can easily replace the modules and
easily build fault tolerant systems.

# What I would like to achie

So, in the ideal world, the outcome of my PhD would be replicators from StarGate..

# Challenges

...however, in the real world, things are much more complicated and we won't
have replicators in at least 20 years in my opinion.

There are many challenges - I outlined only the most important ones.

First, we have to build the modules. To make them useful, they should be around
1 cm in size. They also need a good power source and cheap to produce. None of
it we have so far.

The second challenge is that we talk about distributed systems with thousands of
nodes, which need to communicate in unstable topology, due to their small size
they do not feature much computational power and also everything they do has
some kind of real-time reaquirements.

The third cathegory are actually algorithmical one. I mentioned that the robots
can change their shape. However, computing a reconfiguration plan is hard
problem (even enormously simplified cases are NP-hard) - so we need some
heuristics. There is also a second aspect - how do we specify the tasks for the
robots? How do I tell the bag of modules to bring a me a cup of coffee?

# Phd

In my PhD I cannot finish solve all the problems and I focus only on this
subset. Basically there are plenty of people working on miniaturation, however,
few people actually study how to control these robots. I would like to focus on
the distributed nature of these robots and their control.

# Validation

One of my hard requirements is that I would like to validate all outcomes of my
research on physical robots in the physical world. There are a plenty of
theoretical researches, who propose solution not applicable to a real world. I
don't want to be one of them. I want to be sure I make reasonable assumptions.

To do so, I need a suitable robotic platform. There are several out of them out
there - e.g. M-TRAN, HyMOD or ATRON. However, authors of these robots do not
sell them nor they publish source materials. Unfortunately, the robotic
community is not as "open-source" oriented as the computer science.

# RoFI

Therefore I added additional goal - to develop a reaseach friendly platform
suitable for validation of results. And I would like to encourage the community
to use so not everyone has to reinvent the wheel. I call it RoFI.

# RoFICoM

First I designed a connector for these robots. It provides mechanical,
ocmuncational a power-sharing connection between two modules. This results was
published at IROS 2019. We received a really positive feedback on it from the
community. The appreciated the fact it can be easily manufactured.

# Universal module

The connectors are used by the universal module - the basic module - or cell if
you want. The unit is currently under development

# RoFiBOts

One we have it, we expect to start building robots out of them like this one and
use them to validate our other theoretical work - mainly the self-assembly and
distributed control.

# Last

To wrap the presentation up, I present a brief summary of what I have alredy
finished out of my goals and what I expect to do more.

I worked most on the RoFI development. I think we are few months before
finishing it.

When we talk about the distributed control, we have a proposal of novel
inter-module communication protocol, which we would like to implement to RoFI.
Then we would like to tackle the distributed control - basically what it means
is to come up with an algorithm to solve the following problem. You specify a
task to a single module, it distributes this knowledge and all the modules start
to cooperate to fullfill the task. If you disable one of the modules, the system
should be able to recover. Additionally, we would like to find out how this
cooperates with real-time control.

About the reconfiguration, we sucessfully validated that naive state-space
exploration approaches do not work  and you cannot beat them with raw
computational power. Therefore, we are working on algorithm which turns a
configuration into a snake one. Once we have that, you can reconfigure between
arbitrary two configurations - just by taking snake configuration as a midstep.
Then we would like to explore if cannot find "shortcuts" in such reconfiguration
plan to make it more efficient.

That's all from me. If you have any questions I am happy to answer them.
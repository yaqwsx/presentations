# Title

Hello everyone, my name is Jan Mrázek and I am a PhD student at Masaryk
University in the Czech republic. In the next couple of minutes I will
briefly introduce our latest work - the RoFICoM - an open hardware connector for
metamorphic robots.

# I want to build a robot

My research focuses on metamorphic self-reconfigurable robots. For those of
you, who are not familiar with this term, imagine a simple but rather high-level
robots which can connect together and therefore, build a larger robot, which is
more capable than the individual building pieces. Or if you know the TV show
Stargate, we are talking about replicators basically.

I am interested in designing the reconfiguration and distributed control
algorithms. However, I would like to demonstrate my results on a real robots.
Therefore I want to build one.

The good news is that there are many existing projects. However, many of them
are dead or they do not share blueprints nor sell their modules.

# RoFICOm

Therefore, We decided to design one and make it publicly available. We started
with a connector for such robots, which is the crucial building block. You can
see the results in the image.

# What does it do?

The RoFICoM is a small, stand-alone device which can couple two robots
mechanically, it establishes a communication line so the two robots can connect
and also allows them to share power. I have a short video showing the unit in
operation.

This is the single unit in operation - when it connects, it expands and
basically "screws" into the other unit.

Here you can see how the two units interact with each other.

Also note, that the connecter has quite large area of forgiveness - the units
does not have to be perfectly aligned.

# Use it

Let me now introduce you to the key features of the connector.

First of all, we consider it a versatile. Compared to the existing solutions it
is compact and especially it is flatter. The connector is genderless - which
means any two connectors can connect. We call our connector grid aware - see the
picture below. If you have a robot which fits in a grid, it is beneficial if the
robot body is actually ball as it ocupies less cells during a movement. However
it comes at a cost - two neighbouring modules have only a point contact - and
that's why ROFICOM is expandable - to fit inside the ball. Also note that there
is no power required for sustaining the connection. Also there is no need for
synchronization - the connector can also connect to a purely passive
counterpart.

The connector is designed such

We also designed the connector as a ready-to-use encapsulated module. All you
need to use it in your robots are 4 screws and matching pads on a PCB below it.
That's it. The connector connects to a system via SPI bus and provides rather
high-level interface (like connect/disconnect, test if connected, send a packet,
receive a packet) - the interface description is available on our werbsite.

But most of all unlike the existing solution, you can actually build it yourself
without much effort. The design has been optimized for FDM 3D printing and we
are currently experimenting with polyurethane molding. All the required
components are commonly available. All the design files are available on our
website. And I encourage you - try it yourself and give us feedback if you want.
We want reproducible research.

# What is inside

The connector is basically a 5 components you can print or mold on your own, one
DC motor and 1 PCB you can easily order online at your favourite PCB
manufacturer.

# Platform

As I said in the beginning - our goal is to build a whole open-hardware platform
for metamorphic robots. We call it RoFI and it is still a work in progress,
however we already have a few prototypes.

# Conclusion

So allow me to conclude. I think we have designed a connector which is feature
wise comparable to existing solutions, it is easy to use and compact. But most
importantly - if you want to use it or try it, you can. I hope there will be
people from the community benefiting from the work we done - and I hope they
will not reinvent the wheel as many earlier projects, including ours, had to do.

Thats all, thank you for your attention and I am ready for your questions!
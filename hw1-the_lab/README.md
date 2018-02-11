# Homework 1: Build the Lab

The first homework (or hands-on assignment) is to build a lab for
experimenting with network automation. This lab can be used as the basis
to work on later hands-on assignments.

While it is not required to use the same lab for all assignments, doing
so might help in understanding the automation part instead of learning
how to build different labs. ;-)

## Selecting the Gear

I use emulated Cisco 7200 routers as lab devices. The emulation is done
using dynmips in hypervisor mode and dynagen to create the topology from
a simple text file.

Cisco IOS is supported by upstream Ansible without need for third party
modules, I know Cisco IOS quite well, and I am currently using Ansible to
automate network tests for IOS XE and IOS XR based routers. Thus I should
be able to focus on the network automation part, instead of learning how
to connect the Ansible automation framework to the chosen network devices.

There even is upstream support in NAPALM to work with Cisco IOS based
devices, thus this choice may allow me to explore NAPALM and Salt
Stack, too.

Since early experiments suggest that the full lab topology I would like
to use might be a bit too much for my trusty old laptop, especially with
Ansible running on it as well, I may change to a smaller lab comprising
just half of the routers.

## Lab Topology

My lab is intended to simulate a service provider network offering a
BGP/MPLS IP VPN service.

### Full Lab

The full network is comprised of two planes, each comprising two P
routers, two PE routers, one route reflector, and two CE routers.

![full lab topology](full_lab.png)

### Half Lab

If I go with the smaller lab, I will just omit the second plane.

![half lab topology](half_lab.png)

The virtual lab is connected to my GNU/Linux laptop via two bridges,
that connect to tap devices which connect to router interfaces. The first
bridge, `brOOB`, is used to connect one interface of each router and
the laptop to a shared Ethernet segment. This allows easy connectivity
to the routers to provision a MPLS transport network, as could be done
when staging new routers. After the infrastructure is available, `brPE1`
connects the laptop and the PE1 router. The PE1 router then provides
in-band connectivity to the loopback interfaces of all routers, which
shall be used to provision L3VPN services.

### Python Virtual Environment

The network automation tools run on my laptop, which uses GNU/Linux
natively. To use the current Ansible (and potentially NAPALM and Salt
Stack), the network automation tools are installed into a Python Virtual
Environment.

### Initial Lab Configuration

Since Ansible is supposed to be used via TCP/IP (instead of e.g. serial
console), the lab routers need to be pre-provisioned with a basic
configuration that provides IP connectivity and an SSH server. This
pre-staging configuration can be applied via copy&paste to the router
consoles. With this configuration, Ansible can connect to every router,
which suffices for the first homework and provides a starting point for
the upcoming hands-on exercises.

## Lab Automation

Not only is the virtual lab intended to learn network automation, starting
and stopping it is automated as well. The virtual lab configuration and
control scripts can be found in the [lab/](lab/) directory.

### Starting the Lab

The script `start_lab` creates the GNU/Linux network devices needed
to connect to the virtual lab and then starts GNU screen in which to
start `dynamips` and `dynagen`. The script then waits for `dynagen` and
`dynamips` to stop, after which it removes the GNU/Linux network devices
it created.

#### Debugging

In order to debug this script I have used a minimalistic lab setup
consisting of just one router.

![one router topology for debugging](P1.png)

### Creating and Deploying Pre-Provisioning Configuration

The router configuration needed to connect via Ansible is generated via
GNU `m4` from a template (`template.m4`) and a per-router definition file
(`<ROUTER_NAME>.m4`) to specify both the router's name and IP address.
Generation of the configuration files is contrlled using GNU `make`. To
deploy the configuration to the routers I have written an `expect` script
that connects to the router via the virtual console server provided by
`dynamips`, reads the generated configuration file, applies it line by
line, and then saves the configuration. All this can be found in the
[pre-staging/](pre-staging/) directory.

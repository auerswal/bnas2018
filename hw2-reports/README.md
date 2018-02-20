# Homework 2: Create Summary Reports

The second homework (or hands-on assignment) is to create summary reports.
The idea is to collect information from the network devices and turn
that into an easily readable report that is useful on its own.

## Creating a Network Topology Diagram

This course does not require to solve a set of specific problems, it
rather sets a theme to follow and provides the student with ideas. One of
the given ideas is to create a network graph based on neighbor information
collected from the devices. I like this idea, because it provides me
with an opportunity to look into
[Graphviz](http://graphviz.org/)
which is a suggested tool to visualize (i.e. generate an image file of)
the connectivity graph.

This problem has some relation to the
[Prescriptive Topology Manager](https://github.com/CumulusNetworks/ptm)
from Cumulus Networks
([PTM Documentation](https://docs.cumulusnetworks.com/display/DOCS/Prescriptive+Topology+Manager+-+PTM))
which uses a file in Graphviz format named `topology.dot` to describe
the intended network topolgy and uses the Link Layer Discovery Protocol
(LLDP) to compare the switch's neighbors with the given topology.

Since I am using virtual Cisco IOS devices in my
[lab](../hw1-the_lab/),
I am using the Cisco Discovery Protocol (CDP, also known as CiscoDP on
Enterasys (now ExtremeEOS) switches, sometimes known as Industry Standard
Discovery Protocol (ISDP) as well) as data source.

### Solution Description

I use the
[`ios_command`](http://docs.ansible.com/ansible/latest/ios_command_module.html)
module to collect CDP data from the virtual routers. The output is parsed
by an Ansible filter (one of the
[`parse_cli` or `parse_cli_textfsm`](http://docs.ansible.com/ansible/latest/playbooks_filters.html#id20)
filters) into variables. The
variables are used together with a
[jinja2 template](https://docs.ansible.com/ansible/latest/playbooks_templating.html)
to generate a network topology description in Graphviz format,
i.e. using the
[DOT language](https://graphviz.gitlab.io/_pages/doc/info/lang.html).
The
[dot](https://graphviz.gitlab.io/_pages/pdf/dotguide.pdf)
program is used to create an image file in
[PNG](http://www.libpng.org/pub/png/)
format.

---

[BNAS2018 GitHub repository](https://github.com/auerswal/bnas2018) | [My GitHub user page](https://github.com/auerswal) | [My home page](https://www.unix-ag.uni-kl.de/~auerswal/)
## Interlude 2: Lab Configuration

The virtual lab as set up in [homework 1](../hw1-the_lab) enables just the
interfaces used for out-of-band management. These interfaces are connected
to a Linux bridge without CDP support. As a result every router sees all other
routers via CDP in the OOB interface. Since all physical router interfaces
are administratively down by default, the connectivity graph shows just
full mesh connectivity between the OOB interfaces and nothing more. That is
not the intended result for the topology visualization.

Thus I have written two playbooks to add some configuration to the virtual
network:

1. The playbook [`no_oob_mgmt_cdp.yml`](ansible/playbooks/no_oob_mgmt_cdp.yml)
   disables CDP on the OOB interfaces, because I do not want to see this in
   the topology graph. The OOB interfaces are intended for staging only, they
   are not part of the production configuration. This is a simple playbook,
   because just one command (`no cdp enable`) needs to be configured on the
   same interface (`FastEthernet0/0`) of all routers. This is done with just
   one task invoking the `ios_config` module in the single play of the
   playbook.
2. The playbook [`configure_interfaces.yml`](ansible/playbooks/configure_interfaces.yml)
   enables the transit interfaces between the routers, and additionally
   configures IPv4 addresses on transit and loopback interfaces. (The IPv4
   addresses are not used yet.) This playbook is a bit more complex than the
   other. It reads a [YAML file](ansible/playbooks/vars/half_lab-interfaces.yml)
   containing node descriptions, uses a
   [Jinja2 template](ansible/playbooks/templates/ios-interfaces.j2) to generate
   configuration snippets, and then uses the generated configuration as input
   to the `ios_config` Ansible module.

---

[BNAS2018 Homework 2](README.md) | [BNAS2018 GitHub repository](https://github.com/auerswal/bnas2018) | [My GitHub user page](https://github.com/auerswal) | [My home page](https://www.unix-ag.uni-kl.de/~auerswal/)

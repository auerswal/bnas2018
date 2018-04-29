# Homework 3: Create a Service Data Model

The third homework (or hands-on assignment) is to create a data model
describing devices, network infrastructure and a service. This data
model is intended to be used in the [fourth homework](../hw4-deploy_service/)
to deploy the service using automation.

This hands-on assignment is divided into several parts:

1. List attributes that need to be described by the data model.
2. Select the appropriate data store(s).
3. Create a suitable data model.
4. Document the data model to enable others to use it.
5. Validate the data model by creating (partial) device configurations.

## Network Attributes

I want to automate management of an
[MPLS](https://tools.ietf.org/html/rfc3031) network providing [BGP/MPLS IP
VPN](https://tools.ietf.org/html/rfc4364) (L3VPN) services (as written in
[Homework 1: Build the Lab](../hw1-the_lab/)). Thus the data model needs
to describe the MPLS transport network and the L3VPN service.

I exclude the CE routers for the time being, they can be used to test the
L3VPN service by applying suitable configurations. Managed CE routers
can be seen as an additional service that may be combined with the
basic L3VPN.

Thus the data model for the L3VPN comprises the following elements:

* Common parameters
  * Administrator credentials
  * Domain name
  * IGP
  * network management system IP
  * AS number
* Transport network
  * Network nodes (P, PE, BGP route reflectors)
    * name
    * management IP
    * roles (P, PE, RR)
  * Transport links
  * Infrastructure links (off-path route reflectors, network management)
  * IP ranges
    * Loopback range
    * Transport range
  * Loopback offsets
    * P
    * PE
    * RR
* L3VPN service
  * Customer ID
  * VPN ID
    * RT / RD determined from AS number and VPN ID
  * Access Circuits
    * PE interfaces
    * IP networks

## Data Stores

I use separate YAML files to store the data model instance:

* [`common.yml`](common.yml)
* [`transport.yml`](transport.yml)
* [`l3vpn.yml`](l3vpn.yml)

Using the above YAML files separates the data model from the automation
framework (Ansible). Using host and group variables inside the Ansible
inventory binds the data model closely to Ansible.

## Data Model

## User Documentation

## Device Configurations

---

## References

* [Ansible](https://www.ansible.com/)
* [BGP/MPLS IP VPN](https://tools.ietf.org/html/rfc4364)
* [MPLS](https://tools.ietf.org/html/rfc3031)

---

[BNAS2018 GitHub repository](https://github.com/auerswal/bnas2018) | [My GitHub user page](https://github.com/auerswal) | [My home page](https://www.unix-ag.uni-kl.de/~auerswal/)

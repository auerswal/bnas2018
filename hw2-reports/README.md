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

## Interlude: Beating Ansible Installation into Shape

As noted in [homework 1](../hw1-the_lab/) I decided to install Ansible
into a Python Virtual Environment (venv). That seemd to work fine, until
I tried to use the `ios_commands` module. While the `raw` module, using
[OpenSSH](https://www.openssh.com/), worked fine, the `ios_command`
module, using [Paramiko](http://www.paramiko.org/), did not:

```
fatal: [P1-oob.lab.local]: FAILED! => {"changed": false, "msg": "unable to open shell. Please see: https://docs.ansible.com/ansible/network_debug_troubleshooting.html#unable-to-open-shell"}
```

The link provided in the error message hinted at authentication errors
as the most likely cause, but it also provided information on how gather
debugging information: This is done by defining two environment variables,
`ANSIBLE_LOG_PATH` and `ANSIBLE_DEBUG`, to useful values and adding
`-vvvv` to the Ansible invocation:

```
env ANSIBLE_LOG_PATH=debug.log ANSIBLE_DEBUG=True ansible-playbook -l P1-oob.lab.local -vvvvv playbooks/topology.yml
```

In my case the file `debug.log` told me that Paramiko was not installed:

```
AnsibleError: paramiko is not installed
```

Taking a look at the contents of the Python Virtual Environment showed
Paramiko, trying to install or upgrade it did not change anything:

```
(ansible)$ pip install paramiko
 Requirement already satisfied (use --upgrade to upgrade): paramiko in /home/auerswald/work/bnas2018/ansible/lib/python2.7/site-packages
Cleaning up...
(ansible)$ pip install paramiko --upgrade
 Requirement already up-to-date: paramiko in /home/auerswald/work/bnas2018/ansible/lib/python2.7/site-packages
Cleaning up...
```

Manually importing Paramiko in a Python interpreter showed, that a
dependency of Paramiko was not installed:

```
(ansible)$ python
Python 2.7.6 (default, Nov 23 2017, 15:49:48)
[GCC 4.8.4] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import paramiko
  File "<stdin>", line 1, in <module>
  File "/home/auerswald/work/bnas2018/ansible/local/lib/python2.7/site-packages/paramiko/__init__.py", line 22, in <module>
    from paramiko.transport import SecurityOptions, Transport
  File "/home/auerswald/work/bnas2018/ansible/local/lib/python2.7/site-packages/paramiko/transport.py", line 34, in <module>
    from cryptography.hazmat.primitives.ciphers import algorithms, Cipher, modes
  File "/home/auerswald/work/bnas2018/ansible/local/lib/python2.7/site-packages/cryptography/hazmat/primitives/ciphers/__init__.py", line 7, in <module>
    from cryptography.hazmat.primitives.ciphers.base import (
  File "/home/auerswald/work/bnas2018/ansible/local/lib/python2.7/site-packages/cryptography/hazmat/primitives/ciphers/base.py", line 12, in <module>
    from cryptography.exceptions import (
  File "/home/auerswald/work/bnas2018/ansible/local/lib/python2.7/site-packages/cryptography/exceptions.py", line 7, in <module>
    from enum import Enum
ImportError: No module named enum
>>>
```

I then added the `enum` Python module to the venv using `pip`:

```
(ansible)$ pip install enum
  Downloading enum-0.4.6.tar.gz
  Running setup.py (path:/home/auerswald/work/bnas2018/ansible/build/enum/setup.py) egg_info for package enum
Requirement already satisfied (use --upgrade to upgrade): setuptools in /home/auerswald/work/bnas2018/ansible/lib/python2.7/site-packages (from enum)
Installing collected packages: enum
  Running setup.py install for enum
  Could not find .egg-info directory in install record for enum
Successfully installed enum
Cleaning up...
```

This still did not work, and would come back to bite me later because
that `enum` package was wrong (I needed `enum34` instead) but running
the playbook now resulted in a Syslog message on the router:

```
*Feb 24 20:35:45.903: %SSH-4-SSH2_UNEXPECTED_MSG: Unexpected message type has arrived. Terminating the connection from 192.168.254.42
```

Thus Ansible can now use Paramiko to connect to (network) devices. The
file `debug.log` showed a new Paramiko error:

```
2018-02-24 21:09:35,709 paramiko.transport     from cryptography.x509 import certificate_transparency
2018-02-24 21:09:35,709 paramiko.transport ImportError: cannot import name certificate_transparency
```

Again the `certificate_transparency.py` file is already available in the venv,
but manually importing results in an error:

```
(ansible)$ python
Python 2.7.6 (default, Nov 23 2017, 15:49:48)
[GCC 4.8.4] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> from cryptography.x509 import certificate_transparency
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/home/auerswald/work/bnas2018/ansible/local/lib/python2.7/site-packages/cryptography/x509/__init__.py", line 8, in <module>
    from cryptography.x509.base import (
  File "/home/auerswald/work/bnas2018/ansible/local/lib/python2.7/site-packages/cryptography/x509/base.py", line 16, in <module>
    from cryptography.x509.extensions import Extension, ExtensionType
  File "/home/auerswald/work/bnas2018/ansible/local/lib/python2.7/site-packages/cryptography/x509/extensions.py", line 10, in <module>
    import ipaddress
ImportError: No module named ipaddress
>>>
```

I then installed the `ipaddress` Python package into the Python Virtual
Environment:

```
(ansible)$ pip install -U ipaddress
Downloading/unpacking ipaddress
  Downloading ipaddress-1.0.19.tar.gz
  Running setup.py (path:/home/auerswald/work/bnas2018/ansible/build/ipaddress/setup.py) egg_info for package ipaddress
Installing collected packages: ipaddress
  Running setup.py install for ipaddress
  Could not find .egg-info directory in install record for ipaddress
Successfully installed ipaddress
Cleaning up...
```

Now I was getting somewhere, because Ansible no longer failed to open
a shell, but crashed with the error message:

```
ERROR! Unexpected Exception, this is probably a bug: 'type' object is not iterable
[...]
  File "/home/auerswald/work/bnas2018/ansible/local/lib/python2.7/site-packages/cryptography/x509/name.py", line 28, in <module>
    _ASN1_TYPE_TO_ENUM = dict((i.value, i) for i in _ASN1Type)
TypeError: 'type' object is not iterable
```

Trying the respective code by hand in a Python interpreter showed that
the `enum` package I installed was not used the way the `cryptography`
package did. The solution was to ask Google, which answered that the
Python package to provide an `Enum` similar to that introduced with Python
3.4 was called `enum34`. Thus I removed `enum` and installed `enum34`:

```
(ansible)$ pip uninstall enum
Uninstalling enum:
  /home/auerswald/work/bnas2018/ansible/lib/python2.7/site-packages/enum-0.4.6-py2.7.egg-info
  /home/auerswald/work/bnas2018/ansible/lib/python2.7/site-packages/enum.py
  /home/auerswald/work/bnas2018/ansible/lib/python2.7/site-packages/enum.pyc
Proceed (y/n)? y
  Successfully uninstalled enum
(ansible)$ pip install enum34
Downloading/unpacking enum34
  Downloading enum34-1.1.6-py2-none-any.whl
Installing collected packages: enum34
Successfully installed enum34
Cleaning up...
```

Now the Paramiko connection was setup correctly and the Ansible `ios_command`
module worked as expected.

---

[BNAS2018 GitHub repository](https://github.com/auerswal/bnas2018) | [My GitHub user page](https://github.com/auerswal) | [My home page](https://www.unix-ag.uni-kl.de/~auerswal/)
